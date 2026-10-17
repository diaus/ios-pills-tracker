import Foundation
import Testing
@testable import Domain

struct PillTypeProgressTests {
    private let today = Day(year: 2026, month: 10, day: 6)
    private let instant = Date(timeIntervalSince1970: 1_791_000_000)

    private func makeAggregate(slots: Set<Slot>?) throws -> PillTypeAggregate {
        var aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 1, columns: 3, createdAt: Date(timeIntervalSince1970: 0))
        if let slots { try aggregate.setPrescriptionSlots(slots) }
        return aggregate
    }

    private func intake(for aggregate: PillTypeAggregate, slot: Slot, day: Day? = nil, column: Int = 0) throws -> Intake {
        let blisterID = try #require(aggregate.currentBlister?.id)
        return Intake(pillTypeID: aggregate.id, blisterID: blisterID, position: Position(row: 0, column: column), slot: slot, day: day ?? today, instant: instant)
    }

    private func progress(_ aggregate: PillTypeAggregate, intakes: [Intake] = []) -> PillTypeProgress {
        PillTypeProgress(aggregate: aggregate, day: today, intakes: intakes)
    }

    @Test func slotsWithAnIntakeTodayAreDoneAndTheRestOpen() throws {
        let aggregate = try makeAggregate(slots: [.morning, .day, .evening])
        let morning = try intake(for: aggregate, slot: .morning)
        let yesterdayEvening = try intake(for: aggregate, slot: .evening, day: Day(year: 2026, month: 10, day: 5), column: 1)

        let progress = progress(aggregate, intakes: [morning, yesterdayEvening])

        #expect(progress.prescriptionState == .active)
        #expect(progress.slots.map(\.slot) == [.morning, .day, .evening])
        #expect(progress.intake(for: .morning) == morning)
        #expect(progress.isDone(.morning))
        #expect(!progress.isDone(.day))
        #expect(!progress.isDone(.evening))
        #expect(progress.openSlots == [.day, .evening])
        #expect(!progress.isCompleted)
    }

    @Test func anotherPillTypesIntakesDoNotCount() throws {
        let aggregate = try makeAggregate(slots: [.morning])
        let other = try makeAggregate(slots: [.morning])

        let progress = progress(aggregate, intakes: [try intake(for: other, slot: .morning)])

        #expect(progress.openSlots == [.morning])
    }

    @Test func isCompletedWhenNoSlotIsOpen() throws {
        let aggregate = try makeAggregate(slots: [.morning, .evening])

        let progress = progress(aggregate, intakes: [
            try intake(for: aggregate, slot: .morning),
            try intake(for: aggregate, slot: .evening, column: 1),
        ])

        #expect(progress.isCompleted)
        #expect(progress.openSlots.isEmpty)
    }

    @Test func flagsLowStockWhenPresentPillsAreFewerThanOpenSlots() throws {
        var aggregate = try makeAggregate(slots: [.morning, .day, .evening])
        try aggregate.syncCurrentBlister(present: [Position(row: 0, column: 2)])

        let progress = progress(aggregate)

        #expect(progress.presentCount == 1)
        #expect(progress.isLowStock)
    }

    @Test func enoughPresentPillsIsNotLowStock() throws {
        var aggregate = try makeAggregate(slots: [.morning, .evening])
        try aggregate.syncCurrentBlister(present: [Position(row: 0, column: 1), Position(row: 0, column: 2)])

        let progress = progress(aggregate)

        #expect(progress.presentCount == 2)
        #expect(!progress.isLowStock)
    }

    @Test func aSlotRemovedFromThePrescriptionMidDayDropsOut() throws {
        var aggregate = try makeAggregate(slots: [.morning, .evening])
        let morning = try intake(for: aggregate, slot: .morning)
        try aggregate.setPrescriptionSlots([.evening])

        let progress = progress(aggregate, intakes: [morning])

        #expect(progress.slots.map(\.slot) == [.evening])
        #expect(progress.intake(for: .morning) == nil)
        #expect(!progress.isCompleted)
    }

    @Test func aSlotAddedToThePrescriptionMidDayIsOpen() throws {
        var aggregate = try makeAggregate(slots: [.morning])
        let morning = try intake(for: aggregate, slot: .morning)
        try aggregate.setPrescriptionSlots([.morning, .evening])

        let progress = progress(aggregate, intakes: [morning])

        #expect(progress.isDone(.morning))
        #expect(progress.openSlots == [.evening])
        #expect(!progress.isCompleted)
    }

    /// Story 21: Intakes are keyed on the Pill Type, so a Slot consumed before the Prescription was
    /// removed and set again the same Day is still Done.
    @Test func aSlotConsumedBeforeThePrescriptionWasRemovedAndSetAgainTheSameDayStaysDone() throws {
        var aggregate = try makeAggregate(slots: [.morning, .evening])
        let morning = try aggregate.consume(Position(row: 0, column: 0), slot: .morning, doneSlots: [], day: today, instant: instant)
        aggregate.removePrescription()
        try aggregate.setPrescriptionSlots([.morning, .evening])

        let progress = progress(aggregate, intakes: [morning])

        #expect(progress.isDone(.morning))
        #expect(progress.openSlots == [.evening])
    }

    @Test func aPausedPrescriptionIsReportedPaused() throws {
        var aggregate = try makeAggregate(slots: [.morning])
        try aggregate.pausePrescription()

        #expect(progress(aggregate).prescriptionState == .paused)
    }

    @Test func aPillTypeWithoutAPrescriptionHasNoSlots() throws {
        let progress = progress(try makeAggregate(slots: nil))

        #expect(!progress.hasPrescription)
        #expect(progress.prescriptionState == nil)
        #expect(progress.slots.isEmpty)
        #expect(progress.presentCount == 3)
    }

    // MARK: Affordances

    @Test func startNewBlisterIsOfferedOnlyWhenEveryPositionIsEmpty() throws {
        var aggregate = try makeAggregate(slots: [.morning])
        #expect(!progress(aggregate).canStartNewBlister)

        try aggregate.syncCurrentBlister(present: [])
        #expect(progress(aggregate).canStartNewBlister)
    }

    @Test func aDoneSlotIsUndoableOnlyFromTheCurrentBlister() throws {
        var aggregate = try makeAggregate(slots: [.morning, .evening])
        let fromRetired = try intake(for: aggregate, slot: .morning)
        try aggregate.syncCurrentBlister(present: [])
        try aggregate.startNewBlister()
        let fromCurrent = try intake(for: aggregate, slot: .evening, column: 1)

        let progress = progress(aggregate, intakes: [fromRetired, fromCurrent])

        #expect(progress.isDone(.morning))
        #expect(progress.undoableIntake(for: .morning) == nil)
        #expect(progress.undoableIntake(for: .evening) == fromCurrent)
    }

    @Test func consumableSlotsAreTodaysOpenSlotsForAPresentPosition() throws {
        let aggregate = try makeAggregate(slots: [.morning, .day, .evening])

        let progress = progress(aggregate, intakes: [try intake(for: aggregate, slot: .day)])

        #expect(progress.consumableSlots(at: Position(row: 0, column: 1)) == [.morning, .evening])
    }

    @Test func nothingIsConsumableFromAnEmptyPositionOrOutsideTheGrid() throws {
        var aggregate = try makeAggregate(slots: [.morning])
        try aggregate.syncPosition(Position(row: 0, column: 0), isPresent: false)

        let progress = progress(aggregate)

        #expect(progress.openSlots == [.morning])
        #expect(progress.consumableSlots(at: Position(row: 0, column: 0)).isEmpty)
        #expect(progress.consumableSlots(at: Position(row: 5, column: 5)).isEmpty)
        #expect(progress.consumableSlots(at: Position(row: 0, column: 1)) == [.morning])
    }

    @Test func nothingIsConsumableUnderAPausedPrescription() throws {
        var aggregate = try makeAggregate(slots: [.morning])
        try aggregate.pausePrescription()

        let progress = progress(aggregate)

        #expect(progress.openSlots == [.morning])
        #expect(progress.consumableSlots(at: Position(row: 0, column: 0)).isEmpty)
    }

    @Test func nothingIsConsumableWithoutAPrescription() throws {
        #expect(progress(try makeAggregate(slots: nil)).consumableSlots(at: Position(row: 0, column: 0)).isEmpty)
    }
}
