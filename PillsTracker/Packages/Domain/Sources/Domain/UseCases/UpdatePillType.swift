import Foundation

/// Applies one change (rename, shape, Prescription) to a Pill Type and stores it. The aggregate is
/// fetched fresh, so the change lands on what is stored rather than on a screen's older copy.
public struct UpdatePillType: Sendable {
    private let repository: any PillTypeRepository

    public init(repository: any PillTypeRepository) {
        self.repository = repository
    }

    /// Returns the stored aggregate. A rule `change` breaks throws its `DomainError` and stores nothing.
    @discardableResult
    public func callAsFunction(
        pillTypeID: UUID,
        _ change: @Sendable (inout PillTypeAggregate) throws(DomainError) -> Void
    ) async throws -> PillTypeAggregate {
        guard var aggregate = try await repository.fetch(id: pillTypeID) else { throw DomainError.pillTypeNotFound }
        try change(&aggregate)
        try await repository.update(aggregate)
        return aggregate
    }
}
