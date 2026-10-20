import Foundation

/// Intake History: one Pill Type's Intakes over `days`, from the Current Blister and every Retired one,
/// with each Day judged against its Prescription. nil when the Pill Type no longer exists.
public struct IntakeHistory: Sendable {
    private let repository: any PillTypeRepository

    public init(repository: any PillTypeRepository) {
        self.repository = repository
    }

    public func callAsFunction(pillTypeID: UUID, days: ClosedRange<Day>, today: Day) async throws -> PillTypeHistory? {
        guard let aggregate = try await repository.fetch(id: pillTypeID) else { return nil }
        let intakes = try await repository.intakes(pillTypeID: pillTypeID, days: days)
        return PillTypeHistory(prescription: aggregate.prescription, intakes: intakes, today: today)
    }
}
