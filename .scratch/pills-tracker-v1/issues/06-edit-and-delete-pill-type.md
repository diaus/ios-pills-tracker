# 06: Edit and delete a Pill Type

**What to build:** From the Blister screen toolbar the user renames a Pill Type, changes its grid shape (only while the Current Blister is empty, taking effect on the next Start New Blister), or deletes it. Deleting removes its Prescription, Blisters and Intakes and returns the user to Home.

**Blocked by:** 05 Consume for today's Open Slot, daily progress, and Undo

**Status:** ready-for-agent

- [ ] Blister screen toolbar "Pill Type" entry opens a sheet with name and grid shape; the shape fields are disabled with an explanation while the Current Blister has any Present Position
- [ ] Renaming updates Home, the Pill Types list and the Blister screen title
- [ ] A changed shape applies to the next Start New Blister, not to the empty Current Blister
- [ ] Delete asks for confirmation, cascades Prescription, Blisters and Intakes via SwiftData delete rules, and pops to Home
- [ ] Domain validation: shape change refused when the Current Blister is not empty
- [ ] Data test: deleting a Pill Type removes its Prescription, all its Blisters and all its Intakes
