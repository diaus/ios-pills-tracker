import Foundation

/// Consume: takes a Present pill from a Position of the Current Blister for one of the Day's Open Slots.
/// The Position becomes Empty and an Intake is recorded. `day` and `instant` come from the caller;
/// the use case never reads a clock (ADR 0001).
public struct Consume: Sendable {
    private let pillTypes: any PillTypeRepository
    private let intakes: any IntakeRepository

    public init(pillTypes: any PillTypeRepository, intakes: any IntakeRepository) {
        self.pillTypes = pillTypes
        self.intakes = intakes
    }

    @discardableResult
    public func callAsFunction(pillTypeID: UUID, position: Position, slot: Slot, day: Day, instant: Date) async throws -> Intake {
        guard var aggregate = try await pillTypes.fetch(id: pillTypeID) else { throw UseCaseError.pillTypeNotFound }
        guard let index = aggregate.blisters.firstIndex(where: { $0.state == .current }) else {
            throw UseCaseError.noCurrentBlister
        }
        guard let prescription = aggregate.prescription, prescription.state == .active else {
            throw UseCaseError.noActivePrescription
        }
        guard aggregate.blisters[index].isPresent(position) else { throw UseCaseError.positionEmpty }

        let doneSlots = Set(try await intakes.fetch(day: day, pillTypeID: pillTypeID).map(\.slot))
        guard prescription.contains(slot), !doneSlots.contains(slot) else { throw UseCaseError.slotNotOpen }

        aggregate.blisters[index].presentPositions.remove(position)
        let intake = Intake(
            pillTypeID: pillTypeID,
            blisterID: aggregate.blisters[index].id,
            position: position,
            slot: slot,
            day: day,
            instant: instant
        )
        try await pillTypes.update(aggregate)
        try await intakes.create(intake)
        return intake
    }
}
