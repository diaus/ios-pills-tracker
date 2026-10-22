# 02: Delete StartNewBlister; write down where a use case exists

**What to build:** `StartNewBlister` is `UpdatePillType` with the closure `{ try $0.startNewBlister() }`. Delete the use case, its Factory registration and its injection; `BlisterViewModel.startNewBlister()` goes through `updatePillType`. Its rule tests move to the aggregate. Create and delete stay single repository calls; CODING_STANDARDS states the rule.

**Status:** ready-for-agent

- [ ] `Domain/UseCases/StartNewBlister.swift` and `StartNewBlisterTests.swift` deleted; the `startNewBlister` registration removed from `Container+UseCases.swift`
- [ ] `PillTypeAggregateTests` covers: refuses while any Position is Present; retires the empty Current Blister and starts a full one; a Retired Blister keeps its final grid when another is retired later. `UpdatePillTypeTests` covers the unknown Pill Type (added if missing)
- [ ] `EditPillTypeTests` uses `UpdatePillType` for its Start New Blister fixture
- [ ] CODING_STANDARDS, Architecture: "A use case exists where a read or write composes more than one repository call … A single repository call is made directly."
- [ ] `scripts/check.sh` passes, `build_sim` builds with zero warnings, `test_sim` passes
