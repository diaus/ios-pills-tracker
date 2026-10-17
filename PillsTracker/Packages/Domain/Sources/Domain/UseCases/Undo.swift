import Foundation

/// Undo: reverts an Intake made on `day` from the Current Blister. The Position becomes Present
/// again and the Intake is removed. Intakes from another Day or a Retired Blister cannot be undone,
/// because the user can no longer verify them against the Blister in hand.
public struct Undo: Sendable {
    private let pillTypes: any PillTypeRepository
    private let intakes: any IntakeRepository

    public init(pillTypes: any PillTypeRepository, intakes: any IntakeRepository) {
        self.pillTypes = pillTypes
        self.intakes = intakes
    }

    public func callAsFunction(intakeID: UUID, day: Day) async throws {
        guard let intake = try await intakes.fetch(id: intakeID) else { throw DomainError.undoNotAllowed }
        guard var aggregate = try await pillTypes.fetch(id: intake.pillTypeID) else { throw DomainError.pillTypeNotFound }
        try aggregate.undo(intake, on: day)
        try await pillTypes.update(aggregate)
        try await intakes.delete(id: intake.id)
    }
}
