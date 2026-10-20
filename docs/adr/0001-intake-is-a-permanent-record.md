---
status: accepted
---

# Intake is a permanent record keyed on Pill Type

v1 shows no history, but "taken today / left today" still needs a record of each Consume. We decided that an Intake is a permanent row (never purged, never deleted by Start New Blister) that references the Pill Type (not the Prescription), the Blister and Position it came from, the Slot, the local calendar Day stored explicitly, and the UTC instant. Use cases take `Day` as an explicit parameter instead of reading a clock.

## Considered Options

- **Per-day scratch state on the Prescription, reset at midnight.** Rejected: throws away data v2 history needs, and ties progress to the Prescription so deleting/re-creating one mid-day would lose today's Done Slots.
- **Recompute Day from the timestamp at read time.** Rejected: a timezone change would move past Intakes to a different Day; the Day the user experienced is the truth.
- **Clock injection (`DateProvider`) in use cases.** Rejected as over-engineering: passing `Day` in makes editing past days trivial later and keeps tests deterministic without a fake clock.

## Consequences

- Blisters are kept as Retired records after replacement so old Intakes stay resolvable; Undo is limited to Intakes on the Current Blister.
- Deleting a Prescription leaves Intakes untouched; deleting a Pill Type cascades them.
- One app-level model (`DailyProgressModel`), not the Domain, decides what "today" is and re-evaluates it on scene-active and significant-time-change; screens read the Day from it and pass it to the use cases.

## Amendment: Undo on any Day of the Current Blister

Undo was first limited to today's Intakes. It now accepts any Intake on the Current Blister, from any Day, reached by tapping its Empty Position on the grid. A wrong Consume noticed the next morning could otherwise only be "fixed" with a Sync Edit, which left a false Intake behind. The cost is that Undo can reopen a Slot on a past Day; that is accepted because the Intake it removes was wrong. To make Undo the only way back, a Sync Edit can no longer set Present a Position that has an Intake. Retired Blisters stay locked.

## Amendment: Consume on a past Selected Day

The Blister screen can move its Selected Day to any earlier Day and Consume for that Day's Open Slots. There is no lower bound, not even the Pill Type's creation: someone who has been on a Prescription for a while before installing the app can backfill those Intakes. With no Prescription history, a past Day shows the current Prescription's Slots.

`Consume` accepts any `Day`, including a future one. That is deliberate: the Selected Day never moves past today, and keeping the check out of Domain avoids passing "today" into the use case only to guard it.
