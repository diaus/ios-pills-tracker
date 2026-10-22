# Lock Screen widget

Status: implemented on feat/lock-screen-widget (awaiting the on-device Lock Screen checks in 04–06, then merge to main)

## Problem Statement

To see whether today's pills for a Pill Type are taken, the user has to unlock the phone and open the app. The answer should be on the Lock Screen at a glance.

## Solution

A 1×1 Lock Screen widget (`accessoryCircular`), configured with one Pill Type that has an Active Prescription. It shows the Pill Type's Abbreviation and one mark per prescribed Slot, filled when the Slot is Done for Today. Tapping it opens that Pill Type's Blister screen. To make "Today" match how people actually take evening pills, Today rolls over at 03:00 instead of midnight, in the app and the widget alike.

## Decisions

### Configuration

- Only the `accessoryCircular` family.
- The configuration parameter is a **Pill Type**. The picker lists only Pill Types with an Active Prescription, in Home order.
- When a widget is added, it auto-configures through `EntityQuery.defaultResult()`. It picks the first Active Pill Type, in Home order, that no placed widget is already configured for. If none is left, it stays unconfigured.
- If `defaultResult()` turns out not to save as a real configuration on iOS 18, an unconfigured widget shows the empty state.

### Appearance

- A small dimmed `pill` SF Symbol at the top right, in every state that shows a Pill Type.
- The Pill Type's **Abbreviation** in the middle, or the first two characters of its name when no Abbreviation is set. It's scaled to the largest size the free space allows, down to the smallest legible size, on at most 2 lines, then truncated.
- A row of small circles at the bottom, one per prescribed Slot (morning, day, evening order), filled when the Slot is Done for Today and hollow when it's Open.
- **Completed:** every circle filled, plus a checkmark at the end of the row, the same size as a circle.
- **Paused or removed Prescription:** "-/-/-" in place of the circles (always three dashes), and the whole widget dimmed. The configuration is kept.
- **Pill Type deleted:** treated as unconfigured.
- **Empty state** (unconfigured, or nothing to show): a large `pills` SF Symbol, with no small `pill` symbol.
- The widget is read-only. Consume needs a specific Position, so it stays in the app.

### Tap

- When the widget shows a Pill Type: open that Pill Type's Blister screen with Selected Day = Today, through `widgetURL` and `onOpenURL` to `AppRoute.blister(pillTypeID:)`. This follows TinyReminder's `WidgetTap` pattern.
- In the empty state: open Home and show an alert: "To choose a Pill Type for this widget, touch and hold the Lock Screen, tap Customize, then tap the widget." It has one OK button. iOS has no API to open a widget's configuration from the app.

### Today rolls over at 03:00 (ADR 0004)

- `Day.current` in Domain: if the local hour is before 3, Today is the previous calendar Day, otherwise the calendar Day. The offset is a fixed constant, with no test (daylight-saving nights may be an hour off).
- The app and the widget both use `Day.current`. Use cases still take `Day`.
- `DailyProgressModel` schedules a refresh of Today at the next 03:00, on top of scene-active and significant-time-change.
- Intakes already stored aren't migrated.

### Data

- New optional **Abbreviation** on Pill Type, with no length limit. Blank after trimming means not set. It's edited on the Add and Edit Pill Type screens. It needs a schema V3 and a migration.
- The SwiftData store moves into an App Group container that the app and the widget share (ADR 0003). On first launch, an existing store and its `-wal`/`-shm` files are moved from Application Support into the App Group before the container opens.
- The widget opens the store, loads the Pill Type and Today's Intakes, and builds `PillTypeProgress`. It checks `hasPrescription` and `prescriptionState` before reading `isCompleted`, which is also true without a Prescription.
- The widget timeline has an entry for now and one at the next 03:00.
- `WidgetCenter.shared.reloadAllTimelines()` runs after every repository save, where `ChangeNotifier` fires.

## Out of Scope

- Other widget families (`accessoryRectangular`, inline, Home Screen sizes).
- Consuming from the widget.
- A per-Pill Type icon.
- A configurable rollover hour.

## Issues

1. `01-today-rolls-over-at-3am.md`
2. `02-abbreviation.md`
3. `03-store-in-app-group.md`
4. `04-widget-extension.md` (blocked by 01, 02, 03)
5. `05-widget-tap.md` (blocked by 04)
6. `06-reload-widget-after-save.md` (blocked by 04)
