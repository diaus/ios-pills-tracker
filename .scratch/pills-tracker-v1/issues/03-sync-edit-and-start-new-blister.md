# 03: Sync Edit and Start New Blister

**What to build:** On the Blister screen the user keeps the grid in sync with reality: tapping an Empty Position offers "mark as present", tapping a Present Position offers "remove without prescription". When every Position is Empty a Start New Blister button appears, asks for confirmation, and replaces the grid with a fresh one while the old Blister is kept as Retired.

**Blocked by:** 02 Add a Pill Type and see its Current Blister

**Status:** ready-for-agent

- [x] Domain: SyncPosition use case sets a Position Present or Empty on the Current Blister and touches nothing else
- [x] Domain: StartNewBlister use case refuses with `blisterNotEmpty` when any Position is Present; otherwise marks the Current Blister Retired (keeping its final grid) and creates a new Current Blister with all Positions Present
- [x] Tapping any Position opens an action sheet; there is no edit-mode toggle
- [x] Start New Blister button is visible only when the grid is empty and requires confirmation
- [x] Retired Blisters persist in Data and are not shown in the UI
- [x] Domain tests with fake repositories: SyncPosition both directions; StartNewBlister refusal and success including the Retired Blister keeping its state
- [x] If a use case throws despite the UI guard, a plain alert is shown
