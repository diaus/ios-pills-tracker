import Foundation
import Testing
import Domain
@testable import Data

struct IntakePersistenceTests {
    private let today = Day(year: 2026, month: 10, day: 6)

    private func makeRepositories() throws -> (PillTypeRepositoryLive, IntakeRepositoryLive) {
        let container = try PillsModelContainer.make(inMemory: true)
        let notifier = DataChangeNotifier()
        return (
            PillTypeRepositoryLive(modelContainer: container, notifier: notifier),
            IntakeRepositoryLive(modelContainer: container, notifier: notifier)
        )
    }

    private func makeAggregate() throws -> PillTypeAggregate {
        var aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 1, columns: 2, createdAt: Date(timeIntervalSince1970: 1_000))
        try aggregate.setPrescriptionSlots([.morning, .evening])
        return aggregate
    }

    @Test func intakeRoundTripsWithItsExplicitDay() async throws {
        let (pillTypes, intakes) = try makeRepositories()
        let aggregate = try makeAggregate()
        try await pillTypes.create(aggregate)
        // 2026-10-05 23:30 UTC, which is already the 6th east of UTC: the stored Day is the one the user
        // experienced, never derived from the instant (ADR 0001).
        let intake = Intake(
            pillTypeID: aggregate.id,
            blisterID: try #require(aggregate.currentBlister?.id),
            position: Position(row: 0, column: 1),
            slot: .evening,
            day: today,
            instant: Date(timeIntervalSince1970: 1_791_243_000)
        )

        try await intakes.create(intake)

        #expect(try await intakes.fetch(id: intake.id) == intake)
        #expect(try await intakes.fetch(day: today, pillTypeID: nil) == [intake])
        #expect(try await intakes.fetch(day: today, pillTypeID: aggregate.id) == [intake])
        #expect(try await intakes.fetch(day: Day(year: 2026, month: 10, day: 5), pillTypeID: nil).isEmpty)
        #expect(try await intakes.fetch(day: today, pillTypeID: UUID()).isEmpty)
    }

    @Test func fetchForADayIsOrderedByInstant() async throws {
        let (pillTypes, intakes) = try makeRepositories()
        let aggregate = try makeAggregate()
        try await pillTypes.create(aggregate)
        let blisterID = try #require(aggregate.currentBlister?.id)
        let later = Intake(pillTypeID: aggregate.id, blisterID: blisterID, position: Position(row: 0, column: 1), slot: .evening, day: today, instant: Date(timeIntervalSince1970: 2_000))
        let earlier = Intake(pillTypeID: aggregate.id, blisterID: blisterID, position: Position(row: 0, column: 0), slot: .morning, day: today, instant: Date(timeIntervalSince1970: 1_000))

        try await intakes.create(later)
        try await intakes.create(earlier)

        #expect(try await intakes.fetch(day: today, pillTypeID: nil) == [earlier, later])
    }

    @Test func deleteRemovesOnlyThatIntake() async throws {
        let (pillTypes, intakes) = try makeRepositories()
        let aggregate = try makeAggregate()
        try await pillTypes.create(aggregate)
        let blisterID = try #require(aggregate.currentBlister?.id)
        let first = Intake(pillTypeID: aggregate.id, blisterID: blisterID, position: Position(row: 0, column: 0), slot: .morning, day: today, instant: Date(timeIntervalSince1970: 1_000))
        let second = Intake(pillTypeID: aggregate.id, blisterID: blisterID, position: Position(row: 0, column: 1), slot: .evening, day: today, instant: Date(timeIntervalSince1970: 2_000))
        try await intakes.create(first)
        try await intakes.create(second)

        try await intakes.delete(id: first.id)

        #expect(try await intakes.fetch(day: today, pillTypeID: nil) == [second])
        #expect(try await intakes.fetch(id: first.id) == nil)
    }

    @Test func creatingAnIntakeForAnUnknownPillTypeFails() async throws {
        let (_, intakes) = try makeRepositories()
        let intake = Intake(pillTypeID: UUID(), blisterID: UUID(), position: Position(row: 0, column: 0), slot: .morning, day: today, instant: .now)

        await #expect(throws: DataError.notFound) {
            try await intakes.create(intake)
        }
    }

    @Test func intakesRemainAfterTheirBlisterIsRetired() async throws {
        let (pillTypes, intakes) = try makeRepositories()
        var aggregate = try makeAggregate()
        try await pillTypes.create(aggregate)
        let oldBlisterID = try #require(aggregate.currentBlister?.id)
        let intake = try await Consume(pillTypes: pillTypes, intakes: intakes)(
            pillTypeID: aggregate.id, position: Position(row: 0, column: 0), slot: .morning, day: today, instant: Date(timeIntervalSince1970: 1_000)
        )
        aggregate = try #require(try await pillTypes.fetch(id: aggregate.id))
        aggregate.blisters[0].presentPositions = []
        try await pillTypes.update(aggregate)

        try await StartNewBlister(repository: pillTypes)(pillTypeID: aggregate.id)

        let fetched = try #require(try await intakes.fetch(id: intake.id))
        #expect(fetched == intake)
        #expect(fetched.blisterID == oldBlisterID)
        let stored = try #require(try await pillTypes.fetch(id: aggregate.id))
        #expect(stored.blisters.first { $0.id == oldBlisterID }?.state == .retired)
    }

    @Test func intakesSurviveDeletingThePrescription() async throws {
        let (pillTypes, intakes) = try makeRepositories()
        var aggregate = try makeAggregate()
        try await pillTypes.create(aggregate)
        let intake = Intake(pillTypeID: aggregate.id, blisterID: try #require(aggregate.currentBlister?.id), position: Position(row: 0, column: 0), slot: .morning, day: today, instant: Date(timeIntervalSince1970: 1_000))
        try await intakes.create(intake)

        aggregate.removePrescription()
        try await pillTypes.update(aggregate)

        #expect(try await intakes.fetch(id: intake.id) == intake)
    }

    @Test func createNotifiesTheSharedChangeStream() async throws {
        let (pillTypes, intakes) = try makeRepositories()
        let aggregate = try makeAggregate()
        try await pillTypes.create(aggregate)
        let stream = await pillTypes.changes
        var iterator = stream.makeAsyncIterator()

        try await intakes.create(Intake(pillTypeID: aggregate.id, blisterID: try #require(aggregate.currentBlister?.id), position: Position(row: 0, column: 0), slot: .morning, day: today, instant: .now))

        #expect(await iterator.next() != nil)
    }
}
