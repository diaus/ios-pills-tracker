import Foundation

/// Sync Edit: sets one Position of the Current Blister Present or Empty so the app matches reality.
/// Touches nothing else: no Intake is created and Retired Blisters stay as they are.
public struct SyncPosition: Sendable {
    private let repository: any PillTypeRepository

    public init(repository: any PillTypeRepository) {
        self.repository = repository
    }

    public func callAsFunction(pillTypeID: UUID, position: Position, isPresent: Bool) async throws {
        guard var aggregate = try await repository.fetch(id: pillTypeID) else { throw DomainError.pillTypeNotFound }
        try aggregate.syncPosition(position, isPresent: isPresent)
        try await repository.update(aggregate)
    }
}
