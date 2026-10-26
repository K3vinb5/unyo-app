# Flutter 3.38.1 → 3.47.7 Migration Plan

Overnight migration executed 2026-10-21/22. This file is the checklist of record.
Proof of success lived in `../research/flutter-3.47-migration/` (retired 2026-10-26
with the research/ cleanup; the report's conclusions are recorded in this file).

## Versions

| | From | To |
|---|---|---|
| Flutter | 3.38.1 | 3.47.7 (stable, 2026-10-08) |
| Dart | 3.10.0 | 3.13.5 |

FVM pin (`.fvmrc`) must be bumped in **unyo-app** and **unyo-lib** together
(unyo-app consumes unyo-lib via path dep). unyo-p2p stays pinned separately.

## Main objectives

1. **Baseline** — capture current-state proof before touching anything:
   - [x] `flutter test` passes on 3.38.1 — N/A, no test files exist in `test/`
   - [x] Linux debug build works on 3.38.1 ✓
   - [x] analyze baseline: 62 issues, 0 errors (`baseline/analyze-3.38.1.log`)
   - [x] Reference screenshots already exist in `unyo-design/screens/` (Oct 21)
2. **SDK bump** — DONE: `fvm use 3.47.7 --force` in unyo-app + unyo-lib
   (`--force` needed because pub resolution fails until deps are upgraded).
   Existing pubspec env constraints (`sdk: ">=3.10.0 <4.0.0"`,
   `flutter: ">=3.38.1"`) already permit 3.47.7 — left unchanged.
3. **Dependencies** — DONE:
   - unyo-lib: `pub upgrade` clean; **jni/jnigen kept at 0.14.2** — analyzes
     clean on Dart 3.13, no jmodels regeneration needed.
   - unyo-app: `pub upgrade --major-versions` — 122 changed; notable:
     dynamic_color 2.1.0, material_color_utilities 0.13.0, fvp ^0.39.1,
     video_player ^2.14.1, bloc_lint ^0.4.1, win32 6.4.0, uuid 4.6.0.
     freezed held at 3.x intentionally.
   - **NEW TRAP**: `cast` 2.1.0 (stale upstream) breaks against bonsoir 7.x
     (`BonsoirDiscoveryEventType` renamed) → `dependency_overrides:
     bonsoir: 5.1.11` added to pubspec.
   - **NEW TRAP**: `dart fix`'s `missing_dependency` fix moves
     `flutter_test`/`flutter_driver` into main `dependencies:` as `: any`,
     breaking pub resolution — must be moved back under `dev_dependencies:`
     with `sdk: flutter` after every dart fix run.
4. **Mechanical fixes** — DONE: `dart fix --apply` (9 fixes), analyze
   0 errors / 58 issues (baseline was 62 — improvement).
   - **fvp 0.39 API change**: `mdk.Player.onMediaStatus(cb)` callback setter
     → `Stream<({oldValue, newValue})>` getter. Fixed in
     `lib/core/services/video/video_service.dart` (listen + cancel in dispose).
5. **material_ui opt-in** — DONE: `flutter pub add material_ui` (^1.8.0) then
   `dart fix --apply --code=migrate_design_widgets` (111 files, 111 fixes).
   NOTE: running the fix without material_ui in pubspec first crashes the
   analysis server (known upstream bug).
6. **Regenerate code** — DONE: build_runner (132 outputs, freezed/json/hive_ce/
   auto_route), 0 errors.
7. **Build matrix** — DONE for Linux: debug ✓ release ✓ (release bundle verified
   at runtime). JRE symlink rule intact in debug; release JRE re-copied via
   installJRERelease.sh after rm -rf. macOS/Windows NOT verifiable from this
   machine — runner files untouched, must be built there before release.
8. **Full runtime verification** — ALL PASSED (see REPORT.md + screenshots):
   - [x] App launches, account selection + login work
   - [x] Home/Anime/Manga/Extensions/Settings/AdvancedSearch/Theme screens — match baseline
   - [x] Extension loading + JNI isolate path (search, episodes, videos via JVM)
   - [x] Anime details + Torrentio extension selection
   - [x] **Video opens without crash** (Impeller OpenGLESSDF + merged threads)
   - [x] **Scrubbing to ~50% and ~90% — no crash**
   - [x] Progress reporting 30s tick fired; episode marked watched
   - [x] Theme settings render (dynamic_color 2.1.0)
   - [x] No Hive lock issues across multiple restarts
   - [x] Release binary smoke test passed
9. **Proof** — DONE: the migration proof bundle (REPORT.md, baseline/, logs/,
   screens/ 16 shots, video/ 5 shots) was retired in the 2026-10-26 research/
   cleanup; the report contents summarized above.

## Known traps (from project memory)

- Never run two app instances — Hive DB lock. `pkill -f "bundle/unyo"` first.
- `linux/CMakeLists.txt` has a Debug-only JRE symlink install rule — preserve it.
- flutter_driver still ships in 3.47 (automation survives); entrypoint is
  `lib/driver_main.dart`, never ship it in release.
- If driver finders hang on details screens (known unresolved bug), use the
  custom `ext.unyo.tapAt` VM extension with coordinates from a screenshot.
- Video player needs the Torrentio Anime extension selected (others broken).
- After touching unyo-lib deps, unyo-app must re-resolve (path dep).

## Commit conventions

`rewrite:` prefix for the migration commits, `fix:` for regression fixes,
lowercase imperative. Include regenerated `*.g.dart` / `lib/generated/json`
in the same commit as the source change. Do NOT commit without user
confirmation — stage changes and leave commits for review unless told
otherwise. (User authorized overnight autonomous work; still: no git
mutations without explicit ask — leave working tree changes.)
