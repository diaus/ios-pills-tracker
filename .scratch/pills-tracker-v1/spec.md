# Pills Tracker v1

Status: implemented on feat/pills-tracker-v1 (awaiting merge to main)

## Problem Statement

People who take several medications lose track of which pills they have already taken today and which are still due. Pills come in blisters, so the physical strip is the natural source of truth, but a glance at a half-empty strip does not tell you whether the evening dose is still outstanding. Existing reminder apps model "doses" abstractly and never match what is actually in the strip, so users stop trusting them.

## Solution

An iPhone app where each medication (Pill Type) is shown as its Current Blister: a grid that mirrors the real strip, position by position. The user attaches a daily Prescription (which of Morning / Day / Evening they take a pill in). The Home screen shows every Active Prescription as a card with the mini grid and the three Slots as Done / Open chips, so "what is left today" is readable at a glance. Tapping a card opens the Blister screen where the user Consumes a pill for an Open Slot by tapping the actual Position they popped, Undoes a mistake, or Sync Edits positions to match reality. Every Consume is stored as a permanent Intake so a history UI can be added in v2 without a data migration.

## User Stories

### Pill Types and Blisters

1. As a user, I want to add a Pill Type with a name and the blister grid shape (rows × columns), so that the app can show a grid matching my real strip.
2. As a user, I want the first Current Blister to be created automatically with every Position Present when I add a Pill Type, so that I can start using it immediately.
3. As a user, I want to rename a Pill Type, so that I can fix typos or use the name I actually say.
4. As a user, I want to change a Pill Type's grid shape only while its Current Blister is empty, so that the app never has to guess what happened to pills in a resized grid.
5. As a user, I want to delete a Pill Type together with its Prescription, Blisters and Intakes, so that medications I stopped taking disappear completely.
6. As a user, I want to see the Current Blister as a grid where Present and Empty Positions look clearly different, so that I can compare it visually with the strip in my hand.
7. As a user, I want to tap an Empty Position and mark it Present (Sync Edit), so that the app matches reality after I miscounted.
8. As a user, I want to tap a Present Position and remove it without a Prescription (Sync Edit), so that pills I dropped, lost or gave away do not count as taken.
9. As a user, I want Sync Edits to never affect today's progress, so that fixing the picture does not pretend I took a dose.
10. As a user, I want a Start New Blister action that appears only when every Position is Empty and asks for confirmation, so that I cannot accidentally reset a half-full strip.
11. As a user, I want Start New Blister to give me a fresh grid with every Position Present, so that I do not have to tap every cell.
12. As a user, I want my previous Intakes to remain after Start New Blister, so that history stays intact for the future.

### Prescriptions

13. As a user, I want to add a Prescription for a Pill Type by choosing any non-empty subset of Morning, Day, Evening, so that the app knows when I take it.
14. As a user, I want at most one Prescription per Pill Type, so that there is one clear answer to "what do I take today".
15. As a user, I want to edit the Slots of a Prescription, so that I can follow a changed regimen.
16. As a user, I want a Slot I removed from the Prescription to disappear from today's Done and Open chips, so that the card reflects the current regimen.
17. As a user, I want a Slot I added to the Prescription to show as Open for today, so that I do not forget the new dose.
18. As a user, I want to pause a Prescription, so that a medication I am temporarily off stops cluttering my daily list.
19. As a user, I want to resume a Paused Prescription with one tap, so that restarting is painless.
20. As a user, I want to delete a Prescription while keeping the Pill Type, its Blister and its Intakes, so that I can re-add it later without losing data.
21. As a user, I want today's Done Slots to survive deleting and re-creating a Prescription the same day, so that I am not told to take a dose twice.

### Consuming and progress

22. As a user, I want to tap a Present Position and pick one of today's Open Slots, so that the pill I actually popped is recorded for that dose.
23. As a user, I want the chosen Position to become Empty and the Slot to become Done immediately, so that the grid and the chips stay consistent.
24. As a user, I want to be refused when I try to Consume from an Empty Position, so that I cannot record a pill that is not there.
25. As a user, I want the Consume sheet to offer only the Sync Edit option when no Open Slots are left today, so that extra pills are not attributed to a Prescription.
26. As a user, I want to Undo an Intake made today from the Current Blister by tapping its Done chip, so that a wrong tap is reversible.
27. As a user, I want Undo to restore the pill at the exact Position it was taken from, so that the grid returns to the real state.
28. As a user, I want Undo to be unavailable for Intakes from a Retired Blister or from an earlier Day, so that I cannot corrupt data I can no longer verify against the strip.
29. As a user, I want "today" to roll over at local midnight, so that every morning starts with all Slots Open.
30. As a user, I want the app to recompute "today" when it returns to the foreground or the system clock changes significantly, so that a screen left open overnight is not stale.
31. As a user, I want the Day of an Intake to be the local calendar day at the moment I took it, so that travelling across timezones does not move my doses to another day.

