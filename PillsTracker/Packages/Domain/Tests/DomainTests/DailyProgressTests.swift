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
        DailyProgress(pillTypes: FakePillTypeRepository(aggregates), intakes: FakeIntakeRepository(intakes))
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
        aggregate.blisters[0].presentPositions = [Position(row: 0, column: 2)]
        let sut = makeSUT([aggregate])

        let progress = try #require(try await sut(day: today).first)

        #expect(progress.presentCount == 1)
        #expect(progress.isLowStock)
    }

    @Test func enoughPresentPillsIsNotLowStock() async throws {
        var aggregate = try makeAggregate(slots: [.morning, .evening])
        aggregate.blisters[0].presentPositions = [Position(row: 0, column: 1), Position(row: 0, column: 2)]
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

    @Test func aPausedPrescriptionIsReportedPausedSoHomeCanLeaveItOut() async throws {
        var aggregate = try makeAggregate(slots: [.morning])
        try aggregate.pausePrescription()
        let sut = makeSUT([aggregate])

        let all = try await sut(day: today)

        #expect(all.map(\.prescriptionState) == [.paused])
        #expect(all.filter { $0.prescriptionState == .active }.isEmpty)
    }

    @Test func aPillTypeWithoutAPrescriptionIsExcluded() async throws {
        let withPrescription = try makeAggregate(name: "Aspirin", slots: [.morning])
        let without = try makeAggregate(name: "Vitamin", slots: nil, createdAt: 1)
        let sut = makeSUT([withPrescription, without])

        let all = try await sut(day: today)

        #expect(all.map(\.id) == [withPrescription.id])
    }

    @Test func isOrderedByPillTypeCreationDate() async throws {
        let newer = try makeAggregate(name: "Newer", slots: [.morning], createdAt: 2_000)
        let older = try makeAggregate(name: "Older", slots: [.day], createdAt: 1_000)
        let sut = makeSUT([newer, older])

        let all = try await sut(day: today)

        #expect(all.map(\.aggregate.pillType.name) == ["Older", "Newer"])
    }

    @Test func singlePillTypeLookupReturnsNilWithoutAPrescription() async throws {
        let withPrescription = try makeAggregate(name: "Aspirin", slots: [.morning])
        let without = try makeAggregate(name: "Vitamin", slots: nil, createdAt: 1)
        let sut = makeSUT([withPrescription, without])

        #expect(try await sut(pillTypeID: withPrescription.id, day: today)?.id == withPrescription.id)
        #expect(try await sut(pillTypeID: without.id, day: today) == nil)
        #expect(try await sut(pillTypeID: UUID(), day: today) == nil)
    }
}
