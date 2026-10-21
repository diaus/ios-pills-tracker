# 06: Reload the widget after every save

**What to build:** The widget can't observe the store, so the app tells WidgetKit to reload after every write: Consume, Undo, Sync Edit, Prescription changes (edit, pause, resume, remove), and Pill Type add, edit or delete (ADR 0003).

**Blocked by:** 04 Lock Screen widget extension

**Status:** ready-for-agent

- [ ] `WidgetCenter.shared.reloadAllTimelines()` runs after every successful repository save, in the same place the `ChangeNotifier` signal fires, not in each screen
- [ ] Domain and Data stay free of WidgetKit; the reload is injected or attached at the app's DI layer
- [ ] Checked on iPhone 16 (iOS 18.5): Consume, Undo, pausing and resuming the Prescription, and editing the Abbreviation each show up on the Lock Screen widget
- [ ] `scripts/check.sh` passes and `build_sim` builds with zero warnings