### Home screen

32. As a user, I want the Home screen to show one card per Active Prescription, so that I see only what matters today.
33. As a user, I want each card to show the Pill Type name, a mini rendering of the Current Blister grid, and the three Slots as chips (Done / Open / not prescribed), so that I can see progress without opening anything.
34. As a user, I want a card to show a Completed state when no Slot is Open today, so that finished medications are visibly done.
35. As a user, I want a warning on a card when the Current Blister has fewer Present pills than Open Slots today, so that I know to get a new strip before I run out.
36. As a user, I want cards ordered by Pill Type creation date, so that the order is stable and predictable.
37. As a user, I want a Paused section under the cards listing Paused Prescriptions, so that resuming is one tap away.
38. As a user, I want tapping a card or a Paused row to open the Blister screen, so that acting on a medication is one tap from Home.
39. As a user, I want a "+" on Home to add a Pill Type, so that onboarding a new medication is fast.
40. As a user, I want a Pill Types list screen that shows all Pill Types including those without a Prescription, so that nothing is unreachable.
41. As a user, I want an empty state on Home when I have no Pill Types, so that I know what to do first.
42. As a user, I want the Home screen to reflect a Consume or Undo I just made on the Blister screen without manual refresh, so that the two screens never disagree.

### Blister screen

43. As a user, I want the Blister screen to show the full grid, the Slot chips for today, and toolbar entries for editing the Prescription and the Pill Type, so that every action for one medication lives in one place.
44. As a user, I want every tap on a Position to open a small sheet of actions rather than switching into an edit mode, so that I never wonder which mode I am in.
45. As a user, I want a plain alert if an action is refused by a rule the UI failed to prevent, so that silent failures do not happen.

### Quality

46. As a user, I want my data to stay on the device with no account or sync, so that my medication list is private.
47. As a user, I want the app's text to be in English and ready for other languages later, so that localisation is a data change, not a rewrite.

## Implementation Decisions

### Architecture

- Clean Architecture with the dependency rule enforced by the compiler through local Swift packages. Two packages: **Domain** and **Data**. Presentation (SwiftUI views and view models) and composition live in the app target.
- Domain is framework-free: Sendable value types for entities, repository protocols with async methods, use cases with plain init injection, typed domain errors. No Factory, no SwiftData, no Foundation beyond value types.
- Data is the only module that imports SwiftData. It holds the SwiftData models, a `VersionedSchema` from day one, mapping to and from Domain values, repository implementations built on `@ModelActor`, and a "data changed" `AsyncStream` that view models subscribe to in order to reload.
- Dependency injection uses hmlongco/Factory. Data extends `Container` to register its repository implementations. The app target extends `Container` to register use cases and view models. Domain has no registrations, so no placeholder factories exist that could crash when forgotten.
- Swift 6 language mode with strict concurrency in both packages and the app target. View models are `@MainActor @Observable`. Minimum deployment target is iOS 18 (the template project currently says iOS 27 and must be lowered).
- The template UITest target is deleted. Strings live in a String Catalog, English only.
- Storage is local only. No CloudKit.

### Domain model

- **Pill Type**: identity, name (required, non-empty), grid shape (rows and columns each 1…10), creation timestamp. Owns at most one Prescription and one or more Blisters, exactly one of which is Current.
- **Blister**: identity, owning Pill Type, state (Current or Retired), and the set of Present Positions. Positions are addressed zero-based as (row, column) in code; nothing user-facing shows an index.
- **Prescription**: identity, owning Pill Type, non-empty set of Slots, state (Active or Paused). Daily only.
- **Slot**: an enum of Morning, Day, Evening. Labels, not clock times.
- **Day**: a Domain value type of year, month, day. Comparable, Hashable, Sendable, constructible from a `Date` plus calendar. The view model decides what "today" is and recomputes on scene-active and on the system significant-time-change notification. Use cases receive `Day` as a parameter and never read a clock (see ADR 0001).
- **Intake**: identity, Pill Type id, Blister id, Position, Slot, Day stored explicitly, and the UTC instant. Permanent. Created only by Consume. Never purged. Keyed on Pill Type, not Prescription.
- Deleting a Pill Type cascades its Prescription, Blisters and Intakes via SwiftData relationship delete rules. Deleting a Prescription touches nothing else.

