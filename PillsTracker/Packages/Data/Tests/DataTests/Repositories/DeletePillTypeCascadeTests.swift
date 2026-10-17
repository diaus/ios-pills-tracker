import Foundation
import SwiftData
import Testing
import Domain
@testable import Data

/// Deleting a Pill Type removes everything it owns via SwiftData delete rules (ticket 06).
struct DeletePillTypeCascadeTests {
    private let today = Day(year: 2026, month: 10, day: 6)

    private func makeRepositories() throws -> (ModelContainer, PillTypeRepositoryLive, IntakeRepositoryLive) {
        let container = try PillsModelContainer.make(inMemory: true)
        let notifier = DataChangeNotifier()
        return (
            container,
            PillTypeRepositoryLive(modelContainer: container, notifier: notifier),
            IntakeRepositoryLive(modelContainer: container, notifier: notifier)
        )
    }

    /// A Pill Type with a Prescription, one Retired and one Current Blister, and an Intake on each Blister.
    private func seed(_ pillTypes: PillTypeRepositoryLive, _ intakes: IntakeRepositoryLive, name: String) async throws -> PillTypeAggregate {
        var aggregate = try PillTypeAggregate.new(name: name, rows: 1, columns: 2, createdAt: Date(timeIntervalSince1970: 1_000))
        try aggregate.setPrescriptionSlots([.morning, .evening])
        let retired = Blister(pillTypeID: aggregate.id, shape: aggregate.pillType.shape, state: .retired, presentPositions: [])
        aggregate = aggregate.inserting(retired)
        try await pillTypes.create(aggregate)
        let currentID = try #require(aggregate.currentBlister?.id)
        try await intakes.create(Intake(pillTypeID: aggregate.id, blisterID: retired.id, position: Position(row: 0, column: 0), slot: .morning, day: Day(year: 2026, month: 10, day: 5), instant: Date(timeIntervalSince1970: 1_000)))
        try await intakes.create(Intake(pillTypeID: aggregate.id, blisterID: currentID, position: Position(row: 0, column: 0), slot: .morning, day: today, instant: Date(timeIntervalSince1970: 2_000)))
        return aggregate
    }

    private struct Counts: Equatable {
        var pillTypes: Int, blisters: Int, prescriptions: Int, intakes: Int
    }

    private func counts(in container: ModelContainer) throws -> Counts {
        let context = ModelContext(container)
        return Counts(
            pillTypes: try context.fetchCount(FetchDescriptor<PillTypeModel>()),
            blisters: try context.fetchCount(FetchDescriptor<BlisterModel>()),
            prescriptions: try context.fetchCount(FetchDescriptor<PrescriptionModel>()),
            intakes: try context.fetchCount(FetchDescriptor<IntakeModel>())
        )
    }

    @Test func deletingAPillTypeRemovesItsPrescriptionBlistersAndIntakes() async throws {
        let (container, pillTypes, intakes) = try makeRepositories()
        let aggregate = try await seed(pillTypes, intakes, name: "Aspirin")
        #expect(try counts(in: container) == Counts(pillTypes: 1, blisters: 2, prescriptions: 1, intakes: 2))

        try await pillTypes.delete(id: aggregate.id)

        #expect(try counts(in: container) == Counts(pillTypes: 0, blisters: 0, prescriptions: 0, intakes: 0))
        #expect(try await pillTypes.fetch(id: aggregate.id) == nil)
        #expect(try await intakes.fetch(day: today, pillTypeID: nil).isEmpty)
    }

    @Test func deletingOnePillTypeLeavesTheOthersIntact() async throws {
        let (container, pillTypes, intakes) = try makeRepositories()
        let doomed = try await seed(pillTypes, intakes, name: "Aspirin")
        let kept = try await seed(pillTypes, intakes, name: "Ibuprofen")

        try await pillTypes.delete(id: doomed.id)

        #expect(try counts(in: container) == Counts(pillTypes: 1, blisters: 2, prescriptions: 1, intakes: 2))
        // Blisters come back in no guaranteed order (an unordered to-many relationship), so compare them as a Set.
        let fetched = try #require(try await pillTypes.fetch(id: kept.id))
        #expect(fetched.pillType == kept.pillType)
        #expect(fetched.prescription == kept.prescription)
        #expect(Set(fetched.blisters) == Set(kept.blisters))
        #expect(try await intakes.fetch(day: today, pillTypeID: kept.id).count == 1)
    }

    @Test func deletingAnUnknownPillTypeIsANoOp() async throws {
        let (container, pillTypes, intakes) = try makeRepositories()
        _ = try await seed(pillTypes, intakes, name: "Aspirin")

        try await pillTypes.delete(id: UUID())

        #expect(try counts(in: container) == Counts(pillTypes: 1, blisters: 2, prescriptions: 1, intakes: 2))
    }
}
