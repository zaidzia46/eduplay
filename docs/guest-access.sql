-- Guest / Anonymous access — backend setup for eduplay
-- Run this MANUALLY in the Supabase SQL editor (Dashboard → SQL Editor → New
-- query). This file never runs itself; the app does not apply migrations.
--
-- It is idempotent — safe to re-run. Read the two Dashboard prerequisites below
-- FIRST; they are toggles, not SQL, and the flow does not work without the
-- first one.
--
-- ─────────────────────────────────────────────────────────────────────────
-- DASHBOARD PREREQUISITE (required, not SQL)
--   Authentication → Sign In / Providers → "Anonymous sign-ins" → ENABLE.
--   Without it, supabase.auth.signInAnonymously() returns HTTP 422 and the
--   "Explore as guest" button fails.
--
-- DASHBOARD DECISION — email confirmation (your call, not SQL)
--   Authentication → ... → "Confirm email".
--   When ON: converting a guest (updateUser with a new email) keeps them
--   signed in on the SAME anonymous session, but the new email stays pending
--   until they click the confirmation link (gotrue exposes it as
--   User.newEmail). The app already detects this and shows a gentle
--   "check your email to confirm" note; their progress is safe either way.
--   When OFF: the email is usable immediately. Either setting works with the
--   app — pick per your product policy.
--
-- ABUSE (future hardening, out of scope here)
--   Anonymous sign-in can be scripted, minting throwaway auth.users rows.
--   Consider Supabase's CAPTCHA / rate-limit protections, and run the
--   stale-guest cleanup at the bottom periodically to bound growth.
-- ─────────────────────────────────────────────────────────────────────────


-- ─────────────────────────────────────────────────────────────────────────
-- 1. handle_new_parent(): must tolerate anonymous sign-ups.
--
-- Anonymous sign-in inserts an auth.users row with NO email and NO 'name' in
-- raw_user_meta_data. The app requires a public.parents row to exist for the
-- children.parent_id FK, and that row is created by this AFTER INSERT trigger
-- on auth.users. If the trigger inserts a NULL into a NOT NULL parents.name,
-- the whole sign-in fails ("Database error creating anonymous user").
--
-- STEP 1a — inspect YOUR current definition first, so you can preserve any
-- extra columns it sets (uncomment and run):
--
--   select pg_get_functiondef('public.handle_new_parent()'::regprocedure);
--
-- STEP 1b — recommended defensive version. It defaults the name to 'Guest'
-- when metadata is absent/empty. REVIEW the diagnostic above and merge in any
-- additional columns your version writes. NOTE: anonymous users have a NULL
-- email, so if your parents table has a NOT NULL email column you must make it
-- nullable for guests (or insert a placeholder here).
-- ─────────────────────────────────────────────────────────────────────────
create or replace function public.handle_new_parent()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.parents (id, name)
  values (
    new.id,
    coalesce(nullif(new.raw_user_meta_data ->> 'name', ''), 'Guest')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;
-- The existing "after insert on auth.users" trigger keeps pointing at this
-- function, so only the body is replaced — no trigger rebind needed.


-- ─────────────────────────────────────────────────────────────────────────
-- 2. parents: let a parent update their own row.
--
-- Converting a guest (register in convert mode) calls
--   update parents set name = <entered name> where id = auth.uid()
-- so the display name stops being the 'Guest' default. Under RLS a missing
-- UPDATE policy makes that a silent no-op (0 rows, no error). This grants it,
-- scoped strictly to the caller's own row. Harmless for real parents.
-- ─────────────────────────────────────────────────────────────────────────
drop policy if exists "Parents can update own row" on public.parents;
create policy "Parents can update own row"
  on public.parents
  for update
  to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());


