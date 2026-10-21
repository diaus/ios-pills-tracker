# 03: Store moves into the App Group

**What to build:** The SwiftData store moves from the app's Application Support into an App Group container, so the widget extension can open it (ADR 0003). An existing store is moved there on first launch, without losing any data.

**Blocked by:** none

**Status:** ready-for-agent

- [ ] An App Group (e.g. `group.com.andrew.PillsTracker`) is added to the app target's entitlements, with `CODE_SIGN_ENTITLEMENTS` set
- [ ] Data: `PillsModelContainer` opens the store at a URL in the App Group container, and the group identifier is defined once in the Data package
- [ ] Data: before the container opens, if the App Group has no store and Application Support has one, the store file and its `-wal`/`-shm` files are moved into the App Group. When both exist, the App Group store wins and the old one is left alone.
- [ ] Data tests: the move function, run against temporary directories, moves all three files, does nothing when there's no old store, and doesn't overwrite an existing new store
- [ ] Manual check: install the current build, add a Pill Type with Intakes, install the new build over it, and the data is still there
- [ ] `scripts/check.sh` passes and `build_sim` builds with zero warnings
