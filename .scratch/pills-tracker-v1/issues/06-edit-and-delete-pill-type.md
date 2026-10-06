# 06: Edit and delete a Pill Type

**What to build:** From the Blister screen toolbar the user renames a Pill Type, changes its grid shape (only while the Current Blister is empty, taking effect on the next Start New Blister), or deletes it. Deleting removes its Prescription, Blisters and Intakes and returns the user to Home.

**Blocked by:** 05 Consume for today's Open Slot, daily progress, and Undo

**Status:** resolved

- [x] Blister screen toolbar "Pill Type" entry opens a sheet with name and grid shape; the shape fields are disabled with an explanation while the Current Blister has any Present Position
- [x] Renaming updates Home, the Pill Types list and the Blister screen title
- [x] A changed shape applies to the next Start New Blister, not to the empty Current Blister
- [x] Delete asks for confirmation, cascades Prescription, Blisters and Intakes via SwiftData delete rules, and pops to Home
- [x] Domain validation: shape change refused when the Current Blister is not empty
- [x] Data test: deleting a Pill Type removes its Prescription, all its Blisters and all its Intakes

## Comments

- 2026-10-06: Implemented on branch `feat/pills-tracker-v1` (commits f8dca62..70f5069). All acceptance boxes ticked; code review findings fixed in commits b85c251..70f5069. Verified: app build zero warnings, app tests 3, Domain tests 62, Data tests 31, all passing.
