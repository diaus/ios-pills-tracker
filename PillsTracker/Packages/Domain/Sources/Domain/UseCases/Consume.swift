import Foundation

/// Consume: takes a Present pill from a Position of the Current Blister for one of the Day's Open Slots.
/// The Position becomes Empty and an Intake is recorded. `day` and `instant` come from the caller;
/// the use case never reads a clock (ADR 0001).
public struct Consume: Sendable {
    private let repository: any PillTypeRepository

    public init(repository: any PillTypeRepository) {
        self.repository = repository
    }

    @discardableResult
    public func callAsFunction(pillTypeID: UUID, position: Position, slot: Slot, day: Day, instant: Date) async throws -> Intake {
        guard var aggregate = try await repository.fetch(id: pillTypeID) else { throw DomainError.pillTypeNotFound }
        let doneSlots = Set(try await repository.intakes(on: day, pillTypeID: pillTypeID).map(\.slot))
        let intake = try aggregate.consume(position, slot: slot, doneSlots: doneSlots, day: day, instant: instant)
        try await repository.update(aggregate, recording: intake)
        return intake
    }
}
