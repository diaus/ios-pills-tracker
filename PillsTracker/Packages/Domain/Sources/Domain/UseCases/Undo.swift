import Foundation

/// Undo: reverts an Intake from the Current Blister, made on any Day. The Position becomes Present
/// again and the Intake is removed. Only the latest Intake at a Position can be undone, and Intakes
/// from a Retired Blister cannot be, because the user can no longer verify them against the Blister in hand.
public struct Undo: Sendable {
    private let repository: any PillTypeRepository

    public init(repository: any PillTypeRepository) {
        self.repository = repository
    }

    public func callAsFunction(intakeID: UUID) async throws {
        guard let intake = try await repository.intake(id: intakeID) else { throw DomainError.undoNotAllowed }
        guard var aggregate = try await repository.fetch(id: intake.pillTypeID) else { throw DomainError.pillTypeNotFound }
        let blisterIntakes = try await repository.intakes(blisterIDs: [intake.blisterID])
        try aggregate.undo(intake, blisterIntakes: blisterIntakes)
        try await repository.update(aggregate, removing: intake)
    }
}
