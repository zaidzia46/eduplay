# Media → Storage: Lesson Content Images

Status: **Phase 1 code done; bucket setup + verification pending.**

Move data-driven lesson content images out of the app bundle into Supabase
Storage so the app binary doesn't grow with the catalog (hundreds of chapters).

## Decisions (locked)
- **Public bucket** `lesson-media` + `getPublicUrl` (no signing; CDN- and
  disk-cacheable via `cached_network_image`). Contrast with the private
  `avatars` bucket, which uses signed URLs because avatars are per-user.
- **Scope:** `content_blocks.data.url` images only. Subject icons
  (`subjects.icon_path`) stay bundled → Phase 2.
- **Path convention:** the Storage object key **equals** the value already in
  `content_blocks.data.url` (e.g. `grade1/math/math4.png`) → **no DB changes.**

## Part A — Supabase dashboard (manual)
1. Storage → New bucket → name `lesson-media` → toggle **Public** → create.
2. Upload existing images preserving folders so keys match the DB:
   `lesson-media/grade1/math/math1.png` … `math10.png`.
3. Public bucket allows anon read (no read policy needed). Dashboard uploads use
   the service role and bypass RLS (no write policy needed for hand-seeding).
   Only if uploading from a script/app later:
   ```sql
   create policy "lesson-media authenticated write"
   on storage.objects for insert to authenticated
   with check (bucket_id = 'lesson-media');
   ```
4. Verify a public URL loads in a browser:
   `https://<project>.supabase.co/storage/v1/object/public/lesson-media/grade1/math/math1.png`

## Part B — Code (DONE)
- `lib/core/media_service.dart` — `MediaService.lessonMediaUrl(path)` →
  `getPublicUrl` from the `lesson-media` bucket.
- `content_block_view.dart` — `_ToyChip` and `_SingleImageView` now use
  `CachedNetworkImage` (kept the old fallback icon as `errorWidget`; added
  placeholders). Removed the `_kMediaRoot` asset constant.
- `content_block_model.dart` — `ImageBlock.url` doc updated (Storage key, not
  asset path).

## Part C — Verify & clean up (PENDING, after Part A)
- Open the Counting lesson → confirm images load from network; re-open offline
  to confirm `cached_network_image` disk cache.
- Then remove `assets/subImages/...` from `pubspec.yaml` and delete the local
  files. (Left in place until verified so there's a fallback during cutover.)

## Rollback
- `errorWidget` degrades a missing/mis-keyed object to the same "not supported"
  icon shown today — no crash. DB untouched; revert = revert the code diff.

## Later (not this phase)
- Phase 2: subject icons (`icon_path`), same public-bucket pattern — decide
  whether to re-key `icon_path` to full Storage paths or keep a prefix.
- JSON→seed importer should also upload media so new lessons are one step.
