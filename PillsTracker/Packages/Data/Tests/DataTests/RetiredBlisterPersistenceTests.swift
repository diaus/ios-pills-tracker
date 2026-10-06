import Foundation
import Testing
import Domain
@testable import Data

/// Retired Blisters must survive in Data after Start New Blister, keeping their final grid.
struct RetiredBlisterPersistenceTests {
    @Test func startNewBlisterKeepsTheRetiredBlisterWithItsFinalGrid() async throws {
        let container = try PillsModelContainer.make(inMemory: true)
        let repository = PillTypeRepositoryLive(modelContainer: container, notifier: DataChangeNotifier())
        var aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 1, columns: 2, createdAt: Date(timeIntervalSince1970: 1_000))
        aggregate.blisters[0].presentPositions = []
        let oldID = aggregate.blisters[0].id
        try await repository.create(aggregate)

        try await StartNewBlister(repository: repository)(pillTypeID: aggregate.id)

        let fetched = try #require(try await repository.fetch(id: aggregate.id))
        #expect(fetched.blisters.count == 2)
        let retired = try #require(fetched.blisters.first { $0.id == oldID })
        #expect(retired.state == .retired)
        #expect(retired.presentPositions.isEmpty)
        #expect(fetched.currentBlister?.presentPositions.count == 2)
    }
}
