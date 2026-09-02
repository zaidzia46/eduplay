-- Progress feature RPCs for eduplay
-- Run this once in the Supabase SQL editor (Dashboard → SQL Editor → New query).
--
-- All three functions are SECURITY INVOKER (the default), so the existing RLS
-- policies that already let the signed-in parent select from children /
-- quiz_attempts / the catalog tables apply unchanged.
--
-- Completion is PASS-BASED: a quiz counts as passed when the child has at
-- least one attempt scoring >= that quiz's passing_score_percent.
--   chapter %  = passed quizzes / total quizzes in the chapter
--   subject %  = completed chapters / total chapters in the subject
--   overall %  = average of subject % across subjects that have content
-- Everything is scoped to the child's CURRENT enrollment
-- (child_standard_enrollment.is_current = true).

-- ─────────────────────────────────────────────────────────────────────────
-- 1. Overview: one JSON payload for the Progress tab.
-- ─────────────────────────────────────────────────────────────────────────
create or replace function public.get_child_progress(p_child_id bigint)
returns jsonb
language sql
stable
as $$
with enrollment as (
  select curriculum_id, standard_id
  from child_standard_enrollment
  where child_id = p_child_id and is_current = true
  limit 1
),
ss as (
  select s.id as standard_subject_id,
         subj.id as subject_id,
         subj.name,
         subj.color_hex,
         subj.icon_path
  from standard_subjects s
  join enrollment e
    on e.curriculum_id = s.curriculum_id
   and e.standard_id = s.standard_id
  join subjects subj on subj.id = s.subject_id
),
ch as (
  select c.id as chapter_id, c.standard_subject_id
  from chapters c
  join ss on ss.standard_subject_id = c.standard_subject_id
),
qz as (
  select q.id as quiz_id, q.chapter_id, q.passing_score_percent
  from quizzes q
  join ch on ch.chapter_id = q.chapter_id
),
quiz_pass as (
  select qz.quiz_id,
         qz.chapter_id,
         (exists (
           select 1
           from quiz_attempts a
           where a.child_id = p_child_id
             and a.quiz_id = qz.quiz_id
             and a.total_questions > 0
             and (a.correct_count::numeric / a.total_questions) * 100
                 >= qz.passing_score_percent
         ))::int as passed
  from qz
),
chapter_agg as (
  select ch.chapter_id,
         ch.standard_subject_id,
         count(qp.quiz_id) as quizzes_total,
         coalesce(sum(qp.passed), 0) as quizzes_passed
  from ch
  left join quiz_pass qp on qp.chapter_id = ch.chapter_id
  group by ch.chapter_id, ch.standard_subject_id
),
chapter_done as (
  select chapter_id,
         standard_subject_id,
         quizzes_total,
         quizzes_passed,
         (quizzes_total > 0 and quizzes_passed = quizzes_total)::int as completed
  from chapter_agg
),
subject_agg as (
  select ss.standard_subject_id,
         ss.subject_id,
         ss.name,
         ss.color_hex,
         ss.icon_path,
         count(cd.chapter_id) as chapters_total,
         coalesce(sum(cd.completed), 0) as chapters_completed
  from ss
  left join chapter_done cd on cd.standard_subject_id = ss.standard_subject_id
  group by ss.standard_subject_id, ss.subject_id, ss.name, ss.color_hex, ss.icon_path
),
subject_pct as (
  select *,
         case when chapters_total > 0
              then round(chapters_completed::numeric / chapters_total * 100)::int
              else 0 end as percent,
         (chapters_total > 0 and chapters_completed = chapters_total)::int
           as subject_completed
  from subject_agg
),
chapter_totals as (
  select count(*) as chapters_total,
         coalesce(sum(completed), 0) as chapters_completed
  from chapter_done
),
quiz_totals as (
  select count(*) as quizzes_total,
         coalesce(sum(passed), 0) as quizzes_passed
  from quiz_pass
)
select jsonb_build_object(
  'overall_percent', coalesce(
    (select round(avg(percent))::int from subject_pct where chapters_total > 0), 0),
  'subjects_total', (select count(*) from subject_pct),
  'subjects_completed', (select coalesce(sum(subject_completed), 0) from subject_pct),
  'chapters_total', (select chapters_total from chapter_totals),
  'chapters_completed', (select chapters_completed from chapter_totals),
  'quizzes_total', (select quizzes_total from quiz_totals),
  'quizzes_passed', (select quizzes_passed from quiz_totals),
  'subjects', coalesce((
    select jsonb_agg(jsonb_build_object(
      'standard_subject_id', standard_subject_id,
      'subject_id', subject_id,
      'name', name,
      'color_hex', color_hex,
      'icon_path', icon_path,
      'chapters_total', chapters_total,
      'chapters_completed', chapters_completed,
      'percent', percent
    ) order by name)
    from subject_pct
  ), '[]'::jsonb)
);
$$;

