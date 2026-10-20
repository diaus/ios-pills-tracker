import Foundation
import Testing
import Domain
@testable import Data
import Utils

struct PrescriptionPersistenceTests {
    private func makeRepository() throws -> PillTypeRepositoryLive {
        PillTypeRepositoryLive(modelContainer: try PillsModelContainer.make(inMemory: true), notifier: ChangeNotifier())
    }

    private func makeAggregate(slots: Set<Slot>) throws -> PillTypeAggregate {
        var aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 2, columns: 5, createdAt: Date(timeIntervalSince1970: 1_000))
        try aggregate.setPrescriptionSlots(slots)
        return aggregate
    }

    @Test func prescriptionRoundTripsWithItsPillType() async throws {
        let repository = try makeRepository()
        var aggregate = try makeAggregate(slots: [.morning, .evening])
        try aggregate.pausePrescription()

        try await repository.create(aggregate)
        let fetched = try #require(try await repository.fetch(id: aggregate.id))

        #expect(fetched == aggregate)
        #expect(fetched.prescription?.slots == [.morning, .evening])
        #expect(fetched.prescription?.state == .paused)
    }

    @Test func startDayAndEndDayRoundTripAndCanBeCleared() async throws {
        let repository = try makeRepository()
        var aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 1, columns: 1, createdAt: Date(timeIntervalSince1970: 1_000))
        try aggregate.setPrescription(slots: [.morning], startDay: Day(year: 2026, month: 9, day: 1), endDay: Day(year: 2026, month: 9, day: 30))
        try await repository.create(aggregate)
        #expect(try await repository.fetch(id: aggregate.id)?.prescription == aggregate.prescription)

        try aggregate.setPrescription(slots: [.morning], startDay: Day(year: 2026, month: 8, day: 15), endDay: nil)
        try await repository.update(aggregate)

        let fetched = try #require(try await repository.fetch(id: aggregate.id)?.prescription)
        #expect(fetched.startDay == Day(year: 2026, month: 8, day: 15))
        #expect(fetched.endDay == nil)
    }

    @Test func addingAPrescriptionToAnExistingPillTypePersists() async throws {
        let repository = try makeRepository()
        var aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 1, columns: 1, createdAt: Date(timeIntervalSince1970: 1_000))
        try await repository.create(aggregate)

        try aggregate.setPrescriptionSlots([.day])
        try await repository.update(aggregate)

        let fetched = try #require(try await repository.fetch(id: aggregate.id))
        #expect(fetched.prescription == aggregate.prescription)
    }

    @Test func editingSlotsAndStateKeepsTheSamePrescription() async throws {
        let repository = try makeRepository()
        var aggregate = try makeAggregate(slots: [.morning])
        try await repository.create(aggregate)

        try aggregate.setPrescriptionSlots([.day, .evening])
        try aggregate.pausePrescription()
        try await repository.update(aggregate)

        let fetched = try #require(try await repository.fetch(id: aggregate.id))
        #expect(fetched.prescription == aggregate.prescription)
        #expect(try await repository.fetchAll().count == 1)
    }

    @Test func removingThePrescriptionKeepsThePillTypeAndItsBlisters() async throws {
        let repository = try makeRepository()
        var aggregate = try makeAggregate(slots: [.morning])
        try await repository.create(aggregate)

        aggregate.removePrescription()
        try await repository.update(aggregate)

        let fetched = try #require(try await repository.fetch(id: aggregate.id))
        #expect(fetched.prescription == nil)
        #expect(fetched.pillType == aggregate.pillType)
        #expect(fetched.blisters == aggregate.blisters)
        #expect(try await repository.fetchAll().count == 1)
    }
}
