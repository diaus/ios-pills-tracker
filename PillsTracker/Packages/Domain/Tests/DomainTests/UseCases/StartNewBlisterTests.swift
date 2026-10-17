import Foundation
import Testing
@testable import Domain

struct StartNewBlisterTests {
    private func makeAggregate() throws -> PillTypeAggregate {
        try PillTypeAggregate.new(name: "Aspirin", rows: 2, columns: 2, createdAt: Date(timeIntervalSince1970: 0))
    }

    @Test func refusesWhileAnyPositionIsPresent() async throws {
        var aggregate = try makeAggregate()
        try aggregate.syncCurrentBlister(present: [Position(row: 1, column: 1)])
        let repository = FakePillTypeRepository([aggregate])
        let sut = StartNewBlister(repository: repository)

        await #expect(throws: UseCaseError.blisterNotEmpty) {
            try await sut(pillTypeID: aggregate.id)
        }
        #expect(await repository.fetch(id: aggregate.id) == aggregate)
    }

    @Test func retiresTheEmptyCurrentBlisterAndStartsAFullOne() async throws {
        var aggregate = try makeAggregate()
        try aggregate.syncCurrentBlister(present: [])
        let oldBlister = try #require(aggregate.currentBlister)
        let repository = FakePillTypeRepository([aggregate])
        let sut = StartNewBlister(repository: repository)

        try await sut(pillTypeID: aggregate.id)

        let stored = try #require(await repository.fetch(id: aggregate.id))
        #expect(stored.pillType == aggregate.pillType)
        #expect(stored.blisters.count == 2)

        let retired = try #require(stored.blisters.first { $0.id == oldBlister.id })
        #expect(retired.state == .retired)
        #expect(retired.presentPositions.isEmpty)

        let current = try #require(stored.currentBlister)
        #expect(current.id != oldBlister.id)
        #expect(current.pillTypeID == aggregate.id)
        #expect(current.presentPositions == Set(aggregate.pillType.shape.allPositions))
        #expect(current.presentPositions.count == 4)
    }

    @Test func retiredBlisterKeepsItsFinalGridWhenAnotherIsRetiredLater() async throws {
        var aggregate = try makeAggregate()
        let earlier = Blister(pillTypeID: aggregate.id, shape: aggregate.pillType.shape, state: .retired, presentPositions: [Position(row: 0, column: 0)])
        aggregate = aggregate.inserting(earlier)
        try aggregate.syncCurrentBlister(present: [])
        let repository = FakePillTypeRepository([aggregate])
        let sut = StartNewBlister(repository: repository)

        try await sut(pillTypeID: aggregate.id)

        let stored = try #require(await repository.fetch(id: aggregate.id))
        #expect(stored.blisters.first { $0.id == earlier.id } == earlier)
        #expect(stored.blisters.filter { $0.state == .current }.count == 1)
        #expect(stored.blisters.count == 3)
    }

    @Test func throwsForUnknownPillType() async throws {
        let sut = StartNewBlister(repository: FakePillTypeRepository())
        await #expect(throws: UseCaseError.pillTypeNotFound) {
            try await sut(pillTypeID: UUID())
        }
    }
}