-- ─────────────────────────────────────────────────────────────────────────
-- 3. children: cap guests at exactly one child.
--
-- Anonymous users carry the 'authenticated' role, so every existing
-- authenticated policy already applies to them — a guest is just a parent with
-- one child. The only extra rule: a guest may not create a SECOND child.
--
-- This is a RESTRICTIVE policy, so it is AND-ed with (not OR-ed against) your
-- existing PERMISSIVE insert policy on children — it can only ever tighten,
-- never widen. It assumes RLS is already enabled on children and a permissive
-- INSERT policy already exists (it must, since real parents create children
-- today). The claim check short-circuits to TRUE for non-anonymous users, so
-- real parents are entirely unaffected.
-- ─────────────────────────────────────────────────────────────────────────
drop policy if exists "Guest child cap" on public.children;
create policy "Guest child cap"
  on public.children
  as restrictive
  for insert
  to authenticated
  with check (
    not coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false)
    or (select count(*) from public.children where parent_id = auth.uid()) = 0
  );

-- Alternative / defense-in-depth (optional): a BEFORE INSERT trigger giving a
-- friendlier error. Uncomment if you prefer it over (or alongside) the policy:
--
-- create or replace function public.enforce_guest_child_cap()
-- returns trigger language plpgsql security definer set search_path = public as $$
-- begin
--   if coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false)
--      and (select count(*) from public.children where parent_id = new.parent_id) >= 1 then
--     raise exception 'Guests can create only one child — sign up to add more.'
--       using errcode = 'check_violation';
--   end if;
--   return new;
-- end;
-- $$;
-- drop trigger if exists trg_guest_child_cap on public.children;
-- create trigger trg_guest_child_cap
--   before insert on public.children
--   for each row execute function public.enforce_guest_child_cap();


-- ─────────────────────────────────────────────────────────────────────────
-- 4. Catalog readability check (diagnostic only — no changes).
--
-- The grade cascade (cities → institutes → curricula → standards) and all quiz
-- content must be SELECT-able by role 'authenticated' — which now includes
-- guests. Real parents already read these, and anon users share that role, so
-- no new grant is expected. Just confirm no policy filters on is_anonymous.
-- Adjust the table list to match your schema, then run:
--
--   select schemaname, tablename, policyname, cmd, roles, qual
--   from pg_policies
--   where tablename in (
--     'cities', 'institutes', 'institute_curricula',
--     'institute_curricula_standard', 'standards', 'standard_subjects',
--     'subjects', 'chapters', 'quizzes', 'questions'
--   )
--   order by tablename, policyname;
-- ─────────────────────────────────────────────────────────────────────────


-- ─────────────────────────────────────────────────────────────────────────
-- 5. Stale-guest cleanup (bounds auth.users growth).
--
-- Every "Explore as guest" tap that is never converted leaves an anonymous
-- auth.users row (plus its parents/children/attempts) forever. Delete anon
-- users idle for > 30 days. This CASCADES only if the FK chain
--   auth.users → parents → children → quiz_attempts / child_standard_enrollment
-- is ON DELETE CASCADE. Verify first, then uncomment the delete.
--
-- Verify cascade from parents → children (confdeltype 'c' = cascade):
--   select conname, confdeltype
--   from pg_constraint
--   where conrelid = 'public.children'::regclass and contype = 'f';
-- and that parents.id → auth.users cascades:
--   select conname, confdeltype
--   from pg_constraint
--   where conrelid = 'public.parents'::regclass and contype = 'f';
--
-- Then (uncomment to actually delete):
--   delete from auth.users u
--   where u.is_anonymous
--     and coalesce(u.last_sign_in_at, u.created_at) < now() - interval '30 days';
--
-- If the chain is NOT fully cascading, delete children/parents explicitly
-- first, or add the cascade. To automate, schedule the delete with pg_cron
-- (Database → Extensions → enable pg_cron), e.g. a nightly job — otherwise run
-- it manually now and then.
-- ─────────────────────────────────────────────────────────────────────────


-- ── Post-setup sanity checks (run after enabling Anonymous sign-ins) ──
-- 1) An anon sign-in should create a parents row:
--    (sign in as guest from the app, then, as the service role / SQL editor)
--    select id, name from public.parents order by id desc limit 5;
-- 2) A guest must NOT be able to insert a 2nd child — the app hides the button,
--    but a direct insert of a second children row for the same parent_id should
--    be rejected by the "Guest child cap" policy above.
