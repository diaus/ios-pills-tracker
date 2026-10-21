import Foundation
import SwiftData
import Testing
import Domain
@testable import Data
import Utils

struct PillTypeRepositoryLiveTests {
    private func makeRepository() throws -> (PillTypeRepositoryLive, ChangeNotifier) {
        let notifier = ChangeNotifier()
        let container = try PillsModelContainer.make(inMemory: true)
        return (PillTypeRepositoryLive(modelContainer: container, notifier: notifier), notifier)
    }

    @Test func pillTypeWithItsBlisterRoundTrips() async throws {
        let (repository, _) = try makeRepository()
        var aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 2, columns: 5, createdAt: Date(timeIntervalSince1970: 1_000))
        try aggregate.syncPosition(Position(row: 1, column: 4), isPresent: false, blisterIntakes: [])

        try await repository.create(aggregate)
        let fetched = try #require(try await repository.fetch(id: aggregate.id))

        #expect(fetched == aggregate)
    }

    @Test func abbreviationRoundTrips() async throws {
        let (repository, _) = try makeRepository()
        let aggregate = try PillTypeAggregate.new(name: "Aspirin", abbreviation: "ASA", rows: 1, columns: 1, createdAt: Date(timeIntervalSince1970: 1_000))

        try await repository.create(aggregate)
        let fetched = try #require(try await repository.fetch(id: aggregate.id))

        #expect(fetched.pillType.abbreviation == "ASA")
    }

    @Test func updateStoresAndClearsTheAbbreviation() async throws {
        let (repository, _) = try makeRepository()
        var aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 1, columns: 1, createdAt: Date(timeIntervalSince1970: 1_000))
        try await repository.create(aggregate)

        aggregate.setAbbreviation("ASA")
        try await repository.update(aggregate)
        #expect(try await repository.fetch(id: aggregate.id)?.pillType.abbreviation == "ASA")

        aggregate.setAbbreviation("")
        try await repository.update(aggregate)
        let fetched = try #require(try await repository.fetch(id: aggregate.id))
        #expect(fetched.pillType.abbreviation == nil)
    }

    @Test func eachBlisterKeepsItsOwnShape() async throws {
        let (repository, _) = try makeRepository()
        var aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 2, columns: 5, createdAt: Date(timeIntervalSince1970: 1_000))
        let oldShape = try GridShape(rows: 1, columns: 3)
        let retired = Blister(pillTypeID: aggregate.id, shape: oldShape, state: .retired, presentPositions: [])
        aggregate = PillTypeAggregate(pillType: aggregate.pillType, blisters: [retired] + aggregate.blisters)

        try await repository.create(aggregate)
        let fetched = try #require(try await repository.fetch(id: aggregate.id))

        #expect(fetched.pillType == aggregate.pillType)
        #expect(Set(fetched.blisters) == Set(aggregate.blisters))
        #expect(fetched.blisters.first { $0.id == retired.id }?.shape == oldShape)
        #expect(fetched.currentBlister?.shape == aggregate.pillType.shape)
    }

    /// Blisters written before they carried a shape have rows and columns 0; they use the Pill Type's shape.
    @Test func aBlisterStoredWithoutAShapeUsesThePillTypesShape() async throws {
        let container = try PillsModelContainer.make(inMemory: true)
        let repository = PillTypeRepositoryLive(modelContainer: container, notifier: ChangeNotifier())
        let pillTypeID = UUID()
        let blisterID = UUID()
        let context = ModelContext(container)
        let pillType = PillTypeModel(id: pillTypeID, name: "Aspirin", rows: 2, columns: 5, createdAt: Date(timeIntervalSince1970: 1_000))
        context.insert(pillType)
        pillType.blisters = [BlisterModel(id: blisterID, rows: 0, columns: 0, state: "current", presentPositions: [])]
        try context.save()

        let fetched = try #require(try await repository.fetch(id: pillTypeID))

        #expect(fetched.currentBlister?.id == blisterID)
        #expect(fetched.currentBlister?.shape == (try GridShape(rows: 2, columns: 5)))
    }

    @Test func fetchAllReturnsCreationDateOrder() async throws {
        let (repository, _) = try makeRepository()
        let later = try PillTypeAggregate.new(name: "Later", rows: 1, columns: 1, createdAt: Date(timeIntervalSince1970: 2_000))
        let earlier = try PillTypeAggregate.new(name: "Earlier", rows: 1, columns: 1, createdAt: Date(timeIntervalSince1970: 1_000))

        try await repository.create(later)
        try await repository.create(earlier)

        #expect(try await repository.fetchAll().map(\.pillType.name) == ["Earlier", "Later"])
    }

    @Test func fetchUnknownIDReturnsNil() async throws {
        let (repository, _) = try makeRepository()
        #expect(try await repository.fetch(id: UUID()) == nil)
    }

    @Test func updateStoresTheRenameTheRetiredBlisterAndTheNewOne() async throws {
        let (repository, _) = try makeRepository()
        var aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 1, columns: 2, createdAt: Date(timeIntervalSince1970: 1_000))
        try await repository.create(aggregate)

        try aggregate.pillType.rename("Ibuprofen")
        for position in aggregate.pillType.shape.allPositions {
            try aggregate.syncPosition(position, isPresent: false, blisterIntakes: [])
        }
        try aggregate.startNewBlister()
        try await repository.update(aggregate)

        let fetched = try #require(try await repository.fetch(id: aggregate.id))
        #expect(fetched.pillType.name == "Ibuprofen")
        #expect(fetched.blisters.count == 2)
        #expect(Set(fetched.blisters) == Set(aggregate.blisters))
        #expect(try await repository.fetchAll().count == 1)
    }

    @Test func deleteRemovesTheAggregate() async throws {
        let (repository, _) = try makeRepository()
        let aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 1, columns: 1, createdAt: Date(timeIntervalSince1970: 1_000))
        try await repository.create(aggregate)

        try await repository.delete(id: aggregate.id)

        #expect(try await repository.fetch(id: aggregate.id) == nil)
        #expect(try await repository.fetchAll().isEmpty)
    }

    @Test func everyWriteFiresTheChangeStream() async throws {
        let (repository, notifier) = try makeRepository()
        var iterator = notifier.changes.makeAsyncIterator()
        let aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 1, columns: 1, createdAt: Date(timeIntervalSince1970: 1_000))

        try await repository.create(aggregate)
        #expect(await iterator.next() != nil)

        try await repository.update(aggregate)
        #expect(await iterator.next() != nil)

        try await repository.delete(id: aggregate.id)
        #expect(await iterator.next() != nil)
    }
}
