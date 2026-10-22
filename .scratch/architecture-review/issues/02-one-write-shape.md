# 02: Delete StartNewBlister; write down where a use case exists

**What to build:** `StartNewBlister` is `UpdatePillType` with the closure `{ try $0.startNewBlister() }`. Delete the use case, its Factory registration and its injection; `BlisterViewModel.startNewBlister()` goes through `updatePillType`. Its rule tests move to the aggregate. Create and delete stay single repository calls; CODING_STANDARDS states the rule.

**Status:** resolved

- [x] `Domain/UseCases/StartNewBlister.swift` and `StartNewBlisterTests.swift` deleted; the `startNewBlister` registration removed from `Container+UseCases.swift`
- [x] `PillTypeAggregateTests` covers: refuses while any Position is Present; retires the empty Current Blister and starts a full one; a Retired Blister keeps its final grid when another is retired later. `UpdatePillTypeTests` covers the unknown Pill Type (added if missing)
- [x] `EditPillTypeTests` uses `UpdatePillType` for its Start New Blister fixture
- [x] CODING_STANDARDS, Architecture: "A use case exists where a read or write composes more than one repository call … A single repository call is made directly."
- [x] `scripts/check.sh` passes, `build_sim` builds with zero warnings, `test_sim` passes

## Comments

- **Resolved:** Domain 100 tests (4 use-case tests replaced by 3 aggregate tests; the unknown-Pill-Type case was already in `UpdatePillTypeTests`), `scripts/check.sh` OK, `build_sim` zero warnings, `test_sim` 28 passed. Two Data tests used the use case as a fixture and now call `UpdatePillType` with the closure. The Start New Blister button wasn't driven in the simulator: the path it takes is the one `UpdatePillType`'s tests and the Data persistence tests exercise.
