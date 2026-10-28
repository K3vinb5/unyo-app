---
name: flutter-desktop-automation
description: Drive and screenshot a Flutter desktop app (Linux, KDE/Wayland) as an agent — navigate screens, tap widgets, capture every screen WITHOUT stealing window focus or touching the user's mouse. Use whenever you need to test a Flutter desktop app's UI, capture screenshots of all screens/flows, verify a UI change visually, walk a user flow end-to-end, or build design reference material from a running app. Triggers on requests like "screenshot every screen", "test the app yourself", "walk through the app", "capture the UI for Figma/design mockups", or any visual QA of a Flutter Linux app.
---

# Flutter Desktop Automation (Linux / KDE Wayland)

Drive a Flutter desktop app like a user — tap, scroll, read the widget tree, capture
screens — while the human keeps using their computer. This method was built and
debugged on a real production Flutter app; follow it and you skip ~2 hours of
broken tools and dead ends.

## The method at a glance

Three channels, used together:

1. **flutter_driver** (in-app automation): real taps/scrolls resolved against the
   widget tree. No coordinate math, no vision guessing, no DPI bugs.
2. **Direct VM-service websocket calls**: the Dart MCP server's `flutter_driver`
   tool has serialization bugs (see Pitfalls) — calling `ext.flutter.driver`
   directly over the VM-service websocket bypasses them and unlocks nested
   finders and timeouts.
3. **KWin DBus window capture**: screenshots of the app window *by window ID*,
   without focusing it. The user never loses focus. flutter_driver's own
   `screenshot` command is broken on Linux desktop — do not use it.

Deliberately NOT used: OS-level mouse control (ydotool/xdotool). It steals the
user's cursor, and ydotool's absolute coordinates are broken on multi-monitor
Wayland anyway. Only consider it if the user is away from the machine and asks
for it.

## Hard rules (learned the painful way)

- **One app instance at a time, ever.** Flutter desktop apps commonly use Hive or
  other file-locked state. A second instance hits lock corruption. Before
  launching anything: `pkill -f "bundle/<app-binary-name>"`.
- **Never steal window focus.** The human may be typing in another window. All
  capture goes through the KWin script below (window ID based), never
  `spectacle -a`/`import -window root` after focusing the app.
- **Never ship the automation entrypoint.** It disables real keyboard input and
  must stay out of release builds. It lives in its own `lib/driver_main.dart`,
  referenced by nothing else.
- **Release builds can't be automated.** AOT strips the VM service. Debug or
  profile builds only. The UI renders identically, so screenshots are
  representative.
- **Prefer keys over coordinates over text.** Ask the user (or add yourself,
  hot-reloadable and invisible) for `ValueKey`s on important controls:
  `key: const ValueKey('menu-home')`. Text finders fail on truncated/ellipsized
  labels and localized apps; coordinates shift; keys are forever.

## Setup (once per app)

### 1. Automation entrypoint

Create `lib/driver_main.dart` in the app (template in `assets/driver_main.dart` —
it also registers custom `ext.unyo.*`-style helper extensions; rename the prefix
to the app). Minimal viable version:

```dart
// ignore: depend_on_referenced_packages -- dev-only automation entrypoint
import 'package:flutter_driver/driver_extension.dart';
import 'package:unyo/main.dart' as app;  // adjust package name

void main() {
  enableFlutterDriverExtension();  // BEFORE app.main() — it creates its own binding
  app.main();
}
```

Add the dev dependency: `flutter pub add dev:flutter_driver --sdk=flutter`
(or add `flutter_driver: sdk: flutter` under `dev_dependencies` in pubspec.yaml).

Launch: `flutter run -d linux -t lib/driver_main.dart` — or via the Dart MCP
server's `launch_app` tool with `target: "lib/driver_main.dart"` (note:
`launch_app` ignores extra CLI args, which is why the entrypoint file pattern is
required instead of `--dart-define`).

### 2. Dart MCP server (for hot_reload, launch_app, logs)

If the agent host supports MCP, register the official server:

```json
{ "mcp": { "dart": { "type": "local", "command": ["dart", "mcp-server"] } } }
```

Its useful tools: `launch_app`, `connect_dart_tooling_daemon`, `hot_reload`,
`hot_restart`, `get_app_logs` (source of the VM-service websocket URI),
`get_runtime_errors`. Its `flutter_driver` tool is partially broken — use the
direct-call script instead (below).

### 3. Helper scripts

