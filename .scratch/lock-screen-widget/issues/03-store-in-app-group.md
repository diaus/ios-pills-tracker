# 03: Store moves into the App Group

**What to build:** The SwiftData store moves from the app's Application Support into an App Group container, so the widget extension can open it (ADR 0003). An existing store is moved there on first launch, without losing any data.

**Blocked by:** none

**Status:** ready-for-agent

- [x] An App Group (e.g. `group.com.andrew.PillsTracker`) is added to the app target's entitlements, with `CODE_SIGN_ENTITLEMENTS` set
- [x] Data: `PillsModelContainer` opens the store at a URL in the App Group container, and the group identifier is defined once in the Data package
- [x] Data: before the container opens, if the App Group has no store and Application Support has one, the store file and its `-wal`/`-shm` files are moved into the App Group. When both exist, the App Group store wins and the old one is left alone.
- [x] Data tests: the move function, run against temporary directories, moves all three files, does nothing when there's no old store, and doesn't overwrite an existing new store
- [ ] Manual check: install the current build, add a Pill Type with Intakes, install the new build over it, and the data is still there
- [ ] `scripts/check.sh` passes and `build_sim` builds with zero warnings

## Comments

- `scripts/check.sh` passes. The `build_sim` half of the last box and the Manual check are left to the merger: raw `xcodebuild` is blocked for parallel implementers, so this branch has no app build or simulator run yet. The merger also confirms the App Group container is non-nil on the simulator.
- The entry point is `PillsModelContainer.makeInAppGroup()` (public, in `Schema/PillsStoreLocation.swift`). It moves the old store before it opens the container, so the widget extension must open the store through it too: a widget that ran first would otherwise create an empty App Group store, which then wins over the old one.
- The old store's URL is spelled out (`Application Support/default.store`). `ModelConfiguration`'s default `groupContainer: .automatic` puts the store in the first App Group once the entitlement exists, so the default no longer points at the old store.
