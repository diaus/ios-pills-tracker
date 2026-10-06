# 04: Prescriptions and Home cards

**What to build:** From the Blister screen toolbar the user creates a Prescription by picking any non-empty subset of Morning, Day, Evening, and can later edit the Slots, pause, resume, or delete it. Home shows a card per Active Prescription (name, mini grid, three Slot chips showing Open or not prescribed) ordered by Pill Type creation date, plus a Paused section. Pill Types without a Prescription appear only in the Pill Types list.

**Blocked by:** 02 Add a Pill Type and see its Current Blister

**Status:** ready-for-agent

- [x] Domain: Prescription (id, pill type id, non-empty set of Slots, Active/Paused) owned by the Pill Type aggregate; Slot enum Morning, Day, Evening; empty Slot set rejected in Domain
- [x] Data: Prescription model related to Pill Type; deleting a Prescription leaves the Pill Type and its Blisters intact
- [x] Blister screen toolbar "Prescription" entry: create when none exists; otherwise edit Slots, pause, resume, delete
- [x] Home replaces the empty state with cards for Active Prescriptions, ordered by Pill Type creation date; each card shows name, a mini rendering of the Current Blister grid, and three chips (Open or not prescribed; Done comes in ticket 05)
- [x] Home shows a Paused section listing Paused Prescriptions; tapping a card or a Paused row opens the Blister screen
- [x] Home still links to the Pill Types list; Home shows the empty state only when no Pill Types exist
- [x] Data tests: Prescription round-trips with its Pill Type; deleting a Prescription keeps the Pill Type
