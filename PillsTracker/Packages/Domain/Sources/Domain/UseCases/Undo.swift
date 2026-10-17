import Foundation

/// Undo: reverts an Intake made on `day` from the Current Blister. The Position becomes Present
/// again and the Intake is removed. Intakes from another Day or a Retired Blister cannot be undone,
/// because the user can no longer verify them against the Blister in hand.
public struct Undo: Sendable {
    private let repository: any PillTypeRepository

    public init(repository: any PillTypeRepository) {
        self.repository = repository
    }

    public func callAsFunction(intakeID: UUID, day: Day) async throws {
        guard let intake = try await repository.intake(id: intakeID) else { throw DomainError.undoNotAllowed }
        guard var aggregate = try await repository.fetch(id: intake.pillTypeID) else { throw DomainError.pillTypeNotFound }
        try aggregate.undo(intake, on: day)
        try await repository.update(aggregate, removing: intake)
    }
}
