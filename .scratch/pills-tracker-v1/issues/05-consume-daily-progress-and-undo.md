# 05: Consume for today's Open Slot, daily progress, and Undo

**What to build:** Tapping a Present Position lists today's Open Slots (plus the Sync Edit option); choosing one empties the Position and marks the Slot Done. Home and Blister chips show Done/Open, a Completed state when nothing is Open, and a low-stock warning when Present pills are fewer than Open Slots. Tapping a Done chip offers Undo when the Intake is from today and the Current Blister, restoring the exact Position. "Today" rolls at local midnight and is recomputed when the app becomes active or the clock changes significantly.

**Blocked by:** 03 Sync Edit and Start New Blister, 04 Prescriptions and Home cards

**Status:** resolved

- [x] Domain: Day value type (year, month, day; Comparable, Hashable, Sendable; constructible from Date and Calendar); use cases take Day as a parameter and never read a clock (ADR 0001)
- [x] Domain: Intake (id, pill type id, blister id, position, slot, day, instant); IntakeRepository protocol (fetch for a Day optionally per Pill Type, create, delete)
- [x] Domain: Consume use case with errors `positionEmpty`, `slotNotOpen`, `noActivePrescription`; sets the Position Empty and creates an Intake for the given Day
- [x] Domain: Undo use case with error `undoNotAllowed` when the Intake's Day differs or its Blister is Retired; restores the Position and deletes the Intake
- [x] Domain: DailyProgress use case returning, per Pill Type with a Prescription: Prescription state, Done/Open per current Slot derived from that Day's Intakes intersected with current Slots, Completed flag, Present count, low-stock flag
- [x] Data: Intake model keyed on Pill Type; Day stored explicitly, never derived from the instant; Intakes survive Start New Blister
- [x] Present-pill sheet lists today's Open Slots plus "remove without prescription"; when no Slots are Open only the Sync Edit option remains; Empty-pill taps are refused
- [x] Slot chips on Home and Blister show Done/Open; Completed state and low-stock warning render on Home cards
- [x] Tapping a Done chip offers Undo only when allowed
- [x] View models compute "today" themselves and recompute on scene-active and the significant-time-change notification; Home reloads via the change stream after Consume or Undo
- [x] Domain tests: Consume happy path and each error; Undo allowed vs refused (other Day, Retired Blister); DailyProgress covering Done/Open, Completed, low-stock, Slot removed mid-day drops out, Slot added is Open, Paused excluded, Pill Type without Prescription excluded
- [x] Data tests: Intake round-trips with explicit Day; Intakes remain after a Blister is Retired

## Comments

- 2026-10-06: Implemented on branch `feat/pills-tracker-v1` (commits f8dca62..70f5069). All acceptance boxes ticked; code review findings fixed in commits b85c251..70f5069. Verified: app build zero warnings, app tests 3, Domain tests 62, Data tests 31, all passing.
