import Foundation
import Testing
import Domain
@testable import Data
import Utils

struct IntakePersistenceTests {
    private let today = Day(year: 2026, month: 10, day: 6)

    private func makeRepository() throws -> (PillTypeRepositoryLive, ChangeNotifier) {
        let notifier = ChangeNotifier()
        return (PillTypeRepositoryLive(modelContainer: try PillsModelContainer.make(inMemory: true), notifier: notifier), notifier)
    }

    private func makeAggregate() throws -> PillTypeAggregate {
        var aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 1, columns: 2, createdAt: Date(timeIntervalSince1970: 1_000))
        try aggregate.setPrescriptionSlots([.morning, .evening])
        return aggregate
    }

    @Test func consumeStoresTheEmptyPositionAndTheIntakeWithItsExplicitDay() async throws {
        let (repository, _) = try makeRepository()
        var aggregate = try makeAggregate()
        try await repository.create(aggregate)
        // 2026-10-05 23:30 UTC, which is already the 6th east of UTC: the stored Day is the one the user
        // experienced, never derived from the instant (ADR 0001).
        let intake = try aggregate.consume(Position(row: 0, column: 1), slot: .evening, doneSlots: [], day: today, instant: Date(timeIntervalSince1970: 1_791_243_000))

        try await repository.update(aggregate, recording: intake)

        #expect(try await repository.fetch(id: aggregate.id) == aggregate)
        #expect(try await repository.intake(id: intake.id) == intake)
        #expect(try await repository.intakes(on: today, pillTypeID: nil) == [intake])
        #expect(try await repository.intakes(on: today, pillTypeID: aggregate.id) == [intake])
        #expect(try await repository.intakes(on: Day(year: 2026, month: 10, day: 5), pillTypeID: nil).isEmpty)
        #expect(try await repository.intakes(on: today, pillTypeID: UUID()).isEmpty)
    }

    @Test func intakesForADayAreOrderedByInstant() async throws {
        let (repository, _) = try makeRepository()
        var aggregate = try makeAggregate()
        try await repository.create(aggregate)
        let later = try aggregate.consume(Position(row: 0, column: 1), slot: .evening, doneSlots: [], day: today, instant: Date(timeIntervalSince1970: 2_000))
        try await repository.update(aggregate, recording: later)
        let earlier = try aggregate.consume(Position(row: 0, column: 0), slot: .morning, doneSlots: [.evening], day: today, instant: Date(timeIntervalSince1970: 1_000))
        try await repository.update(aggregate, recording: earlier)

        #expect(try await repository.intakes(on: today, pillTypeID: nil) == [earlier, later])
    }

    @Test func undoStoresThePresentPositionAndRemovesOnlyThatIntake() async throws {
        let (repository, _) = try makeRepository()
        var aggregate = try makeAggregate()
        try await repository.create(aggregate)
        let first = try aggregate.consume(Position(row: 0, column: 0), slot: .morning, doneSlots: [], day: today, instant: Date(timeIntervalSince1970: 1_000))
        try await repository.update(aggregate, recording: first)
        let second = try aggregate.consume(Position(row: 0, column: 1), slot: .evening, doneSlots: [.morning], day: today, instant: Date(timeIntervalSince1970: 2_000))
        try await repository.update(aggregate, recording: second)

        try aggregate.undo(first, on: today)
        try await repository.update(aggregate, removing: first)

        #expect(try await repository.fetch(id: aggregate.id)?.currentBlister?.presentPositions == [Position(row: 0, column: 0)])
        #expect(try await repository.intakes(on: today, pillTypeID: nil) == [second])
        #expect(try await repository.intake(id: first.id) == nil)
    }

    @Test func recordingAnIntakeForAnUnknownPillTypeStoresNothing() async throws {
        let (repository, _) = try makeRepository()
        var aggregate = try makeAggregate()
        let intake = try aggregate.consume(Position(row: 0, column: 0), slot: .morning, doneSlots: [], day: today, instant: .now)

        await #expect(throws: DataError.notFound) {
            try await repository.update(aggregate, recording: intake)
        }
        #expect(try await repository.intakes(on: today, pillTypeID: nil).isEmpty)
    }

    @Test func intakesRemainAfterTheirBlisterIsRetired() async throws {
        let (repository, _) = try makeRepository()
        var aggregate = try makeAggregate()
        try await repository.create(aggregate)
        let oldBlisterID = try #require(aggregate.currentBlister?.id)
        let intake = try await Consume(repository: repository)(
            pillTypeID: aggregate.id, position: Position(row: 0, column: 0), slot: .morning, day: today, instant: Date(timeIntervalSince1970: 1_000)
        )
        aggregate = try #require(try await repository.fetch(id: aggregate.id))
        try aggregate.syncCurrentBlister(present: [])
        try await repository.update(aggregate)

        try await StartNewBlister(repository: repository)(pillTypeID: aggregate.id)

        let fetched = try #require(try await repository.intake(id: intake.id))
        #expect(fetched == intake)
        #expect(fetched.blisterID == oldBlisterID)
        let stored = try #require(try await repository.fetch(id: aggregate.id))
        #expect(stored.blisters.first { $0.id == oldBlisterID }?.state == .retired)
    }

    @Test func intakesSurviveDeletingThePrescription() async throws {
        let (repository, _) = try makeRepository()
        var aggregate = try makeAggregate()
        try await repository.create(aggregate)
        let intake = try aggregate.consume(Position(row: 0, column: 0), slot: .morning, doneSlots: [], day: today, instant: Date(timeIntervalSince1970: 1_000))
        try await repository.update(aggregate, recording: intake)

        aggregate.removePrescription()
        try await repository.update(aggregate)

        #expect(try await repository.intake(id: intake.id) == intake)
    }

    @Test func consumeNotifiesTheChangeStream() async throws {
        let (repository, notifier) = try makeRepository()
        var aggregate = try makeAggregate()
        try await repository.create(aggregate)
        var iterator = notifier.changes.makeAsyncIterator()

        let intake = try aggregate.consume(Position(row: 0, column: 0), slot: .morning, doneSlots: [], day: today, instant: .now)
        try await repository.update(aggregate, recording: intake)

        #expect(await iterator.next() != nil)
    }
}
