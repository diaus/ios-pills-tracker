import Foundation

/// Sync Edit: sets one Position of the Current Blister Present or Empty so the app matches reality.
/// Touches nothing else: no Intake is created and Retired Blisters stay as they are. A Position with an
/// Intake cannot be set Present; only Undo does that.
public struct SyncPosition: Sendable {
    private let repository: any PillTypeRepository

    public init(repository: any PillTypeRepository) {
        self.repository = repository
    }

    public func callAsFunction(pillTypeID: UUID, position: Position, isPresent: Bool) async throws {
        guard var aggregate = try await repository.fetch(id: pillTypeID) else { throw DomainError.pillTypeNotFound }
        let blisterIntakes = try await repository.intakes(blisterIDs: aggregate.currentBlister.map { [$0.id] } ?? [])
        try aggregate.syncPosition(position, isPresent: isPresent, blisterIntakes: blisterIntakes)
        try await repository.update(aggregate)
    }
}
