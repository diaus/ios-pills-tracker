import Foundation
import Testing
@testable import Domain

struct ConsumeTests {
    private let today = Day(year: 2026, month: 10, day: 6)
    private let instant = Date(timeIntervalSince1970: 1_791_000_000)
    private let position = Position(row: 0, column: 1)

    private func makeAggregate(slots: Set<Slot>? = [.morning, .evening]) throws -> PillTypeAggregate {
        var aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 1, columns: 3, createdAt: Date(timeIntervalSince1970: 0))
        if let slots { try aggregate.setPrescriptionSlots(slots) }
        return aggregate
    }

    private func makeSUT(_ aggregate: PillTypeAggregate, intakes: [Intake] = []) -> (Consume, FakePillTypeRepository) {
        let repository = FakePillTypeRepository([aggregate], intakes: intakes)
        return (Consume(repository: repository), repository)
    }

    @Test func emptiesThePositionAndRecordsAnIntakeForTheDay() async throws {
        let aggregate = try makeAggregate()
        let (sut, pillTypes) = makeSUT(aggregate)

        let intake = try await sut(pillTypeID: aggregate.id, position: position, slot: .morning, day: today, instant: instant)

        let current = try #require(await pillTypes.fetch(id: aggregate.id)?.currentBlister)
        #expect(current.id == aggregate.currentBlister?.id)
        #expect(!current.isPresent(position))
        #expect(current.presentPositions.count == 2)

        #expect(await pillTypes.allIntakes == [intake])
        #expect(intake.pillTypeID == aggregate.id)
        #expect(intake.blisterID == current.id)
        #expect(intake.position == position)
        #expect(intake.slot == .morning)
        #expect(intake.day == today)
        #expect(intake.instant == instant)
    }

    @Test func refusesAnEmptyPosition() async throws {
        var aggregate = try makeAggregate()
        try aggregate.syncPosition(position, isPresent: false)
        let (sut, pillTypes) = makeSUT(aggregate)

        await #expect(throws: DomainError.positionEmpty) {
            try await sut(pillTypeID: aggregate.id, position: position, slot: .morning, day: today, instant: instant)
        }
        #expect(await pillTypes.fetch(id: aggregate.id) == aggregate)
        #expect(await pillTypes.allIntakes.isEmpty)
    }

    @Test func refusesAPositionOutsideTheCurrentBlistersShape() async throws {
        let aggregate = try makeAggregate()
        let (sut, pillTypes) = makeSUT(aggregate)

        await #expect(throws: DomainError.positionOutOfBounds) {
            try await sut(pillTypeID: aggregate.id, position: Position(row: 1, column: 0), slot: .morning, day: today, instant: instant)
        }
        #expect(await pillTypes.fetch(id: aggregate.id) == aggregate)
        #expect(await pillTypes.allIntakes.isEmpty)
    }

    @Test func refusesASlotThatIsNotPrescribed() async throws {
        let aggregate = try makeAggregate(slots: [.morning])
        let (sut, pillTypes) = makeSUT(aggregate)

        await #expect(throws: DomainError.slotNotOpen) {
            try await sut(pillTypeID: aggregate.id, position: position, slot: .evening, day: today, instant: instant)
        }
        #expect(await pillTypes.allIntakes.isEmpty)
    }

    @Test func refusesASlotAlreadyDoneToday() async throws {
        let aggregate = try makeAggregate()
        let blisterID = try #require(aggregate.currentBlister?.id)
        let earlier = Intake(pillTypeID: aggregate.id, blisterID: blisterID, position: Position(row: 0, column: 0), slot: .morning, day: today, instant: instant)
        let (sut, pillTypes) = makeSUT(aggregate, intakes: [earlier])

        await #expect(throws: DomainError.slotNotOpen) {
            try await sut(pillTypeID: aggregate.id, position: position, slot: .morning, day: today, instant: instant)
        }
        #expect(await pillTypes.fetch(id: aggregate.id) == aggregate)
        #expect(await pillTypes.allIntakes == [earlier])
    }

    @Test func aSlotDoneYesterdayIsOpenToday() async throws {
        let aggregate = try makeAggregate()
        let blisterID = try #require(aggregate.currentBlister?.id)
        let yesterday = Intake(pillTypeID: aggregate.id, blisterID: blisterID, position: Position(row: 0, column: 0), slot: .morning, day: Day(year: 2026, month: 10, day: 5), instant: instant)
        let (sut, pillTypes) = makeSUT(aggregate, intakes: [yesterday])

        try await sut(pillTypeID: aggregate.id, position: position, slot: .morning, day: today, instant: instant)

        #expect(await pillTypes.allIntakes.count == 2)
    }

    @Test func refusesWithoutAPrescription() async throws {
        let aggregate = try makeAggregate(slots: nil)
        let (sut, _) = makeSUT(aggregate)

        await #expect(throws: DomainError.noActivePrescription) {
            try await sut(pillTypeID: aggregate.id, position: position, slot: .morning, day: today, instant: instant)
        }
    }

    @Test func refusesWhileThePrescriptionIsPaused() async throws {
        var aggregate = try makeAggregate()
        try aggregate.pausePrescription()
        let (sut, _) = makeSUT(aggregate)

        await #expect(throws: DomainError.noActivePrescription) {
            try await sut(pillTypeID: aggregate.id, position: position, slot: .morning, day: today, instant: instant)
        }
    }

    @Test func throwsForUnknownPillType() async throws {
        let sut = Consume(repository: FakePillTypeRepository())
        await #expect(throws: DomainError.pillTypeNotFound) {
            try await sut(pillTypeID: UUID(), position: position, slot: .morning, day: today, instant: instant)
        }
    }
}
