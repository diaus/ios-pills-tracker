import Foundation
import Testing
@testable import Domain

/// Editing a Pill Type: rename and grid shape change (ticket 06).
struct EditPillTypeTests {
    private func makeAggregate() throws -> PillTypeAggregate {
        try PillTypeAggregate.new(name: "Aspirin", rows: 2, columns: 2, createdAt: Date(timeIntervalSince1970: 0))
    }

    // MARK: Rename

    @Test func renameTrimsAndStoresTheNewName() throws {
        var aggregate = try makeAggregate()
        try aggregate.rename("  Ibuprofen ")
        #expect(aggregate.pillType.name == "Ibuprofen")
    }

    @Test func renameRejectsAnEmptyName() throws {
        var aggregate = try makeAggregate()
        #expect(throws: DomainError.emptyName) { try aggregate.rename("   ") }
        #expect(aggregate.pillType.name == "Aspirin")
    }

    // MARK: Change shape

    @Test func changeShapeIsRefusedWhileTheCurrentBlisterHasAPresentPosition() throws {
        var aggregate = try makeAggregate()
        aggregate.blisters[0].presentPositions = [Position(row: 0, column: 0)]
        let before = aggregate

        #expect(throws: DomainError.currentBlisterNotEmpty) {
            try aggregate.changeShape(GridShape(rows: 3, columns: 4))
        }
        #expect(aggregate == before)
    }

    @Test func changeShapeIsAllowedWhenTheCurrentBlisterIsEmpty() throws {
        var aggregate = try makeAggregate()
        aggregate.blisters[0].presentPositions = []

        let newShape = try GridShape(rows: 3, columns: 4)
        try aggregate.changeShape(newShape)

        #expect(aggregate.pillType.shape == newShape)
    }

    @Test func changedShapeAppliesToTheNextStartNewBlisterNotToTheEmptyCurrentOne() async throws {
        var aggregate = try makeAggregate()
        aggregate.blisters[0].presentPositions = []
        let emptyCurrent = aggregate.blisters[0]
        let oldShape = try GridShape(rows: 2, columns: 2)
        let newShape = try GridShape(rows: 3, columns: 4)
        try aggregate.changeShape(newShape)
        let repository = FakePillTypeRepository([aggregate])

        // The empty Current Blister is untouched by the shape change and keeps its own 2×2 geometry.
        let stored = try #require(await repository.fetch(id: aggregate.id))
        #expect(stored.currentBlister == emptyCurrent)
        #expect(stored.currentBlister?.shape == oldShape)
        #expect(stored.pillType.shape == newShape)

        try await StartNewBlister(repository: repository)(pillTypeID: aggregate.id)

        let after = try #require(await repository.fetch(id: aggregate.id))
        let retired = try #require(after.blisters.first { $0.id == emptyCurrent.id })
        #expect(retired.state == .retired)
        #expect(retired.presentPositions.isEmpty)
        #expect(retired.shape == oldShape)
        let fresh = try #require(after.currentBlister)
        #expect(fresh.presentPositions.count == 12)
        #expect(fresh.shape == newShape)
        #expect(fresh.presentPositions == Set(newShape.allPositions))
    }
}
