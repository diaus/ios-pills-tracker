import Foundation
import Testing
@testable import Domain

/// What a single Pill Type's progress means is covered by `PillTypeProgressTests`; this covers how
/// the use case assembles them.
struct DailyProgressTests {
    private let today = Day(year: 2026, month: 10, day: 6)

    private func makeAggregate(name: String, createdAt: TimeInterval) throws -> PillTypeAggregate {
        var aggregate = try PillTypeAggregate.new(name: name, rows: 1, columns: 3, createdAt: Date(timeIntervalSince1970: createdAt))
        try aggregate.setPrescriptionSlots([.morning])
        return aggregate
    }

    @Test func isOrderedByPillTypeCreationDate() async throws {
        let newer = try makeAggregate(name: "Newer", createdAt: 2_000)
        let older = try makeAggregate(name: "Older", createdAt: 1_000)
        let sut = DailyProgress(repository: FakePillTypeRepository([newer, older]))

        let all = try await sut(day: today)

        #expect(all.map(\.aggregate.pillType.name) == ["Older", "Newer"])
    }

    @Test func eachPillTypeGetsTheDaysIntakes() async throws {
        var consumed = try makeAggregate(name: "Aspirin", createdAt: 1_000)
        let untouched = try makeAggregate(name: "Vitamin", createdAt: 2_000)
        let intake = try consumed.consume(Position(row: 0, column: 0), slot: .morning, doneSlots: [], day: today, instant: .now)
        let sut = DailyProgress(repository: FakePillTypeRepository([consumed, untouched], intakes: [intake]))

        let all = try await sut(day: today)

        #expect(all.map(\.day) == [today, today])
        #expect(all.map(\.isCompleted) == [true, false])
    }
}
