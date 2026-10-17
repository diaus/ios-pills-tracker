import Foundation
import Testing
@testable import Domain

struct DailyProgressTests {
    private let today = Day(year: 2026, month: 10, day: 6)
    private let instant = Date(timeIntervalSince1970: 1_791_000_000)

    private func makeAggregate(name: String = "Aspirin", slots: Set<Slot>?, createdAt: TimeInterval = 0, rows: Int = 1, columns: Int = 3) throws -> PillTypeAggregate {
        var aggregate = try PillTypeAggregate.new(name: name, rows: rows, columns: columns, createdAt: Date(timeIntervalSince1970: createdAt))
        if let slots { try aggregate.setPrescriptionSlots(slots) }
        return aggregate
    }

    private func intake(for aggregate: PillTypeAggregate, slot: Slot, day: Day? = nil, column: Int = 0) throws -> Intake {
        let blisterID = try #require(aggregate.currentBlister?.id)
        return Intake(pillTypeID: aggregate.id, blisterID: blisterID, position: Position(row: 0, column: column), slot: slot, day: day ?? today, instant: instant)
    }

    private func makeSUT(_ aggregates: [PillTypeAggregate], intakes: [Intake] = []) -> DailyProgress {
        DailyProgress(repository: FakePillTypeRepository(aggregates, intakes: intakes))
    }

    @Test func slotsWithAnIntakeTodayAreDoneAndTheRestOpen() async throws {
        let aggregate = try makeAggregate(slots: [.morning, .day, .evening])
        let morning = try intake(for: aggregate, slot: .morning)
        let yesterdayEvening = try intake(for: aggregate, slot: .evening, day: Day(year: 2026, month: 10, day: 5), column: 1)
        let sut = makeSUT([aggregate], intakes: [morning, yesterdayEvening])

        let progress = try #require(try await sut(day: today).first)

        #expect(progress.id == aggregate.id)
        #expect(progress.aggregate == aggregate)
        #expect(progress.prescriptionState == .active)
        #expect(progress.slots.map(\.slot) == [.morning, .day, .evening])
        #expect(progress.intake(for: .morning) == morning)
        #expect(progress.isDone(.morning))
        #expect(!progress.isDone(.day))
        #expect(!progress.isDone(.evening))
        #expect(progress.openSlots == [.day, .evening])
        #expect(!progress.isCompleted)
    }

    @Test func isCompletedWhenNoSlotIsOpen() async throws {
        let aggregate = try makeAggregate(slots: [.morning, .evening])
        let sut = makeSUT([aggregate], intakes: [
            try intake(for: aggregate, slot: .morning),
            try intake(for: aggregate, slot: .evening, column: 1),
        ])

        let progress = try #require(try await sut(day: today).first)

        #expect(progress.isCompleted)
        #expect(progress.openSlots.isEmpty)
    }

    @Test func flagsLowStockWhenPresentPillsAreFewerThanOpenSlots() async throws {
        var aggregate = try makeAggregate(slots: [.morning, .day, .evening])
        try aggregate.syncCurrentBlister(present: [Position(row: 0, column: 2)])
        let sut = makeSUT([aggregate])

        let progress = try #require(try await sut(day: today).first)

        #expect(progress.presentCount == 1)
        #expect(progress.isLowStock)
    }

    @Test func enoughPresentPillsIsNotLowStock() async throws {
        var aggregate = try makeAggregate(slots: [.morning, .evening])
        try aggregate.syncCurrentBlister(present: [Position(row: 0, column: 1), Position(row: 0, column: 2)])
        let sut = makeSUT([aggregate])

        let progress = try #require(try await sut(day: today).first)

        #expect(progress.presentCount == 2)
        #expect(!progress.isLowStock)
    }

    @Test func aSlotRemovedFromThePrescriptionMidDayDropsOut() async throws {
        var aggregate = try makeAggregate(slots: [.morning, .evening])
        let morning = try intake(for: aggregate, slot: .morning)
        try aggregate.setPrescriptionSlots([.evening])
        let sut = makeSUT([aggregate], intakes: [morning])

        let progress = try #require(try await sut(day: today).first)

        #expect(progress.slots.map(\.slot) == [.evening])
        #expect(progress.intake(for: .morning) == nil)
        #expect(!progress.isCompleted)
    }

    @Test func aSlotAddedToThePrescriptionMidDayIsOpen() async throws {
        var aggregate = try makeAggregate(slots: [.morning])
        let morning = try intake(for: aggregate, slot: .morning)
        try aggregate.setPrescriptionSlots([.morning, .evening])
        let sut = makeSUT([aggregate], intakes: [morning])

        let progress = try #require(try await sut(day: today).first)

        #expect(progress.isDone(.morning))
        #expect(progress.openSlots == [.evening])
        #expect(!progress.isCompleted)
    }

    /// Story 21: Intakes are keyed on the Pill Type, so a Slot consumed before the Prescription was
    /// removed and set again the same Day is still Done.
    @Test func aSlotConsumedBeforeThePrescriptionWasRemovedAndSetAgainTheSameDayStaysDone() async throws {
        var aggregate = try makeAggregate(slots: [.morning, .evening])
        let pillTypes = FakePillTypeRepository([aggregate])
        try await Consume(repository: pillTypes)(
            pillTypeID: aggregate.id, position: Position(row: 0, column: 0), slot: .morning, day: today, instant: instant
        )

        aggregate = try #require(await pillTypes.fetch(id: aggregate.id))
        aggregate.removePrescription()
        try await pillTypes.update(aggregate)
        try aggregate.setPrescriptionSlots([.morning, .evening])
        try await pillTypes.update(aggregate)

        let sut = DailyProgress(repository: pillTypes)
        let progress = try #require(try await sut(day: today).first)
        #expect(progress.isDone(.morning))
        #expect(progress.openSlots == [.evening])
    }

