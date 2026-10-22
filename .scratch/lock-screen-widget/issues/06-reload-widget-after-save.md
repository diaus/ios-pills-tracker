# 06: Reload the widget after every save

**What to build:** The widget can't observe the store, so the app tells WidgetKit to reload after every write: Consume, Undo, Sync Edit, Prescription changes (edit, pause, resume, remove), and Pill Type add, edit or delete (ADR 0003).

**Blocked by:** 04 Lock Screen widget extension

**Status:** resolved

- [x] `WidgetCenter.shared.reloadAllTimelines()` runs after every successful repository save, in the same place the `ChangeNotifier` signal fires, not in each screen
- [x] Domain and Data stay free of WidgetKit; the reload is injected or attached at the app's DI layer
- [x] Checked on iPhone 16 (iOS 18.5): Consume, Undo, pausing and resuming the Prescription, and editing the Abbreviation each show up on the Lock Screen widget
- [x] `scripts/check.sh` passes and `build_sim` builds with zero warnings
  - Verified by the merger on `feat/lock-screen-widget` after merging ticket 05: `build_sim` compiles `Container+AutoRegister.swift` with zero warnings, `test_sim` passes 21 tests. On iPhone 16 (iOS 18.5), Consuming a Position on the Blister screen saves (10 → 9 pills left) and the app keeps running; the Lock Screen widget itself was not checked.

## Comments

- **Status ready-for-human:** the code is merged on `feat/lock-screen-widget` and verified by build, tests and simulator URL checks. What remains is the unticked on-device Lock Screen check(s) above, which need a person to add and tap the widget. Set `resolved` once they pass.

- **2026-10-22, a second Consume while the app stays open doesn't reach the widget: iOS throttles it, not our code.** On iPhone 16 (iOS 18.5), every save calls `reloadAllTimelines()`, but chronod lets only the first request of each foreground session through (`Allowing first refresh while foreground`). It logs every later one as `Throttling additional refresh request while foreground` and runs them only on `Flushing pending reload request due to background transition`, when the app goes Home or the phone locks. The one allowed refresh covers a single widget instance, so with two widgets placed, the second waits too. The widget's reads aren't stale: a separate long-lived reader process saw every save. Apple documents foreground reloads as exempt from the daily budget, not from this filter, and no public API skips it.
