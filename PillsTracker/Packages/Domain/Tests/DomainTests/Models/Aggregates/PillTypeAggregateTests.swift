import Foundation
import Testing
@testable import Domain

struct PillTypeAggregateTests {
    @Test func newPillTypeGetsACurrentBlisterWithEveryPositionPresent() throws {
        let aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 2, columns: 5, createdAt: Date(timeIntervalSince1970: 0))

        #expect(aggregate.pillType.name == "Aspirin")
        #expect(aggregate.pillType.shape.rows == 2)
        #expect(aggregate.pillType.shape.columns == 5)
        #expect(aggregate.blisters.count == 1)

        let current = try #require(aggregate.currentBlister)
        #expect(current.state == .current)
        #expect(current.pillTypeID == aggregate.pillType.id)
        #expect(current.presentPositions.count == 10)
        #expect(current.presentPositions == Set(aggregate.pillType.shape.allPositions))
        #expect(current.shape == aggregate.pillType.shape)
    }

    @Test func newPillTypeValidatesNameAndShape() {
        #expect(throws: DomainError.emptyName) { try PillTypeAggregate.new(name: "", rows: 2, columns: 5, createdAt: .init(timeIntervalSince1970: 0)) }
        #expect(throws: DomainError.invalidRows) { try PillTypeAggregate.new(name: "A", rows: 0, columns: 5, createdAt: .init(timeIntervalSince1970: 0)) }
        #expect(throws: DomainError.invalidColumns) { try PillTypeAggregate.new(name: "A", rows: 2, columns: 11, createdAt: .init(timeIntervalSince1970: 0)) }
    }

    @Test func currentBlisterIgnoresRetiredOnes() throws {
        var aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 1, columns: 2, createdAt: Date(timeIntervalSince1970: 0))
        let retired = Blister(pillTypeID: aggregate.pillType.id, shape: aggregate.pillType.shape, state: .retired, presentPositions: [])
        aggregate = aggregate.inserting(retired)
        #expect(aggregate.currentBlister?.state == .current)
    }
}