    @Test func aPausedPrescriptionIsReportedPausedSoHomeCanLeaveItOut() async throws {
        var aggregate = try makeAggregate(slots: [.morning])
        try aggregate.pausePrescription()
        let sut = makeSUT([aggregate])

        let all = try await sut(day: today)

        #expect(all.map(\.prescriptionState) == [.paused])
        #expect(all.filter { $0.prescriptionState == .active }.isEmpty)
    }

    @Test func aPillTypeWithoutAPrescriptionIsIncludedWithNoSlots() async throws {
        let withPrescription = try makeAggregate(name: "Aspirin", slots: [.morning])
        let without = try makeAggregate(name: "Vitamin", slots: nil, createdAt: 1)
        let sut = makeSUT([withPrescription, without])

        let all = try await sut(day: today)

        #expect(all.map(\.id) == [withPrescription.id, without.id])
        let vitamin = try #require(all.last)
        #expect(!vitamin.hasPrescription)
        #expect(vitamin.prescriptionState == nil)
        #expect(vitamin.slots.isEmpty)
        #expect(vitamin.presentCount == 3)
    }

    @Test func isOrderedByPillTypeCreationDate() async throws {
        let newer = try makeAggregate(name: "Newer", slots: [.morning], createdAt: 2_000)
        let older = try makeAggregate(name: "Older", slots: [.day], createdAt: 1_000)
        let sut = makeSUT([newer, older])

        let all = try await sut(day: today)

        #expect(all.map(\.aggregate.pillType.name) == ["Older", "Newer"])
    }

    @Test func singlePillTypeLookupReturnsNilOnlyForAnUnknownPillType() async throws {
        let withPrescription = try makeAggregate(name: "Aspirin", slots: [.morning])
        let without = try makeAggregate(name: "Vitamin", slots: nil, createdAt: 1)
        let sut = makeSUT([withPrescription, without])

        #expect(try await sut(pillTypeID: withPrescription.id, day: today)?.id == withPrescription.id)
        let vitamin = try #require(try await sut(pillTypeID: without.id, day: today))
        #expect(vitamin.id == without.id)
        #expect(!vitamin.hasPrescription)
        #expect(try await sut(pillTypeID: UUID(), day: today) == nil)
    }

    // MARK: Affordances

    @Test func startNewBlisterIsOfferedOnlyWhenEveryPositionIsEmpty() async throws {
        var aggregate = try makeAggregate(slots: [.morning])
        let full = try #require(try await makeSUT([aggregate])(day: today).first)
        #expect(!full.canStartNewBlister)

        try aggregate.syncCurrentBlister(present: [])
        let empty = try #require(try await makeSUT([aggregate])(day: today).first)
        #expect(empty.canStartNewBlister)
    }

    @Test func aDoneSlotIsUndoableOnlyFromTheCurrentBlister() async throws {
        var aggregate = try makeAggregate(slots: [.morning, .evening])
        let fromRetired = try intake(for: aggregate, slot: .morning)
        try aggregate.syncCurrentBlister(present: [])
        try aggregate.startNewBlister()
        let fromCurrent = try intake(for: aggregate, slot: .evening, column: 1)
        let sut = makeSUT([aggregate], intakes: [fromRetired, fromCurrent])

        let progress = try #require(try await sut(day: today).first)

        #expect(progress.isDone(.morning))
        #expect(progress.undoableIntake(for: .morning) == nil)
        #expect(progress.undoableIntake(for: .evening) == fromCurrent)
    }

    @Test func consumableSlotsAreTodaysOpenSlotsForAPresentPosition() async throws {
        let aggregate = try makeAggregate(slots: [.morning, .day, .evening])
        let sut = makeSUT([aggregate], intakes: [try intake(for: aggregate, slot: .day)])

        let progress = try #require(try await sut(day: today).first)

        #expect(progress.consumableSlots(at: Position(row: 0, column: 1)) == [.morning, .evening])
    }

    @Test func nothingIsConsumableFromAnEmptyPositionOrOutsideTheGrid() async throws {
        var aggregate = try makeAggregate(slots: [.morning])
        try aggregate.syncPosition(Position(row: 0, column: 0), isPresent: false)
        let sut = makeSUT([aggregate])

        let progress = try #require(try await sut(day: today).first)

        #expect(progress.openSlots == [.morning])
        #expect(progress.consumableSlots(at: Position(row: 0, column: 0)).isEmpty)
        #expect(progress.consumableSlots(at: Position(row: 5, column: 5)).isEmpty)
        #expect(progress.consumableSlots(at: Position(row: 0, column: 1)) == [.morning])
    }

    @Test func nothingIsConsumableUnderAPausedPrescription() async throws {
        var aggregate = try makeAggregate(slots: [.morning])
        try aggregate.pausePrescription()
        let sut = makeSUT([aggregate])

        let progress = try #require(try await sut(day: today).first)

        #expect(progress.openSlots == [.morning])
        #expect(progress.consumableSlots(at: Position(row: 0, column: 0)).isEmpty)
    }

    @Test func nothingIsConsumableWithoutAPrescription() async throws {
        let aggregate = try makeAggregate(slots: nil)
        let sut = makeSUT([aggregate])

        let progress = try #require(try await sut(day: today).first)

        #expect(progress.consumableSlots(at: Position(row: 0, column: 0)).isEmpty)
    }
}
