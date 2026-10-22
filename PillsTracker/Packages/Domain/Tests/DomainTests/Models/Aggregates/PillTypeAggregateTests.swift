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

    // MARK: Start New Blister

    @Test func startNewBlisterRefusesWhileAnyPositionIsPresent() throws {
        var aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 2, columns: 2, createdAt: Date(timeIntervalSince1970: 0))
        try aggregate.syncCurrentBlister(present: [Position(row: 1, column: 1)])
        let before = aggregate

        #expect(throws: DomainError.currentBlisterNotEmpty) { try aggregate.startNewBlister() }
        #expect(aggregate == before)
    }

    @Test func startNewBlisterRetiresTheEmptyCurrentBlisterAndStartsAFullOne() throws {
        var aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 2, columns: 2, createdAt: Date(timeIntervalSince1970: 0))
        try aggregate.syncCurrentBlister(present: [])
        let oldBlister = try #require(aggregate.currentBlister)

        try aggregate.startNewBlister()

        #expect(aggregate.blisters.count == 2)
        let retired = try #require(aggregate.blisters.first { $0.id == oldBlister.id })
        #expect(retired.state == .retired)
        #expect(retired.presentPositions.isEmpty)
        let current = try #require(aggregate.currentBlister)
        #expect(current.id != oldBlister.id)
        #expect(current.pillTypeID == aggregate.id)
        #expect(current.presentPositions == Set(aggregate.pillType.shape.allPositions))
        #expect(current.presentPositions.count == 4)
    }

    @Test func aRetiredBlisterKeepsItsFinalGridWhenAnotherIsRetiredLater() throws {
        var aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 2, columns: 2, createdAt: Date(timeIntervalSince1970: 0))
        let earlier = Blister(pillTypeID: aggregate.id, shape: aggregate.pillType.shape, state: .retired, presentPositions: [Position(row: 0, column: 0)])
        aggregate = aggregate.inserting(earlier)
        try aggregate.syncCurrentBlister(present: [])

        try aggregate.startNewBlister()

        #expect(aggregate.blisters.first { $0.id == earlier.id } == earlier)
        #expect(aggregate.blisters.filter { $0.state == .current }.count == 1)
        #expect(aggregate.blisters.count == 3)
    }

    // MARK: Undo

    private let position = Position(row: 0, column: 1)

    private func makeConsumable() throws -> PillTypeAggregate {
        var aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 1, columns: 3, createdAt: Date(timeIntervalSince1970: 0))
        try aggregate.setPrescriptionSlots([.morning, .evening])
        return aggregate
    }

    @Test func undoesAnIntakeFromAnEarlierDayOnTheCurrentBlister() throws {
        var aggregate = try makeConsumable()
        let lastWeek = try aggregate.consume(position, slot: .morning, doneSlots: [], day: Day(year: 2026, month: 9, day: 29), instant: Date(timeIntervalSince1970: 1))

        try aggregate.undo(lastWeek, blisterIntakes: [lastWeek])

        #expect(aggregate.currentBlister?.isPresent(position) == true)
    }

    @Test func undoesOnlyTheLatestIntakeAtAPosition() throws {
        var aggregate = try makeConsumable()
        let day = Day(year: 2026, month: 10, day: 6)
        let morning = try aggregate.consume(position, slot: .morning, doneSlots: [], day: day, instant: Date(timeIntervalSince1970: 1))
        // A Position Present again with an Intake predates the Sync Edit rule, so it is built directly.
        aggregate = PillTypeAggregate(
            pillType: aggregate.pillType,
            blisters: aggregate.blisters.map { blister in
                var blister = blister
                blister.presentPositions.insert(position)
                return blister
            },
            prescription: aggregate.prescription
        )
        let evening = try aggregate.consume(position, slot: .evening, doneSlots: [.morning], day: day, instant: Date(timeIntervalSince1970: 2))

        #expect(throws: DomainError.undoNotAllowed) {
            try aggregate.undo(morning, blisterIntakes: [morning, evening])
        }
        #expect(aggregate.canUndo(evening, blisterIntakes: [morning, evening]))
    }

    // MARK: Sync Edit

    @Test func syncEditCannotSetPresentAPositionWithAnIntake() throws {
        var aggregate = try makeConsumable()
        let intake = try aggregate.consume(position, slot: .morning, doneSlots: [], day: Day(year: 2026, month: 10, day: 6), instant: Date(timeIntervalSince1970: 1))

        #expect(throws: DomainError.positionHasIntake) {
            try aggregate.syncPosition(position, isPresent: true, blisterIntakes: [intake])
        }
        #expect(aggregate.currentBlister?.isPresent(position) == false)
    }
}
