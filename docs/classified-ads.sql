-- =============================================================================
--  classified-ads.sql  —  Classified Ads backend (table + storage + RLS)
-- =============================================================================
--
--  WHAT THIS IS
--  ------------
--  The public App Dashboard (the logged-out landing screen) shows a grid of
--  "Classified Ads" cards. This file turns that hardcoded list into a real,
--  admin-managed backend: one table of ads, a public Storage bucket for their
--  images, and read-only access for everyone — including logged-out (anon)
--  visitors, since the App Dashboard has no Supabase user.
--
--  The in-app "inside content" (what opens when an ad is tapped) is NOT defined
--  yet — this is only the catalog + image plumbing. `link_url` is reserved for
--  that future step.
--
--  HOW TO RUN  (!! run manually — the app never applies migrations)
--  ---------------------------------------------------------------
--   1. Supabase Dashboard -> Storage -> "New bucket":
--        name:   classified-ads
--        public: ON   <- must be public so logged-out users can load images
--      (Or just run SECTION 3 below, which creates it idempotently.)
--   2. Supabase Dashboard -> SQL Editor -> paste this whole file -> Run.
--   3. Upload ad images into the `classified-ads` bucket, then put each
--      object's path (e.g. "banners/pttb.jpg") into classified_ads.image_path.
--      You may also paste a full external https URL into image_path instead —
--      the app detects "http(s)://" and uses it as-is.
--
--  This script is idempotent: safe to re-run. (Adding columns later needs an
--  explicit `alter table ... add column if not exists`.)
-- =============================================================================


-- ─── SECTION 1 — table ───────────────────────────────────────────────────────
create table if not exists public.classified_ads (
  id          bigint generated always as identity primary key,
  title       text        not null,
  description text,
  image_path  text,                 -- object key in the `classified-ads` bucket,
                                     -- or a full https URL (used as-is)
  ad_type     text        not null default 'sponsored',
                                     -- conventional values: 'sponsored',
                                     -- 'featured', 'promoted', 'announcement'.
                                     -- Kept as free text so new types need no
                                     -- migration; the app styles unknown types
                                     -- with a neutral fallback badge.
  link_url    text,                 -- reserved: tap destination (inside content TBD)
  is_active   boolean     not null default true,
  sort_order  integer     not null default 0,   -- lower = shown first
  starts_at   timestamptz,          -- optional schedule window start (null = always)
  ends_at     timestamptz,          -- optional schedule window end   (null = always)
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

comment on table public.classified_ads is
  'Admin-managed classified ads shown on the public App Dashboard.';

-- Fast path for the client query (visible ads, ordered).
create index if not exists classified_ads_visible_idx
  on public.classified_ads (is_active, sort_order, created_at desc);


-- ─── SECTION 2 — keep updated_at fresh ───────────────────────────────────────
-- Scoped name to avoid clobbering any shared set_updated_at() in the project.
create or replace function public.classified_ads_set_updated_at()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_classified_ads_updated_at on public.classified_ads;
create trigger trg_classified_ads_updated_at
  before update on public.classified_ads
  for each row execute function public.classified_ads_set_updated_at();


-- ─── SECTION 3 — storage bucket (alternative to the dashboard step) ──────────
-- Public buckets serve objects over getPublicUrl with no per-object RLS needed,
-- which is exactly what the logged-out App Dashboard requires.
insert into storage.buckets (id, name, public)
values ('classified-ads', 'classified-ads', true)
on conflict (id) do update set public = true;


-- ─── SECTION 4 — row level security (public read-only) ───────────────────────
alter table public.classified_ads enable row level security;

-- Everyone (anon + authenticated) may read ONLY currently-visible ads:
-- active, and within the optional schedule window. Hidden / expired / future
-- ads never leave the database, so the client can query the table directly and
-- trust whatever it gets back.
drop policy if exists "classified_ads public read" on public.classified_ads;
create policy "classified_ads public read"
  on public.classified_ads
  for select
  to anon, authenticated
  using (
    is_active
    and (starts_at is null or starts_at <= now())
    and (ends_at   is null or ends_at   >  now())
  );

grant select on public.classified_ads to anon, authenticated;
-- No insert/update/delete grants: ads are managed from the Supabase dashboard
-- (service role), never from the app.


-- ─── SECTION 5 — seed examples (optional; uncomment to insert) ────────────────
-- insert into public.classified_ads (title, description, image_path, ad_type, sort_order)
-- values
--   ('Punjab Textbook Curriculum',
--    'Complete learning content as per Punjab Textbook Board.',
--    'banners/pttb.jpg', 'sponsored', 1),
--   ('Grade 4 added for LSG Lahore',
--    'New learning content for grade 4, aligned with LSG Lahore.',
--    'banners/lsg-lahore.jpg', 'featured', 2),
--   ('Sindh Textbook Curriculum',
--    'Complete learning content as per Sindh Textbook Board.',
--    'banners/sttb.jpg', 'promoted', 3);


-- ─── SECTION 6 — sanity checks ───────────────────────────────────────────────
-- select id, title, ad_type, is_active, sort_order
--   from public.classified_ads order by sort_order, created_at desc;
-- select * from pg_policies where tablename = 'classified_ads';
-- select id, public from storage.buckets where id = 'classified-ads';
