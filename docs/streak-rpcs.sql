-- ════════════════════════════════════════════════════════════════════════
-- streak-rpcs.sql — per-child day-streak, computed server-side.
--
-- RUN MANUALLY in the Supabase SQL editor. Nothing in the app applies this.
--
-- Companion to progress-rpcs.sql. Each child already has current_streak /
-- longest_streak columns on `children` and the whole app already READS them
-- (ChildProfileModel, the profile switcher, dashboard, progress). What's
-- missing is anything that ever MOVES the number — this file adds it.
--
-- Streak rule: a calendar day (in app_timezone()) with >= 1 quiz attempt —
-- pass OR fail — extends the streak. A fully-missed day breaks the run; the
-- next play starts a new run at 1. current_streak counts the run ending on the
-- most recent play day, but ONLY while that day is today or yesterday in
-- app_timezone(): once a child goes a whole calendar day without playing, it
-- decays back to 0 instead of freezing on the last achieved value. Two writers
-- keep the stored column honest — the AFTER INSERT trigger (section 3) moves it
-- up on each play, and a daily pg_cron job (section 5) decays it the morning
-- after a missed day. longest_streak is an all-time high-water mark, no decay.
--
-- The whole file is idempotent — safe to re-run.
-- ════════════════════════════════════════════════════════════════════════


-- ─────────────────────────────────────────────────────────────────────────
-- STEP 0 (ALREADY RUN — result recorded here). quiz_attempts has exactly two
-- AFTER INSERT triggers, and NEITHER writes the streak columns:
--   • trg_compute_quiz_stars      -> compute_quiz_stars()      (writes
--       stars_ledger / child_quiz_best / quiz_attempts.stars_awarded — it
--       never touches the children table at all)
--   • trg_sync_overall_on_attempt -> sync_child_overall_progress()  (writes
--       children.overall_progress only)
-- So current_streak/longest_streak have no existing writer → this is Branch B
-- (standalone additive trigger, section 3). The "stars/streak trigger" phrase
-- in progress-rpcs.sql was a misnomer; the stars trigger never touched streak.
-- Re-run this any time the trigger set changes:
-- select tgname, pg_get_triggerdef(t.oid), p.proname, pg_get_functiondef(p.oid)
-- from pg_trigger t join pg_proc p on p.oid = t.tgfoid
-- where t.tgrelid = 'public.quiz_attempts'::regclass and not t.tgisinternal
-- order by tgname;
-- ─────────────────────────────────────────────────────────────────────────


-- ─────────────────────────────────────────────────────────────────────────
-- 1. Timezone helper. "Calendar day" needs one fixed zone, decided BEFORE the
--    backfill — changing it later means re-running the backfill. Use a named
--    IANA zone (DST-correct), never a fixed offset. Change the string here if
--    the app's audience is not on Pakistan time.
-- ─────────────────────────────────────────────────────────────────────────
create or replace function public.app_timezone()
returns text
language sql
immutable
as $$ select 'Asia/Karachi' $$;


-- ─────────────────────────────────────────────────────────────────────────
-- 2. Streak computation (classic gaps-and-islands). Consecutive calendar days
--    form an "island": ordering the distinct play-days and subtracting the
--    row number leaves every day in one run mapped to the same anchor date
--    (grp), so grouping by grp gives each run's length and last day.
--
--    language sql (no variables / no DECLARE): the final FROM-less SELECT
--    guarantees exactly one row even when the child has zero history — it
--    returns (0, 0) rather than no rows. The ::int cast on row_number() is
--    load-bearing: date - int4 -> date (there is no date - bigint operator).
-- ─────────────────────────────────────────────────────────────────────────
create or replace function public.compute_child_streak(p_child_id bigint)
returns table(current_streak int, longest_streak int)
language sql
stable
as $$
  with days as (
    select distinct (a.attempted_at at time zone public.app_timezone())::date as d
    from public.quiz_attempts a
    where a.child_id = p_child_id
  ),
  grouped as (
    select d, d - (row_number() over (order by d))::int as grp
    from days
  ),
  runs as (
    select grp, count(*)::int as len, max(d) as last_day
    from grouped
    group by grp
  )
  select
    -- current run = the run ending on the most recent play day, but it counts
    -- ONLY while that day is today or yesterday (app_timezone). A fully-missed
    -- calendar day leaves this WHERE with no row -> coalesce -> 0, so the
    -- streak decays instead of freezing on the last achieved value.
    coalesce((select r.len
              from runs r
              where r.last_day = (select max(last_day) from runs)
                and r.last_day >= (now() at time zone public.app_timezone())::date - 1
             ), 0) as current_streak,
    -- longest_streak is an all-time high-water mark — the longest run ever, no decay
    coalesce((select max(r.len) from runs r), 0) as longest_streak;
