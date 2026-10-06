import Foundation
import Testing
@testable import Domain

struct SyncPositionTests {
    private let position = Position(row: 0, column: 1)

    private func makeAggregate() throws -> PillTypeAggregate {
        try PillTypeAggregate.new(name: "Aspirin", rows: 1, columns: 3, createdAt: Date(timeIntervalSince1970: 0))
    }

    @Test func marksAPresentPositionEmptyAndTouchesNothingElse() async throws {
        let aggregate = try makeAggregate()
        let repository = FakePillTypeRepository([aggregate])
        let sut = SyncPosition(repository: repository)

        try await sut(pillTypeID: aggregate.id, position: position, isPresent: false)

        let stored = try #require(await repository.fetch(id: aggregate.id))
        let current = try #require(stored.currentBlister)
        #expect(current.id == aggregate.currentBlister?.id)
        #expect(!current.isPresent(position))
        #expect(current.presentPositions == [Position(row: 0, column: 0), Position(row: 0, column: 2)])
        #expect(stored.pillType == aggregate.pillType)
        #expect(stored.blisters.count == 1)
    }

    @Test func marksAnEmptyPositionPresent() async throws {
        var aggregate = try makeAggregate()
        aggregate.blisters[0].presentPositions = []
        let repository = FakePillTypeRepository([aggregate])
        let sut = SyncPosition(repository: repository)

        try await sut(pillTypeID: aggregate.id, position: position, isPresent: true)

        let current = try #require(await repository.fetch(id: aggregate.id)?.currentBlister)
        #expect(current.presentPositions == [position])
    }

    @Test func leavesRetiredBlistersAlone() async throws {
        var aggregate = try makeAggregate()
        let retired = Blister(pillTypeID: aggregate.id, shape: aggregate.pillType.shape, state: .retired, presentPositions: [position])
        aggregate.blisters.insert(retired, at: 0)
        let repository = FakePillTypeRepository([aggregate])
        let sut = SyncPosition(repository: repository)

        try await sut(pillTypeID: aggregate.id, position: position, isPresent: false)

        let stored = try #require(await repository.fetch(id: aggregate.id))
        #expect(stored.blisters.first { $0.id == retired.id } == retired)
        #expect(stored.currentBlister?.isPresent(position) == false)
    }

    @Test(arguments: [Position(row: 1, column: 0), Position(row: 0, column: 3), Position(row: -1, column: 0)])
    func refusesAPositionOutsideTheCurrentBlistersShape(outside: Position) async throws {
        let aggregate = try makeAggregate()
        let repository = FakePillTypeRepository([aggregate])
        let sut = SyncPosition(repository: repository)

        await #expect(throws: UseCaseError.positionOutOfBounds) {
            try await sut(pillTypeID: aggregate.id, position: outside, isPresent: true)
        }
        #expect(await repository.fetch(id: aggregate.id) == aggregate)
    }

    @Test func createsNoIntakeAndLeavesExistingOnesUntouched() async throws {
        let aggregate = try makeAggregate()
        let intake = Intake(pillTypeID: aggregate.id, blisterID: aggregate.blisters[0].id, position: Position(row: 0, column: 0), slot: .morning, day: Day(year: 2026, month: 10, day: 6), instant: Date(timeIntervalSince1970: 1_791_243_000))
        let intakes = FakeIntakeRepository([intake])
        let sut = SyncPosition(repository: FakePillTypeRepository([aggregate]))

        try await sut(pillTypeID: aggregate.id, position: position, isPresent: false)
        try await sut(pillTypeID: aggregate.id, position: Position(row: 0, column: 0), isPresent: true)

        #expect(await intakes.all == [intake])
    }

    @Test func throwsForUnknownPillType() async throws {
        let repository = FakePillTypeRepository()
        let sut = SyncPosition(repository: repository)

        await #expect(throws: UseCaseError.pillTypeNotFound) {
            try await sut(pillTypeID: UUID(), position: position, isPresent: true)
        }
    }
}
