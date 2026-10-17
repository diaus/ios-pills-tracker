import Foundation
import Testing
@testable import Domain

struct UndoTests {
    private let today = Day(year: 2026, month: 10, day: 6)
    private let instant = Date(timeIntervalSince1970: 1_791_000_000)
    private let position = Position(row: 0, column: 1)

    /// An aggregate whose Current Blister already lacks `position`, plus the Intake that emptied it.
    private func makeConsumed(day: Day) throws -> (PillTypeAggregate, Intake) {
        var aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 1, columns: 3, createdAt: Date(timeIntervalSince1970: 0))
        try aggregate.setPrescriptionSlots([.morning])
        let intake = try aggregate.consume(position, slot: .morning, doneSlots: [], day: day, instant: instant)
        return (aggregate, intake)
    }

    @Test func restoresThePositionAndDeletesTodaysIntakeFromTheCurrentBlister() async throws {
        let (aggregate, intake) = try makeConsumed(day: today)
        let pillTypes = FakePillTypeRepository([aggregate])
        let intakes = FakeIntakeRepository([intake])
        let sut = Undo(pillTypes: pillTypes, intakes: intakes)

        try await sut(intakeID: intake.id, day: today)

        let current = try #require(await pillTypes.fetch(id: aggregate.id)?.currentBlister)
        #expect(current.isPresent(position))
        #expect(current.presentPositions.count == 3)
        #expect(await intakes.all.isEmpty)
    }

    @Test func refusesAnIntakeFromAnotherDay() async throws {
        let (aggregate, intake) = try makeConsumed(day: Day(year: 2026, month: 10, day: 5))
        let pillTypes = FakePillTypeRepository([aggregate])
        let intakes = FakeIntakeRepository([intake])
        let sut = Undo(pillTypes: pillTypes, intakes: intakes)

        await #expect(throws: DomainError.undoNotAllowed) {
            try await sut(intakeID: intake.id, day: today)
        }
        #expect(await pillTypes.fetch(id: aggregate.id) == aggregate)
        #expect(await intakes.all == [intake])
    }

    @Test func refusesAnIntakeFromARetiredBlister() async throws {
        var (aggregate, intake) = try makeConsumed(day: today)
        try aggregate.syncCurrentBlister(present: [])
        try aggregate.startNewBlister()
        let pillTypes = FakePillTypeRepository([aggregate])
        let intakes = FakeIntakeRepository([intake])
        let sut = Undo(pillTypes: pillTypes, intakes: intakes)

        await #expect(throws: DomainError.undoNotAllowed) {
            try await sut(intakeID: intake.id, day: today)
        }
        #expect(await pillTypes.fetch(id: aggregate.id) == aggregate)
        #expect(await intakes.all == [intake])
    }

    @Test func refusesAnUnknownIntake() async throws {
        let sut = Undo(pillTypes: FakePillTypeRepository(), intakes: FakeIntakeRepository())
        await #expect(throws: DomainError.undoNotAllowed) {
            try await sut(intakeID: UUID(), day: today)
        }
    }
}