$$;


-- ─────────────────────────────────────────────────────────────────────────
-- 3. Keep the stored columns current on every new attempt (Branch B, per
--    Step 0: nothing else writes streak, so this standalone trigger — touching
--    ONLY current_streak/longest_streak — coexists cleanly with
--    trg_compute_quiz_stars and trg_sync_overall_on_attempt). Same SECURITY
--    DEFINER + search_path pattern as sync_child_overall_progress() so the
--    UPDATE on children isn't blocked by RLS; longest_streak never regresses.
--    Being AFTER INSERT, compute_child_streak() already sees the just-inserted
--    attempt, so the current day's play counts immediately.
-- ─────────────────────────────────────────────────────────────────────────
create or replace function public.sync_child_streak()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cur int;
  v_lng int;
begin
  select current_streak, longest_streak
    into v_cur, v_lng
    from public.compute_child_streak(new.child_id);

  update public.children
     set current_streak = coalesce(v_cur, 0),
         longest_streak = greatest(coalesce(longest_streak, 0), coalesce(v_lng, 0))
   where id = new.child_id;

  return new;
end;
$$;

drop trigger if exists trg_sync_streak_on_attempt on public.quiz_attempts;
create trigger trg_sync_streak_on_attempt
  after insert on public.quiz_attempts
  for each row execute function public.sync_child_streak();


-- ─────────────────────────────────────────────────────────────────────────
-- 4. Backfill so existing children reflect their real streak now instead of
--    staying frozen until their next attempt. The LATERAL rides an INNER
--    children scan (c) and we join back on id — an UPDATE's own target table
--    (ch) can't be referenced from its FROM/LATERAL (error 42P10), so we can't
--    write `from lateral compute_child_streak(ch.id)`. Computes once per child.
--    Now that compute_child_streak() is today-aware, re-running this ALSO
--    decays every already-stale child straight to 0 — the instant correction
--    for rows created under the old non-decaying rule. Safe to re-run.
-- ─────────────────────────────────────────────────────────────────────────
update public.children ch
   set current_streak = s.current_streak,
       longest_streak = greatest(coalesce(ch.longest_streak, 0), s.longest_streak)
  from (
    select c.id as child_id,
           cs.current_streak,
           cs.longest_streak
    from public.children c
    cross join lateral public.compute_child_streak(c.id) cs
  ) s
 where ch.id = s.child_id;


-- ─────────────────────────────────────────────────────────────────────────
-- 5. Daily decay. The section-3 trigger only ever fires on a NEW attempt, so a
--    child who STOPS playing is never re-evaluated and the stored current_streak
--    would otherwise sit frozen forever. pg_cron runs the same freshness test
--    once a day and zeroes any child whose most recent play day is now older
--    than yesterday (app_timezone). This is the piece that makes "miss a day ->
--    streak back to 0" happen on its own, with no app code involved.
--
--    Enable pg_cron once: Supabase Dashboard → Database → Extensions → enable
--    `pg_cron` (or the CREATE EXTENSION below — both are fine; it's a no-op if
--    already enabled). Jobs run on the server clock (UTC). Asia/Karachi is
--    UTC+5 with no DST, so 19:10 UTC == 00:10 Karachi next day — just after the
--    calendar day rolls over. If app_timezone() changes, move this hour to match.
--
--    Idempotent: the unschedule SELECT returns no rows (and does nothing) when
--    the job doesn't exist yet, so it's safe before the first schedule. The job
--    writes only the children it actually decays (nonzero streak AND now stale);
--    active children are never touched and longest_streak is left alone.
-- ─────────────────────────────────────────────────────────────────────────
create extension if not exists pg_cron;

select cron.unschedule(jobid)
  from cron.job
 where jobname = 'reset-stale-streaks';

select cron.schedule(
  'reset-stale-streaks',
  '10 19 * * *',
  $cron$
    update public.children ch
       set current_streak = 0
     where coalesce(ch.current_streak, 0) <> 0
       and not exists (
         select 1
         from public.quiz_attempts a
         where a.child_id = ch.id
           and (a.attempted_at at time zone public.app_timezone())::date
               >= (now() at time zone public.app_timezone())::date - 1
       );
  $cron$
);


-- ─────────────────────────────────────────────────────────────────────────
-- 6. Expose to the client roles used by supabase_flutter.
-- ─────────────────────────────────────────────────────────────────────────
grant execute on function public.app_timezone() to anon, authenticated;
grant execute on function public.compute_child_streak(bigint) to anon, authenticated;


-- ── Sanity checks (replace 1 with a real child id) ──
-- select * from public.compute_child_streak(1);
-- select id, name, current_streak, longest_streak from public.children order by id;
