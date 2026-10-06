import Foundation

/// Daily Progress: for every Pill Type with a Prescription, the Done/Open state of its current Slots
/// on `day` (that Day's Intakes intersected with the Prescription's Slots), ordered by Pill Type creation date.
/// Paused Prescriptions are included with their state so the Home screen can list them separately.
public struct DailyProgress: Sendable {
    private let pillTypes: any PillTypeRepository
    private let intakes: any IntakeRepository

    public init(pillTypes: any PillTypeRepository, intakes: any IntakeRepository) {
        self.pillTypes = pillTypes
        self.intakes = intakes
    }

    public func callAsFunction(day: Day) async throws -> [PillTypeProgress] {
        let aggregates = try await pillTypes.fetchAll()
        let dayIntakes = try await intakes.fetch(day: day, pillTypeID: nil)
        return aggregates.compactMap { Self.progress(for: $0, intakes: dayIntakes) }
    }

    /// Progress of one Pill Type, or nil when it does not exist or has no Prescription.
    public func callAsFunction(pillTypeID: UUID, day: Day) async throws -> PillTypeProgress? {
        guard let aggregate = try await pillTypes.fetch(id: pillTypeID) else { return nil }
        let dayIntakes = try await intakes.fetch(day: day, pillTypeID: pillTypeID)
        return Self.progress(for: aggregate, intakes: dayIntakes)
    }

    private static func progress(for aggregate: PillTypeAggregate, intakes: [Intake]) -> PillTypeProgress? {
        guard let prescription = aggregate.prescription else { return nil }
        let own = intakes.filter { $0.pillTypeID == aggregate.id }
        let slots = Slot.allCases
            .filter(prescription.contains)
            .map { slot in SlotProgress(slot: slot, intake: own.first { $0.slot == slot }) }
        return PillTypeProgress(
            aggregate: aggregate,
            prescriptionState: prescription.state,
            slots: slots,
            presentCount: aggregate.currentBlister?.presentPositions.count ?? 0
        )
    }
}
