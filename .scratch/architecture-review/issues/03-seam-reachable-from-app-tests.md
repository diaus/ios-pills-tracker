# 03: Make the repository seam reachable from the app's tests

**What to build:** Add `FactoryTesting` to `PillsTrackerTests` and use `@Suite(.container)` so each test owns its `Container.shared`; tests register an in-memory `PillTypeRepositoryLive` there and build view models as the app does. Delete `DailyProgressModel.preview(_:)` and `isFixed`: each `#Preview` registers its repository first (`let _ = Container.shared.pillTypeRepository.register { … }`) over a seeded in-memory store; the Loading and Failed previews use two preview-only adapters in `Shared/Preview/` (one never returns, one throws).

**Status:** resolved

- [x] First test, read before relying on the trait: a `.singleton` registration (`modelContainer`, `pillTypeRepository`) resolved under `@Suite(.container)` is not shared with another test's container
- [x] `WidgetTapRouterTests`: a tap while Today is loading opens the Blister screen once loaded; an unknown Pill Type lands on Home; two taps on the same Pill Type give different identities; the configure tap shows the help
- [x] `BlisterViewModelTests` Selected Day rules: `selectDay` refuses a future Day; `moveForward` stops at today; `todayChanged` moves a Selected Day that was today and leaves a past one
- [x] `isFixed` and `preview(_:)` gone; all seven preview sites register a repository instead, Loading and Failed included
- [x] `scripts/check.sh` passes, `build_sim` builds with zero warnings, `test_sim` passes

## Comments

- **Finding on the first box:** the `.container` trait isolates registrations, but Factory's `.singleton` cache is global: a `dataChangeNotifier` resolved in one test came back in the next (the check failed on first run). A `register` resets the cache, so `Container.registerInMemoryStore` in `PillsTrackerTests/Support/` registers both the repository and a fresh notifier; `FactoryContainerIsolationTests` guards that contract.
- **Previews:** a SwiftData store can't be seeded from a synchronous `#Preview` builder, so every preview uses the preview-only adapter `PreviewPillTypeRepository` (fixed content, never loads, or fails), registered by `DailyProgressModel.preview(_:)` in `Shared/Preview/` before the model resolves its use cases. The Blister (loaded, Failed) and Home previews were rendered through Xcode and show the grid with today's chips, the load-failed view with the error alert, and the Home list.
- **Resolved:** `test_sim` 38 passed (10 new: 2 isolation, 5 router, 3 Blister view model), `build_sim` zero warnings, `scripts/check.sh` OK.
