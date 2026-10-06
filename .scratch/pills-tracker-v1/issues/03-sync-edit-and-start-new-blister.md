# 03: Sync Edit and Start New Blister

**What to build:** On the Blister screen the user keeps the grid in sync with reality: tapping an Empty Position offers "mark as present", tapping a Present Position offers "remove without prescription". When every Position is Empty a Start New Blister button appears, asks for confirmation, and replaces the grid with a fresh one while the old Blister is kept as Retired.

**Blocked by:** 02 Add a Pill Type and see its Current Blister

**Status:** resolved

- [x] Domain: SyncPosition use case sets a Position Present or Empty on the Current Blister and touches nothing else
- [x] Domain: StartNewBlister use case refuses with `blisterNotEmpty` when any Position is Present; otherwise marks the Current Blister Retired (keeping its final grid) and creates a new Current Blister with all Positions Present
- [x] Tapping any Position opens an action sheet; there is no edit-mode toggle
- [x] Start New Blister button is visible only when the grid is empty and requires confirmation
- [x] Retired Blisters persist in Data and are not shown in the UI
- [x] Domain tests with fake repositories: SyncPosition both directions; StartNewBlister refusal and success including the Retired Blister keeping its state
- [x] If a use case throws despite the UI guard, a plain alert is shown

## Comments

- 2026-10-06: Implemented on branch `feat/pills-tracker-v1` (commits f8dca62..70f5069). All acceptance boxes ticked; code review findings fixed in commits b85c251..70f5069. Verified: app build zero warnings, app tests 3, Domain tests 62, Data tests 31, all passing.
