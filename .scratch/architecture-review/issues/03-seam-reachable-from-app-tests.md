# 03: Make the repository seam reachable from the app's tests

**What to build:** Add `FactoryTesting` to `PillsTrackerTests` and use `@Suite(.container)` so each test owns its `Container.shared`; tests register an in-memory `PillTypeRepositoryLive` there and build view models as the app does. Delete `DailyProgressModel.preview(_:)` and `isFixed`: each `#Preview` registers its repository first (`let _ = Container.shared.pillTypeRepository.register { … }`) over a seeded in-memory store; the Loading and Failed previews use two preview-only adapters in `Shared/Preview/` (one never returns, one throws).

**Status:** ready-for-agent

- [ ] First test, read before relying on the trait: a `.singleton` registration (`modelContainer`, `pillTypeRepository`) resolved under `@Suite(.container)` is not shared with another test's container
- [ ] `WidgetTapRouterTests`: a tap while Today is loading opens the Blister screen once loaded; an unknown Pill Type lands on Home; two taps on the same Pill Type give different identities; the configure tap shows the help
- [ ] `BlisterViewModelTests` Selected Day rules: `selectDay` refuses a future Day; `moveForward` stops at today; `todayChanged` moves a Selected Day that was today and leaves a past one
- [ ] `isFixed` and `preview(_:)` gone; all seven preview sites register a repository instead, Loading and Failed included
- [ ] `scripts/check.sh` passes, `build_sim` builds with zero warnings, `test_sim` passes
