import Foundation
import Testing
@testable import Domain

struct UpdatePillTypeTests {
    private func makeAggregate() throws -> PillTypeAggregate {
        try PillTypeAggregate.new(name: "Aspirin", rows: 1, columns: 3, createdAt: Date(timeIntervalSince1970: 0))
    }

    @Test func appliesTheChangeToTheStoredPillTypeAndReturnsIt() async throws {
        let stored = try makeAggregate()
        let repository = FakePillTypeRepository([stored])
        // The stored Blister moved on since a screen read its copy; the change must not undo that.
        var newer = stored
        try newer.syncPosition(Position(row: 0, column: 0), isPresent: false)
        try await repository.update(newer)

        let updated = try await UpdatePillType(repository: repository)(pillTypeID: stored.id) { aggregate throws(DomainError) in
            try aggregate.setPrescriptionSlots([.evening])
        }

        #expect(updated.prescription?.slots == [.evening])
        #expect(updated.currentBlister == newer.currentBlister)
        #expect(await repository.fetch(id: stored.id) == updated)
    }

    @Test func aBrokenRuleStoresNothing() async throws {
        let stored = try makeAggregate()
        let repository = FakePillTypeRepository([stored])

        await #expect(throws: DomainError.emptyName) {
            try await UpdatePillType(repository: repository)(pillTypeID: stored.id) { aggregate throws(DomainError) in
                try aggregate.rename(" ")
            }
        }
        #expect(await repository.fetch(id: stored.id) == stored)
    }

    @Test func throwsForUnknownPillType() async throws {
        await #expect(throws: DomainError.pillTypeNotFound) {
            try await UpdatePillType(repository: FakePillTypeRepository())(pillTypeID: UUID()) { _ throws(DomainError) in }
        }
    }
}
