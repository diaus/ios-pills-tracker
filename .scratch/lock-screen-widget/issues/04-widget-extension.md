# 04: Lock Screen widget extension

**What to build:** A widget extension with one `accessoryCircular` widget, configured with a Pill Type that has an Active Prescription. It shows the Abbreviation and today's Slots as filled or hollow circles, and covers every state in the spec (Completed, Paused or removed Prescription, empty state). New widgets auto-configure to the first Pill Type not already on the Lock Screen. See `spec.md` sections Configuration and Appearance.

**Blocked by:** 01 Today rolls over at 03:00, 02 Abbreviation, 03 Store moves into the App Group

**Status:** ready-for-agent

- [ ] New widget extension target sharing the App Group, deployment target iOS 18, linking Domain and Data
- [ ] `AppIntentConfiguration` with a Pill Type parameter backed by an `AppEntity` and `EntityQuery`. Suggested results are Pill Types with an Active Prescription, in Home order.
- [ ] `EntityQuery.defaultResult()` returns the first Active Pill Type not already configured in a placed widget (`WidgetCenter.shared.currentConfigurations()`), or nil if none is left. If it turns out not to save as a real configuration on iOS 18, an unconfigured widget shows the empty state; note the finding in Comments.
- [ ] Timeline: an entry for now and one at the next 03:00, computed with `Day.current` logic for that moment; progress built from the store with `PillTypeProgress`
- [ ] Shows a Pill Type: small dimmed `pill` symbol at the top right; Abbreviation (or first two characters of the name) in the middle, scaled to the largest size that fits, at most 2 lines, then truncated; a row of circles at the bottom, one per prescribed Slot, filled when Done
- [ ] Completed: every circle filled, plus a checkmark of the same size at the end of the row
- [ ] Paused or removed Prescription: "-/-/-" instead of the circles, whole widget dimmed (checks `hasPrescription`/`prescriptionState` before `isCompleted`)
- [ ] Pill Type deleted, or unconfigured: large `pills` symbol, no small `pill` symbol
- [ ] Renders in tinted and full-color Lock Screen modes (`AccessoryWidgetBackground`)
- [ ] Xcode previews for each state
- [ ] Checked on iPhone 16 (iOS 18.5): add the widget to the Lock Screen, it auto-configures, the picker lists only Active Pill Types, and Consume in the app then fills a circle
- [ ] `scripts/check.sh` passes and `build_sim` builds both targets with zero warnings
