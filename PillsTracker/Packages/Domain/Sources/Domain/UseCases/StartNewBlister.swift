import Foundation

/// Start New Blister: retires the Current Blister (allowed only when every Position is Empty)
/// and replaces it with a fresh one where every Position is Present.
/// The Retired Blister keeps its final grid and shape so its Intakes stay meaningful; the fresh one
/// takes the Pill Type's shape as it is now.
public struct StartNewBlister: Sendable {
    private let repository: any PillTypeRepository

    public init(repository: any PillTypeRepository) {
        self.repository = repository
    }

    public func callAsFunction(pillTypeID: UUID) async throws {
        guard var aggregate = try await repository.fetch(id: pillTypeID) else { throw UseCaseError.pillTypeNotFound }
        let index = try aggregate.currentBlisterIndex()
        guard aggregate.blisters[index].isEmpty else { throw UseCaseError.blisterNotEmpty }

        aggregate.blisters[index].state = .retired
        aggregate.blisters.append(.fresh(pillTypeID: pillTypeID, shape: aggregate.pillType.shape))
        try await repository.update(aggregate)
    }
}