-- ─────────────────────────────────────────────────────────────────────────
-- 2. Recent activity: latest quiz attempts, joined up to the subject.
-- ─────────────────────────────────────────────────────────────────────────
create or replace function public.get_child_recent_activity(
  p_child_id bigint,
  p_limit int default 5
)
returns table (
  id bigint,
  quiz_id bigint,
  quiz_title text,
  subject_name text,
  color_hex text,
  stars_awarded int,
  attempted_at timestamptz
)
language sql
stable
as $$
  select a.id::bigint,
         a.quiz_id::bigint,
         q.title::text as quiz_title,
         subj.name::text as subject_name,
         subj.color_hex::text,
         a.stars_awarded::int,
         a.attempted_at::timestamptz
  from quiz_attempts a
  join quizzes q on q.id = a.quiz_id
  join chapters c on c.id = q.chapter_id
  join standard_subjects s on s.id = c.standard_subject_id
  join subjects subj on subj.id = s.subject_id
  where a.child_id = p_child_id
  order by a.attempted_at desc
  limit p_limit;
$$;

-- ─────────────────────────────────────────────────────────────────────────
-- 3. Per-chapter drill-down for one subject (powers the ChapterScreen bars).
-- ─────────────────────────────────────────────────────────────────────────
create or replace function public.get_child_subject_chapters(
  p_child_id bigint,
  p_standard_subject_id bigint
)
returns table (
  chapter_id bigint,
  title text,
  sort_order int,
  quizzes_total int,
  quizzes_passed int,
  percent int,
  is_completed boolean
)
language sql
stable
as $$
with qz as (
  select q.id as quiz_id, q.chapter_id, q.passing_score_percent
  from quizzes q
  join chapters c on c.id = q.chapter_id
  where c.standard_subject_id = p_standard_subject_id
),
quiz_pass as (
  select qz.quiz_id,
         qz.chapter_id,
         (exists (
           select 1
           from quiz_attempts a
           where a.child_id = p_child_id
             and a.quiz_id = qz.quiz_id
             and a.total_questions > 0
             and (a.correct_count::numeric / a.total_questions) * 100
                 >= qz.passing_score_percent
         ))::int as passed
  from qz
),
agg as (
  select c.id as chapter_id,
         c.title,
         c.sort_order,
         count(qp.quiz_id) as quizzes_total,
         coalesce(sum(qp.passed), 0) as quizzes_passed
  from chapters c
  left join quiz_pass qp on qp.chapter_id = c.id
  where c.standard_subject_id = p_standard_subject_id
  group by c.id, c.title, c.sort_order
)
select chapter_id::bigint,
       title::text,
       sort_order::int,
       quizzes_total::int,
       quizzes_passed::int,
       (case when quizzes_total > 0
             then round(quizzes_passed::numeric / quizzes_total * 100)::int
             else 0 end)::int as percent,
       (quizzes_total > 0 and quizzes_passed = quizzes_total) as is_completed
from agg
order by sort_order;
$$;

-- ─────────────────────────────────────────────────────────────────────────
-- 4. Per-quiz progress for one chapter (powers the QuizListScreen badges).
--    best_percent = best score across all attempts (0 if never attempted);
--    is_passed    = any attempt >= that quiz's passing_score_percent;
--    attempted    = the child has at least one attempt at the quiz.
-- ─────────────────────────────────────────────────────────────────────────
create or replace function public.get_chapter_quiz_progress(
  p_child_id bigint,
  p_chapter_id bigint
)
returns table (
  quiz_id bigint,
  best_percent int,
  is_passed boolean,
  attempted boolean
)
language sql
stable
as $$
  select q.id::bigint as quiz_id,
         coalesce(
           round(max(a.correct_count::numeric / nullif(a.total_questions, 0) * 100)),
           0
         )::int as best_percent,
         coalesce(
           bool_or(
             a.total_questions > 0
             and (a.correct_count::numeric / a.total_questions) * 100
                 >= q.passing_score_percent
           ),
           false
         ) as is_passed,
         (count(a.id) > 0) as attempted
  from quizzes q
  left join quiz_attempts a
    on a.quiz_id = q.id
   and a.child_id = p_child_id
  where q.chapter_id = p_chapter_id
  group by q.id;
$$;

-- Expose to the client roles used by supabase_flutter.
grant execute on function public.get_child_progress(bigint) to anon, authenticated;
grant execute on function public.get_child_recent_activity(bigint, int) to anon, authenticated;
grant execute on function public.get_child_subject_chapters(bigint, bigint) to anon, authenticated;
grant execute on function public.get_chapter_quiz_progress(bigint, bigint) to anon, authenticated;

-- ── Sanity checks (replace 1 with a real child id) ──
-- select public.get_child_progress(1);
-- select * from public.get_child_recent_activity(1, 5);
-- select * from public.get_child_subject_chapters(1, 1);
-- select * from public.get_chapter_quiz_progress(1, 1);
