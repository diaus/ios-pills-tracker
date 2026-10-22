# 01: Give the widget's timeline one testable interface

**What to build:** Move the entry-building out of `PillTypeTimelineProvider`'s private methods into `PillTypeWidgetTimeline` (in `PillsTrackerWidget/Timeline/`), a value holding a store-opening closure `() throws -> (any PillTypeRepository)?` (default `WidgetStore.repository`, called once per timeline or snapshot). It exposes `entries(for pillTypeID: UUID?, at moments: [Date])` and `timeline(for pillTypeID: UUID?, now: Date) -> Timeline<PillTypeWidgetEntry>`, with the retry-vs-atEnd policy inside. Progress comes from the `DailyProgress` use case filtered by id, not a private copy of it. The provider becomes three delegations. The new file joins `PillsTrackerTests`, as `PillTypeWidgetContent.swift` does.

**Status:** resolved

- [x] `PillTypeWidgetTimelineTests` in `PillsTrackerTests`, over an in-memory `PillTypeRepositoryLive`: nil Pill Type → every entry `.noPillType` with the `.configure` tap; opener returns nil (no store yet) → `.noPillType`; opener throws → `.unreadable`, tap still `.blister`, policy `.after(15 min)`; readable store with one Intake today → the entry at `now` has that Slot Done, the entry at the next rollover has every Slot Open, policy `.atEnd`; a deleted Pill Type → `.noPillType` with a readable store
- [x] The provider's private `progress(of:on:in:)` is gone; the widget's progress is `DailyProgress(day:)` filtered by id (ADR 0003)
- [x] The store is opened once per `timeline`/`snapshot` call, not once per entry (keeps commit e996114)
- [x] `scripts/check.sh` passes, `build_sim` builds with zero warnings, `test_sim` passes

## Comments

- **Resolved:** `test_sim` 28 passed (6 new in `PillTypeWidgetTimelineTests`), `build_sim` zero warnings, `scripts/check.sh` OK. No UI changed; the Lock Screen widget itself stays on ticket `lock-screen-widget/06`'s on-device check.
