import Domain
import Foundation
import Testing
@testable import PillsTracker

/// What tapping a Position of the Blister grid offers.
@MainActor
struct PositionActionsTests {
    private let today = Day(year: 2026, month: 10, day: 6)
    private let instant = Date(timeIntervalSince1970: 1_791_000_000)
    private let first = Position(row: 0, column: 0)
    private let second = Position(row: 0, column: 1)

    private func makeAggregate(slots: Set<Slot>) throws -> PillTypeAggregate {
        var aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 1, columns: 3, createdAt: Date(timeIntervalSince1970: 0))
        try aggregate.setPrescription(slots: slots, startDay: today, endDay: nil)
        return aggregate
    }

    @Test func anEmptyPositionWithAnIntakeIsOnlyUndone() throws {
        var aggregate = try makeAggregate(slots: [.morning, .evening])
        let intake = try aggregate.consume(first, slot: .morning, doneSlots: [], day: today, instant: instant)

        let progress = PillTypeProgress(aggregate: aggregate, day: today, intakes: [intake])

        #expect(progress.actions(at: first) == .undo(intake))
    }

    @Test func aPresentPositionOffersTheSlotsItCanBeConsumedFor() throws {
        var aggregate = try makeAggregate(slots: [.morning, .day, .evening])
        let intake = try aggregate.consume(first, slot: .day, doneSlots: [], day: today, instant: instant)

        let progress = PillTypeProgress(aggregate: aggregate, day: today, intakes: [intake])

        #expect(progress.actions(at: second) == .consume(slots: [.morning, .evening]))
    }

    @Test func aPresentPositionUnderAPausedPrescriptionOffersNoSlot() throws {
        var aggregate = try makeAggregate(slots: [.morning])
        try aggregate.pausePrescription()

        let progress = PillTypeProgress(aggregate: aggregate, day: today, intakes: [])

        #expect(progress.actions(at: first) == .consume(slots: []))
    }

    @Test func anEmptyPositionWithoutAnIntakeCanBeSetPresent() throws {
        var aggregate = try makeAggregate(slots: [.morning])
        try aggregate.syncPosition(first, isPresent: false, blisterIntakes: [])

        let progress = PillTypeProgress(aggregate: aggregate, day: today, intakes: [])

        #expect(progress.actions(at: first) == .setPresent)
    }

    @Test func aPositionOutsideTheGridOffersNothing() throws {
        let progress = PillTypeProgress(aggregate: try makeAggregate(slots: [.morning]), day: today, intakes: [])

        #expect(progress.actions(at: Position(row: 5, column: 5)) == .nothing)
    }
}
