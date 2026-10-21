# 06: Reload the widget after every save

**What to build:** The widget can't observe the store, so the app tells WidgetKit to reload after every write: Consume, Undo, Sync Edit, Prescription changes (edit, pause, resume, remove), and Pill Type add, edit or delete (ADR 0003).

**Blocked by:** 04 Lock Screen widget extension

**Status:** ready-for-agent

- [x] `WidgetCenter.shared.reloadAllTimelines()` runs after every successful repository save, in the same place the `ChangeNotifier` signal fires, not in each screen
- [x] Domain and Data stay free of WidgetKit; the reload is injected or attached at the app's DI layer
- [ ] Checked on iPhone 16 (iOS 18.5): Consume, Undo, pausing and resuming the Prescription, and editing the Abbreviation each show up on the Lock Screen widget
- [x] `scripts/check.sh` passes and `build_sim` builds with zero warnings
  - Verified by the merger on `feat/lock-screen-widget` after merging ticket 05: `build_sim` compiles `Container+AutoRegister.swift` with zero warnings, `test_sim` passes 21 tests. On iPhone 16 (iOS 18.5), Consuming a Position on the Blister screen saves (10 → 9 pills left) and the app keeps running; the Lock Screen widget itself was not checked.