Run them **in place from the skill's `scripts/` directory** (absolute path) — do
NOT copy them into `/tmp` or leave standing copies around (see "Where files
live"). All of them are idempotent and location-independent.

- `vm-call.sh <ext.method> '<params-json>'` — call any VM-service extension
  (`ext.flutter.driver` or your custom ones) with correct nested-finder
  serialization. Needs the VM-service WS URI (see next section), passed as
  `UNYO_VM_WS=ws://...`.
- `kwin-shot.py <window-handle> <out.png>` — focus-free window capture.
- `app-shot.sh <window-title-regex> <out.png>` — resolves the handle via
  `kdotool search --name` and captures (e.g. `'^Unyo$'`).
- `burst.sh <window-title-regex> <output-prefix> <count>` — rapid-fire
  `<count>` captures (~170ms apart) to catch transient loading/skeleton
  states right after a navigation tap.
- `ts-tail.py <file> <out>` — tail a log, prefix each arriving line with a
  wall-clock stamp; use it to date UI shots against fetch/log lines.

Requires: `websocat`, `kdotool`, `python3` + `python3-dbus`, ImageMagick 7
(`magick`; if only IM6 `convert` exists, adjust the script).

## Where files live (RAM vs disk)

`/tmp` is tmpfs on this machine — everything in it burns RAM and vanishes on
reboot. Treat it as scratch-only:

- **Proof/evidence** (screenshots, logs, DIAGNOSIS, drive scripts for a specific
  run): the workspace's `research/<wp>-<slug>-proof/` directory, laid out per
  `unyo-docs/conventions/research-layout.md`. Durable, indexed, never GC'd.
- **Per-run scratch** (bursts, raw frames you will triage): `~/.cache/unyo-drive/<run>/`
  or straight into the research dir if they are keepers.
- **`/tmp`**: only one-shot files that die with the command. Never leave standing
  helper scripts or evidence there — when a machine reboots the next session
  loses them silently and re-derives everything.

**Always clean up at the end of a drive**: kill the app instance, stop tails and
watchers, move keepers into the research dir, delete the scratch dir.

## Getting the VM-service websocket URI

After `flutter run` starts, the URI appears in its output
(`A Dart VM Service on Linux is available at: http://127.0.0.1:PORT/TOKEN=/`),
or via the Dart MCP `get_app_logs` — look for `app.debugPort` with a `wsUri`
like `ws://127.0.0.1:44503/-iojy6NZl20=/ws`. Set it in `vm-call.sh`.

The isolate ID changes on hot restart; the script re-resolves it each call via
`getVM` (first isolate).

## Daily driver commands

All go through `vm-call.sh ext.flutter.driver '<args>'`. Args are the
flutter_driver protocol; `finderType` + finder fields identify the target:

```bash
# Tap by ValueKey (most reliable)
vm-call.sh ext.flutter.driver '{"command":"tap","finderType":"ByValueKey","keyValueString":"menu-home","keyValueType":"String","timeout":"8000"}'

# Tap by exact visible text (fails on hints inside TextFields — hintText is NOT a Text widget)
vm-call.sh ext.flutter.driver '{"command":"tap","finderType":"ByText","text":"Anime List","timeout":"8000"}'

# Nested finders (this is what the MCP tool cannot serialize — pass them as JSON-ENCODED STRINGS)
vm-call.sh ext.flutter.driver '{"command":"tap","finderType":"Ancestor","of":"{\"finderType\":\"ByText\",\"text\":\"Kiwib5\"}","matching":"{\"finderType\":\"ByType\",\"type\":\"UserAvatar\"}","firstMatchOnly":"true","timeout":"8000"}'

# Tap the widget itself (center lands on its child, e.g. an InkWell circle above a label)
vm-call.sh ext.flutter.driver '{"command":"tap","finderType":"ByType","type":"AddUserAvatar","timeout":"8000"}'

# Scroll a list (dx/dy are stringified doubles; duration in MICROSECONDS as string)
vm-call.sh ext.flutter.driver '{"command":"scroll","finderType":"ByType","type":"ListView","dx":"0","dy":"-400","duration":"400000","frequency":"60","timeout":"8000"}'

# Check liveness / inspect a widget
vm-call.sh ext.flutter.driver '{"command":"get_health"}'
vm-call.sh ext.flutter.driver '{"command":"get_diagnostics_tree","finderType":"ByType","type":"MaterialApp","diagnosticsType":"widget","subtreeDepth":"3"}'
vm-call.sh ext.flutter.driver '{"command":"get_offset","finderType":"ByValueKey","keyValueString":"back-button","keyValueType":"String","offsetType":"center","timeout":"5000"}'
```

Notes:
- `timeout` is a **string of milliseconds**. Always include it (e.g. `"8000"`),
  or a missing finder hangs the command forever and can wedge the driver's
  serial command queue (only a hot restart unwedges it).
- A tap "succeeds" even when nothing happens — verify state changes with a
  screenshot after each action. Taps hit the *center* of the found widget; if a
  label's `InkWell` is on a sibling (e.g. the avatar above the text), tapping
  the text does nothing — tap the container instead.
- Ambiguous finders (N matches) error out; disambiguate with Ancestor/Descendant
  or add a ValueKey.
- Dismiss dialogs by tapping their `ModalBarrier` (`ByType ModalBarrier`).
- `PageBack` / `ByType BackButton` only work with Material back buttons; many
  apps use custom `IconButton`s — give them a shared `ValueKey('back-button')`.

## Capturing screens (focus-free)

```bash
app-shot.sh "^Unyo$" /path/to/05-anime-details.png
```

`kwin-shot.py` calls KWin's `org.kde.KWin.ScreenShot2.CaptureWindow` DBus method:
the window is captured by ID, in the background, focus untouched. The image
arrives as raw RGBX8888 and is converted to PNG with ImageMagick. The capture
includes ~45px of shadow margin on each side — subtract it if you need exact
content coordinates.

Verify the capture matches reality after navigation actions — read the PNG back
and look at it before deciding the next step. That screenshot → look → act loop
is the core of reliable automation.

### Coordinate mapping (when you need it)

- Window geometry: `kdotool getwindowgeometry <handle>` → logical position+size.
- KWin capture size = logical size + 90px (45px shadow each side).
- `get_offset` returns logical coords in the Flutter view; logical + window
  position = screen coords. (Only needed for OS-level input, which this skill
  avoids.)

## The custom extension pattern (escape hatch for everything)

The bundled `assets/driver_main.dart` registers `ext.<app>.tapAt`,
`ext.<app>.tapKey`, `ext.<app>.findKey` VM-service extensions inside the app.
They walk the element tree and inject real pointer events via `TestGesture` —
use them when driver finders fail entirely on a screen (this happened on
"details" screens of the reference app: every finder call hung forever while
`get_health` still responded; root cause unknown, possibly deep tree + live
animations). `tapAt` with x/y from a screenshot gives you a full
vision → coordinates → tap loop that always works.

Key implementation details if you adapt it: `TestGesture` needs
`dispatcher: (event) async => GestureBinding.instance.handlePointerEvent(event)`
— raw `PointerDownEvent/PointerUpEvent` injection does NOT trigger taps (the
gesture arena needs the full added/hover/down/up sequence).

## Pitfall catalogue (do not rediscover these)

- `enableFlutterDriverExtension()` **after** `WidgetsFlutterBinding.ensureInitialized()`
  crashes: "Binding is already initialized". Call it first in `main()`.
- Dart MCP `launch_app` silently ignores `args` — `--dart-define` flags never
  reach the app. Use a separate entrypoint file.
- Dart MCP `flutter_driver` tool: nested finder objects get serialized as Dart
  map literals (`{finderType: ByType...}`) and rejected; its `timeout` int param
  throws a cast error. Bypass with `vm-call.sh`.
- Driver command queue wedges after a command with no timeout; only
  `hot_restart` recovers it. Hot restart also invalidates the isolate ID
  (re-resolve) and resets navigation to the initial route (re-login).
- The automation entrypoint disables real keyboard input in the app — you cannot
  type into it manually while it runs.
- ydotool absolute positioning is broken on multi-monitor Wayland (clamps to
  screen 0). Don't fight it; use driver taps.
- `spectacle -a`/`import` capture whatever window is focused — usually the
  agent's terminal, not the app. Use the KWin script.
- Hot reload preserves navigation state; hot restart does not. Prefer reload.
- Stale CMake caches (`build/linux/**/CMakeCache.txt`) break builds after moving
  the project directory — delete the cache, not the bundle.
- Infinite animations (`AnimationController.repeat()`) do NOT break
  flutter_driver finders (verified experimentally), but if finders hang on one
  specific screen, suspect screen-specific causes and fall back to the custom
  extension's `tapAt`.
- The app does not auto-login: cold start lands on the "Who's Watching?" profile
  picker — tap the avatar before any logged-in flow.
- `flutter build linux --profile` driver bundles get NO JRE link (the CMake
  symlink is debug-only) — copy/symlink the custom JRE into
  `build/linux/x64/<mode>/bundle/` or the Aniyomi JVM fails at startup.
- `flutter_driver` scroll commands time out in profile runs — shrink the window
  (e.g. 1280×1200) and capture without scrolling instead.
- KWin `CaptureWindow` can freeze its buffer (observed ~8.5 min stale frames
  while the UI thread stayed alive) — if screenshots no longer match app
  state, restart the app; never cite a stale buffer as evidence.
- Performance numbers only from `--profile` runs. Show the frame-timing overlay
  with a transient `bool.fromEnvironment('PERF_OVERLAY')` toggle in the app
  entry — and revert it before any commit.
- Loading/skeleton states settle fast: navigate, then `burst.sh` immediately
  (frames ~170ms apart) and pair with `ts-tail.py` so each shot can be dated
  against the fetch/log lines.

## Workflow for "capture every screen"

1. Kill existing instances, launch `driver_main.dart`, connect, get WS URI.
2. Log in / land on the start screen; capture `01-<name>.png`.
3. For each target screen: navigate via ValueKey taps → `sleep 2-3` → capture →
   **read the PNG and confirm** before continuing.
4. Keep a manifest of filename → screen/route for the consumer of the shots.
5. Number files (`01-`, `02-`…) in flow order; they're design-reference assets,
   treat them as such.

## When the human is present vs away

Present: driver taps + KWin capture only (zero focus/mouse interference — this
is the whole point of the skill). Away and explicitly authorized: OS-level input
(via KDE Connect's FakeInput or ydotool on single-monitor X11) becomes an option
for things the driver can't reach, like system dialogs outside the app window.
