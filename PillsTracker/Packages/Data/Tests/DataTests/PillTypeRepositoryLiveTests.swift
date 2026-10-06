import Foundation
import SwiftData
import Testing
import Domain
@testable import Data

struct PillTypeRepositoryLiveTests {
    private func makeRepository() throws -> (PillTypeRepositoryLive, DataChangeNotifier) {
        let notifier = DataChangeNotifier()
        let container = try PillsModelContainer.make(inMemory: true)
        return (PillTypeRepositoryLive(modelContainer: container, notifier: notifier), notifier)
    }

    @Test func pillTypeWithItsBlisterRoundTrips() async throws {
        let (repository, _) = try makeRepository()
        var aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 2, columns: 5, createdAt: Date(timeIntervalSince1970: 1_000))
        aggregate.blisters[0].presentPositions.remove(Position(row: 1, column: 4))

        try await repository.create(aggregate)
        let fetched = try #require(try await repository.fetch(id: aggregate.id))

        #expect(fetched == aggregate)
    }

    @Test func eachBlisterKeepsItsOwnShape() async throws {
        let (repository, _) = try makeRepository()
        var aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 2, columns: 5, createdAt: Date(timeIntervalSince1970: 1_000))
        let oldShape = try GridShape(rows: 1, columns: 3)
        let retired = Blister(pillTypeID: aggregate.id, shape: oldShape, state: .retired, presentPositions: [])
        aggregate.blisters.insert(retired, at: 0)

        try await repository.create(aggregate)
        let fetched = try #require(try await repository.fetch(id: aggregate.id))

        #expect(fetched == aggregate)
        #expect(fetched.blisters.first { $0.id == retired.id }?.shape == oldShape)
        #expect(fetched.currentBlister?.shape == aggregate.pillType.shape)
    }

    /// Blisters written before they carried a shape have rows and columns 0; they take the Pill Type's shape.
    @Test func aBlisterStoredWithoutAShapeTakesThePillTypesShape() async throws {
        let container = try PillsModelContainer.make(inMemory: true)
        let repository = PillTypeRepositoryLive(modelContainer: container, notifier: DataChangeNotifier())
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

    @Test func updateReplacesPillTypeAndBlisters() async throws {
        let (repository, _) = try makeRepository()
        var aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 1, columns: 2, createdAt: Date(timeIntervalSince1970: 1_000))
        try await repository.create(aggregate)

        try aggregate.pillType.rename("Ibuprofen")
        aggregate.blisters[0].state = .retired
        aggregate.blisters[0].presentPositions = []
        aggregate.blisters.append(.fresh(pillTypeID: aggregate.id, shape: aggregate.pillType.shape))
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
        let (repository, _) = try makeRepository()
        var iterator = await repository.changes.makeAsyncIterator()
        let aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 1, columns: 1, createdAt: Date(timeIntervalSince1970: 1_000))

        try await repository.create(aggregate)
        #expect(await iterator.next() != nil)

        try await repository.update(aggregate)
        #expect(await iterator.next() != nil)

        try await repository.delete(id: aggregate.id)
        #expect(await iterator.next() != nil)
    }
}
