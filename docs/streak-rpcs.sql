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
-- next play starts a new run at 1. current_streak reflects the run ending on
-- the child's LAST play day and deliberately does NOT decay between plays:
-- it shows the last achieved streak until the child plays again. This keeps
-- the trigger and the backfill consistent (both anchor on max(day), never on
-- "today") and is kinder for kids.
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
    -- current run = the run whose last day is the most recent play day
    coalesce((select r.len
              from runs r
              where r.last_day = (select max(last_day) from runs)), 0) as current_streak,
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
-- 4. One-time backfill so existing children reflect their real streak now
--    instead of staying frozen until their next attempt. The LATERAL rides an
--    INNER children scan (c) and we join back on id — an UPDATE's own target
--    table (ch) can't be referenced from its FROM/LATERAL (error 42P10), so we
--    can't write `from lateral compute_child_streak(ch.id)`. Computes once per
--    child. Branch-independent; also the exact line to RECONCILE anytime.
--    Safe to re-run.
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
-- 5. Expose to the client roles used by supabase_flutter.
-- ─────────────────────────────────────────────────────────────────────────
grant execute on function public.app_timezone() to anon, authenticated;
grant execute on function public.compute_child_streak(bigint) to anon, authenticated;


-- ── Sanity checks (replace 1 with a real child id) ──
-- select * from public.compute_child_streak(1);
-- select id, name, current_streak, longest_streak from public.children order by id;
