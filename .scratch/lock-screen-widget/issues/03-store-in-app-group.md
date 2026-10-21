# 03: Store moves into the App Group

**What to build:** The SwiftData store moves from the app's Application Support into an App Group container, so the widget extension can open it (ADR 0003). An existing store is moved there on first launch, without losing any data.

**Blocked by:** none

**Status:** ready-for-agent

- [x] An App Group (e.g. `group.com.andrew.PillsTracker`) is added to the app target's entitlements, with `CODE_SIGN_ENTITLEMENTS` set
- [x] Data: `PillsModelContainer` opens the store at a URL in the App Group container, and the group identifier is defined once in the Data package
- [x] Data: before the container opens, if the App Group has no store and Application Support has one, the store file and its `-wal`/`-shm` files are moved into the App Group. When both exist, the App Group store wins and the old one is left alone.
- [x] Data tests: the move function, run against temporary directories, moves all three files, does nothing when there's no old store, and doesn't overwrite an existing new store
- [x] Manual check: install the current build, add a Pill Type with Intakes, install the new build over it, and the data is still there
- [x] `scripts/check.sh` passes and `build_sim` builds with zero warnings

## Comments

- `scripts/check.sh` passes. The `build_sim` half of the last box and the Manual check are left to the merger: raw `xcodebuild` is blocked for parallel implementers, so this branch has no app build or simulator run yet. The merger also confirms the App Group container is non-nil on the simulator.
- The entry point is `PillsModelContainer.makeInAppGroup()` (public, in `Schema/PillsStoreLocation.swift`). It moves the old store before it opens the container, so the widget extension must open the store through it too: a widget that ran first would otherwise create an empty App Group store, which then wins over the old one.
- The old store's URL is spelled out (`Application Support/default.store`). `ModelConfiguration`'s default `groupContainer: .automatic` puts the store in the first App Group once the entitlement exists, so the default no longer points at the old store.
- Merged into `feat/lock-screen-widget` on top of ticket 02 (no conflicts; `PillsModelContainer` stays on `PillsSchemaV3`). `PillsModelContainer.make(inMemory:)` lost its `= false` default: only tests call it, all in memory, so nothing can open the on-disk store while skipping the move. `scripts/check.sh` passes (`StoreMoveTests` included), `build_sim` has zero warnings from our code, `test_sim` passes (10/10).
- Manual check, iPhone 16 (iOS 18.5), installing the merged build over the pre-03 build: before, the data container's `Library/Application Support` held `default.store` (126976 B), `-shm` (32768 B), `-wal` (399672 B), and the app had no App Group container. After the first launch, `simctl get_app_container … groups` lists `group.com.andrew.PillsTracker` (so the container is non-nil on the simulator), its `Library/Application Support` holds all three files at the same sizes, and the data container's `Application Support` is empty. In the app: All Pill Types (4) lists Test, Notifier Check, Vitamin D and Magnesium; Vitamin D's Abbreviation is still VD; its Blister shows Morning Done with one pill Taken (9 left), and History shows 21 October with 1 Intake, Completed.
