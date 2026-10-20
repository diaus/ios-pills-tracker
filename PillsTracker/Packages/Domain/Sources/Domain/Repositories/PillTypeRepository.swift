import Foundation

/// Persistence boundary for the Pill Type aggregate (Pill Type with its Blisters and Prescription)
/// and the Intakes it owns. Each write is one save: it happens completely or not at all.
public protocol PillTypeRepository: Sendable {
    /// Every aggregate ordered by Pill Type creation date, oldest first.
    func fetchAll() async throws -> [PillTypeAggregate]
    func fetch(id: UUID) async throws -> PillTypeAggregate?
    /// Every Intake recorded on `day`, optionally only those of one Pill Type, ordered by instant.
    func intakes(on day: Day, pillTypeID: UUID?) async throws -> [Intake]
    /// Every Intake from one of `blisterIDs`, on any Day, ordered by instant.
    func intakes(blisterIDs: [UUID]) async throws -> [Intake]
    /// Every Intake of one Pill Type recorded on one of `days`, from any Blister, ordered by instant.
    func intakes(pillTypeID: UUID, days: ClosedRange<Day>) async throws -> [Intake]
    func intake(id: UUID) async throws -> Intake?

    func create(_ aggregate: PillTypeAggregate) async throws
    /// Stores the aggregate's Pill Type fields and Prescription, its changed Blisters and its new ones.
    func update(_ aggregate: PillTypeAggregate) async throws
    /// Stores the aggregate and records `intake` (Consume) in the same save.
    func update(_ aggregate: PillTypeAggregate, recording intake: Intake) async throws
    /// Stores the aggregate and removes `intake` (Undo) in the same save.
    func update(_ aggregate: PillTypeAggregate, removing intake: Intake) async throws
    /// Deletes the Pill Type with everything it owns, Intakes included.
    func delete(id: UUID) async throws
}
