import Foundation
import Testing
@testable import Domain

/// What a Day of the history means is covered by `PillTypeHistoryTests`; this covers how the use case
/// assembles one.
struct IntakeHistoryTests {
    private let today = Day(year: 2026, month: 10, day: 20)
    private let yesterday = Day(year: 2026, month: 10, day: 19)
    private let october = Day(year: 2026, month: 10, day: 1)...Day(year: 2026, month: 10, day: 31)

    @Test func includesIntakesFromRetiredBlistersAndJudgesThemAgainstThePrescription() async throws {
        var aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 1, columns: 1, createdAt: Date(timeIntervalSince1970: 0))
        try aggregate.setPrescriptionSlots([.morning])
        let retiredIntake = try aggregate.consume(Position(row: 0, column: 0), slot: .morning, doneSlots: [], day: yesterday, instant: .now)
        try aggregate.startNewBlister()
        let sut = IntakeHistory(repository: FakePillTypeRepository([aggregate], intakes: [retiredIntake]))

        let history = try #require(try await sut(pillTypeID: aggregate.id, days: october, today: today))

        #expect(history.day(yesterday).intakeCount == 1)
        #expect(history.day(yesterday).isCompleted == true)
    }

    @Test func leavesOutOtherPillTypesIntakes() async throws {
        let aspirin = try PillTypeAggregate.new(name: "Aspirin", rows: 1, columns: 1, createdAt: Date(timeIntervalSince1970: 0))
        var vitamin = try PillTypeAggregate.new(name: "Vitamin", rows: 1, columns: 1, createdAt: Date(timeIntervalSince1970: 1))
        try vitamin.setPrescriptionSlots([.morning])
        let vitaminIntake = try vitamin.consume(Position(row: 0, column: 0), slot: .morning, doneSlots: [], day: yesterday, instant: .now)
        let sut = IntakeHistory(repository: FakePillTypeRepository([aspirin, vitamin], intakes: [vitaminIntake]))

        let history = try #require(try await sut(pillTypeID: aspirin.id, days: october, today: today))

        #expect(history.day(yesterday).intakeCount == 0)
    }

    @Test func isNilForAPillTypeThatNoLongerExists() async throws {
        let sut = IntakeHistory(repository: FakePillTypeRepository())

        #expect(try await sut(pillTypeID: UUID(), days: october, today: today) == nil)
    }
}