### Use cases (Domain)

- Consume(pillTypeID, position, slot, day): requires the Position Present on the Current Blister and the Slot Open on that Day for the Active Prescription; sets the Position Empty and creates an Intake. Errors: `positionEmpty`, `slotNotOpen`, `noActivePrescription`.
- Undo(intakeID, day): requires the Intake's Day to equal `day` and its Blister to be Current; sets the Position Present and deletes the Intake. Error: `undoNotAllowed`.
- SyncPosition(pillTypeID, position, isPresent): sets the Position state on the Current Blister. Never touches Intakes.
- StartNewBlister(pillTypeID): requires every Position Empty; retires the Current Blister and creates a new Current one with all Positions Present. Error: `blisterNotEmpty`.
- DailyProgress(day): for every Pill Type with a Prescription, returns the Prescription state, the Slots with Done/Open per Slot derived from that Day's Intakes intersected with the current Prescription Slots, the Completed flag, the Present count, and the low-stock flag (Present count < Open count). Home orders by Pill Type creation date.
- Pill Type and Prescription CRUD go through repositories directly from view models; the only rule enforced there is "grid shape editable only when the Current Blister is empty" and "Prescription Slots non-empty", which live as validation in Domain value initialisers.

### Repositories (Domain protocols, Data implementations)

- `PillTypeRepository`: aggregate root for Pill Type, its Prescription and its Blisters. Fetch all, fetch by id, create, update, delete.
- `IntakeRepository`: fetch Intakes for a Day (optionally per Pill Type), create, delete by id.
- Both expose a shared change stream from Data so the Home and Blister view models reload after any write.

### Screens (app target)

- **Home**: cards for Active Prescriptions ordered by Pill Type creation date; Paused section; "+" to add a Pill Type; link to the Pill Types list; empty state.
- **Blister**: grid, Slot chips, action sheets per Position tap, Undo via Done chip, Start New Blister with confirmation only when the grid is empty, toolbar entries for Prescription editing (create, edit Slots, pause, resume, delete) and Pill Type editing (rename, shape when allowed, delete).
- **Pill Types list**: all Pill Types; tapping opens the Blister screen.
- Navigation via `NavigationStack`.

## Testing Decisions

A good test exercises a use case through its public interface with fake repositories and asserts on observable outcomes (returned values, thrown errors, repository contents). It never asserts on call order, private state, or view-model property mirroring. Tests pass `Day` values explicitly, so no clock faking is needed and nothing depends on wall time.

- **Domain package** (Swift Testing, in-memory fake repositories): Consume happy path and each error; Undo allowed vs. not allowed (other Day, Retired Blister); SyncPosition leaves Intakes untouched; StartNewBlister refusal and success, including Intakes surviving; DailyProgress for Done/Open/Completed, low-stock flag, Prescription edited mid-day (removed Slot drops out, added Slot is Open), Paused Prescription excluded, Pill Type without Prescription excluded.
- **Data package** (Swift Testing, in-memory `ModelContainer`): round-trip mapping for each aggregate; cascade delete of a Pill Type removes Prescription, Blisters and Intakes; deleting a Prescription keeps Intakes; Day is stored and read back explicitly, not derived.
- No view-model tests, no UI tests, no snapshot tests in v1.
- Prior art: none, the repo is an empty template. These tests set the convention.

## Out of Scope

- Any history UI, calendar, or editing of past Days (data model supports it; no screens).
- Clock times for Slots, notifications, reminders.
- More than one pill per Slot, non-daily schedules, multiple Prescriptions per Pill Type.
- Multiple Current Blisters per Pill Type, non-rectangular blisters.
- Changing grid shape while a Blister has Present pills.
- Dosage text, colours, icons on Pill Types.
- iCloud or any sync, accounts, export.
- Languages other than English.
- Widgets, watch app, Shortcuts.

## Further Notes

- Vocabulary is defined in `GLOSSARY.md`; use it in issue titles and test names. "Slot" means Morning/Day/Evening; "Position" means a grid cell.
- ADR 0001 records why Intakes are permanent and keyed on Pill Type with an explicit Day.
- Suggested implementation slices for issues: package scaffold and project settings; Domain model and use cases with tests; Data module with tests; Home screen; Blister screen with consume/undo/sync/new-blister; Pill Type and Prescription editing.
