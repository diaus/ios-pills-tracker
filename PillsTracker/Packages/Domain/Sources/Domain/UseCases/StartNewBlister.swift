import Foundation

/// Start New Blister: retires the Current Blister (allowed only when every Position is Empty)
/// and replaces it with a fresh one where every Position is Present.
public struct StartNewBlister: Sendable {
    private let repository: any PillTypeRepository

    public init(repository: any PillTypeRepository) {
        self.repository = repository
    }

    public func callAsFunction(pillTypeID: UUID) async throws {
        guard var aggregate = try await repository.fetch(id: pillTypeID) else { throw DomainError.pillTypeNotFound }
        try aggregate.startNewBlister()
        try await repository.update(aggregate)
    }
}
