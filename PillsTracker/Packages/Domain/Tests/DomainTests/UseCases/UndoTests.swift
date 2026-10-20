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

    @Test func restoresThePositionAndDeletesTheIntakeFromTheCurrentBlister() async throws {
        let (aggregate, intake) = try makeConsumed(day: today)
        let pillTypes = FakePillTypeRepository([aggregate], intakes: [intake])
        let sut = Undo(repository: pillTypes)

        try await sut(intakeID: intake.id)

        let current = try #require(await pillTypes.fetch(id: aggregate.id)?.currentBlister)
        #expect(current.isPresent(position))
        #expect(current.presentPositions.count == 3)
        #expect(await pillTypes.allIntakes.isEmpty)
    }

    @Test func restoresThePositionOfAnIntakeFromAnEarlierDay() async throws {
        let (aggregate, intake) = try makeConsumed(day: Day(year: 2026, month: 9, day: 29))
        let pillTypes = FakePillTypeRepository([aggregate], intakes: [intake])
        let sut = Undo(repository: pillTypes)

        try await sut(intakeID: intake.id)

        #expect(await pillTypes.fetch(id: aggregate.id)?.currentBlister?.isPresent(position) == true)
        #expect(await pillTypes.allIntakes.isEmpty)
    }

    @Test func refusesAnIntakeFromARetiredBlister() async throws {
        var (aggregate, intake) = try makeConsumed(day: today)
        try aggregate.syncCurrentBlister(present: [])
        try aggregate.startNewBlister()
        let pillTypes = FakePillTypeRepository([aggregate], intakes: [intake])
        let sut = Undo(repository: pillTypes)

        await #expect(throws: DomainError.undoNotAllowed) {
            try await sut(intakeID: intake.id)
        }
        #expect(await pillTypes.fetch(id: aggregate.id) == aggregate)
        #expect(await pillTypes.allIntakes == [intake])
    }

    @Test func refusesAnUnknownIntake() async throws {
        let sut = Undo(repository: FakePillTypeRepository())
        await #expect(throws: DomainError.undoNotAllowed) {
            try await sut(intakeID: UUID())
        }
    }
}
