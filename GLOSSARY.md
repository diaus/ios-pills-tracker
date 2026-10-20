# Pills Tracker

Helps a person see which pills they still have to take today and keep the app's picture of each blister in sync with the physical one.

## Language

### Medication

**Pill Type**:
A kind of medication the user takes, identified by its name. Defines the grid shape of its blisters.
_Avoid_: Medication, drug, medicine, pill kind

**Blister**:
A physical strip of pills of one Pill Type, laid out as a rectangular grid. A Pill Type has exactly one Current Blister at a time.
_Avoid_: Strip, pack, sheet

**Current Blister**:
The Blister of a Pill Type that the user is consuming right now. Replaced by starting a new Blister.
_Avoid_: Active blister, open blister

**Retired Blister**:
A former Current Blister that was replaced by Start New Blister. It is kept with its final grid state so its Intakes stay meaningful.
_Avoid_: Old blister, archived blister, deleted blister

**Position**:
One cell of a Blister's grid, addressed by row and column. A Position is either Present (pill still there) or Empty.
_Avoid_: Slot, cell, index

**Present / Empty**:
The two states of a Position. Present means the pill is physically in the Blister; Empty means it is not.
_Avoid_: Consumed, taken, available, missing

**Start New Blister**:
The act of retiring the Current Blister (allowed only when every Position is Empty) and replacing it with a fresh one where every Position is Present.
_Avoid_: Reset, refill, replace

**Sync Edit**:
Manually setting a Position to Present or Empty so the app matches reality. A Sync Edit is not an Intake and never affects today's progress. A Position with an Intake cannot be set Present by a Sync Edit; only Undo makes it Present again.
_Avoid_: Edit, toggle, manual consume

### Schedule

**Slot**:
One of the three parts of the day a pill can be prescribed for: Morning, Day, Evening. Slots are labels, not clock times.
_Avoid_: Time, period, dose time

**Prescription**:
The daily rule for a Pill Type: the non-empty set of Slots in which one pill is taken. A Pill Type has at most one Prescription.
_Avoid_: Schedule, plan, regimen, dosage

**Active / Paused**:
The two states of a Prescription. Only Active Prescriptions count toward today's progress and appear as Blister cards on the Home screen.
_Avoid_: Enabled/disabled, on/off

### Progress

**Intake**:
The record that one pill of a Pill Type was taken from a specific Position of a specific Blister for a specific Slot on a specific Day. Created only by Consume, never by Sync Edit.
_Avoid_: Consumption, dose, history entry

**Consume**:
The act of taking a Present pill from a Position for one of today's open Slots. It makes the Position Empty and creates an Intake.
_Avoid_: Take, mark, check off

**Undo**:
Reverting an Intake from the Current Blister, made on any Day: the Position becomes Present again and the Intake is removed, so its Slot is Open again on that Day. When a Position has several Intakes, Undo reverts the latest. Intakes from a Retired Blister cannot be undone.
_Avoid_: Revert, uncheck

**Day**:
A local calendar day. Progress ("taken today", "left today") is computed per Day and rolls over at local midnight.
_Avoid_: Date, today (as a stored value)

**Open Slot / Done Slot**:
For an Active Prescription on a given Day, a Slot is Done when an Intake exists for it and Open otherwise.
_Avoid_: Pending, remaining

**Completed**:
The state of an Active Prescription on a Day when none of its Slots are Open.
_Avoid_: Finished, all taken
