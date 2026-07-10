# Download Location, WebDAV Sync & Metadata — Implementation Handoff

**Last updated:** 2026-07-10  
**Status:** Code in-repo; manual device validation (Step 5) pending.

Read this file to resume in a new session.

## Original goals

1. Download location survives portable rebuilds (`userdata/` kept).
2. Download path does NOT sync PC ↔ phone.
3. Fix WebDAV "Sync progress" null-check crash.
4. Sync extensions (full binary), feeds, saved filters, order, extension settings.
5. Per-category library sort (Hive `library_category_sort_v1`).

**Not implemented (user deferred):** extension browse pin order, Mangayomi Server backend parity, dedicated sync toggles.

## Snapshot v4 (`mangayomi/mangayomi-sync.json`)

Always: manga, categories, chapters, tracks, extension settings, installed extensions (with `sourceCode`), saved searches, feeds (`feedOrder`), tombstones, library category sorts.

Optional: history, updates, settings (toggles). Settings export strips `downloadLocation` / `autoBackupLocation`.

## Key files

- `lib/utils/path_preferences.dart` — userdata path JSON
- `lib/services/sync/sync_snapshot.dart` — build snapshot
- `lib/services/sync/sync_merger.dart` — merge + apply
- `lib/services/sync/webdav_sync_backend.dart` — WebDAV orchestration
- `lib/services/sync/sync_tombstone.dart` — deletion propagation
- `lib/services/sync/library_category_sort_sync.dart` — Hive per-category sort
- `lib/services/sync/sync_trigger_service.dart` — auto metadata sync (30s debounce)

## Known limitations

- Large sync files with many extension binaries; first sync may be slow on pCloud.
- Cross-platform extension compatibility not guaranteed.
- Extension setting changes do not auto-trigger sync (install/feed/sort do).
- Mangayomi Server backend not updated.
- Tests run in CI only (no local Flutter on build host).

## Step 5 — Manual validation (NEXT)

- [ ] Portable rebuild keeps custom download path
- [ ] Sync progress works (no null-check error)
- [ ] Extension install on PC → sync → on phone without Install tap
- [ ] Uninstall/feed/filter delete propagates both ways
- [ ] Per-category library sort syncs
- [ ] Download paths stay device-specific after settings sync

## Completed steps

| Step | Done |
|------|------|
| 1 Path preferences + sync exclusion | Yes |
| 2 WebDAV favorite parse fix | Yes |
| 3 Extension settings sync | Yes |
| 4 Extensions/feeds/filters/tombstones | Yes |
| 4b Per-category library sort | Yes |
| 5 Device validation | **No** |
