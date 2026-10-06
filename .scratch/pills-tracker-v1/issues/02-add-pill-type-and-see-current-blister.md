# 02: Add a Pill Type and see its Current Blister

**What to build:** The user taps "+" on Home, enters a name and the grid shape, and gets a Pill Type with a Current Blister where every Position is Present. They can find it in the Pill Types list and open the Blister screen to see the grid mirroring their strip.

**Blocked by:** 01 Project scaffold

**Status:** ready-for-agent

- [x] Domain: Pill Type (id, name, rows, columns, creation timestamp) and Blister (id, pill type id, Current/Retired, set of Present Positions) value types; Position is zero-based (row, column); rows and columns validated to 1…10 and name validated non-empty in Domain
- [x] Domain: PillTypeRepository protocol (fetch all, fetch by id, create, update, delete) treating Pill Type as the aggregate root for its Blisters
- [x] Data: SwiftData models under a VersionedSchema, mapping to and from Domain values, a `@ModelActor` repository implementation registered in a Factory `Container` extension
- [x] Data: a "data changed" AsyncStream that fires after every write
- [x] Creating a Pill Type also creates its Current Blister with every Position Present
- [x] Home "+" opens a sheet with name, rows, columns; validation errors are shown inline; saving dismisses and the Pill Types list shows the new type
- [x] A Pill Types list screen lists every Pill Type ordered by creation date; tapping opens the Blister screen
- [x] Blister screen renders the grid with Present and Empty Positions visually distinct (read-only in this ticket)
- [x] Data tests with an in-memory ModelContainer: Pill Type with its Blister round-trips; fetch all returns creation-date order
- [x] View models are `@MainActor @Observable` and registered via Factory in the app target
