---
status: accepted
---

# The widget reload is a per-save hook, not a listener on the change stream

The widget learns about a write only when the app reloads its timelines (ADR 0003). We decided that the repository runs an injected `afterStoreSave` hook after every successful save, and the app wires `WidgetCenter.shared.reloadAllTimelines()` into it through Factory's `AutoRegistering`. Data stays free of WidgetKit. The reload must happen on every save, whoever is running at the time. The in-process `ChangeNotifier` stream can't promise that: it reaches only current subscribers and merges bursts. So the two stay separate, even though both fire right after a save.

## Considered Options

- **Drop the hook and reload from a listener on `ChangeNotifier.changes`**, run from the window's `.task`, from `App.init`, or from `DailyProgressModel.run()`. Rejected (architecture review, 22 Oct 2026): it removes an init parameter and a registration, but the widget would then be reloaded only while a listener is alive. A write made with no window, such as a future background launch for a notification action, would never reach the widget. The hook's tests (every successful write runs it once, a failed one never does) would turn into an untested loop in the app. Firing later on the main actor doesn't matter: iOS lets only the first foreground reload through and holds the rest until the app goes to the background.
