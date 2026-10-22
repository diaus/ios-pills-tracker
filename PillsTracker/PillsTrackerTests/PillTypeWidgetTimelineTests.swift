import Data
import Domain
import Foundation
import Testing
import WidgetKit
@testable import PillsTracker

/// The widget's entries from the App Group store. `PillTypeWidgetTimeline` is compiled in from the widget's sources.
@MainActor
struct PillTypeWidgetTimelineTests {
    /// 2026-10-06 12:00 UTC: a moment well clear of any 03:00 rollover in any time zone.
    private let now = Date(timeIntervalSince1970: 1_791_288_000)
    private var today: Day { Day.current(at: now, calendar: .current) }
    private var nextRollover: Date { Day.nextRollover(after: now, calendar: .current)! }

    private func makeRepository() throws -> PillTypeRepositoryLive {
        PillTypeRepositoryLive(modelContainer: try PillsModelContainer.make(inMemory: true))
    }

    /// Vitamin D ("Vi"), Morning and Evening, every Position Present.
    private func makeAggregate() throws -> PillTypeAggregate {
        var aggregate = try PillTypeAggregate.new(name: "Vitamin D", rows: 2, columns: 2, createdAt: Date(timeIntervalSince1970: 0))
        try aggregate.setPrescription(slots: [.morning, .evening], startDay: Day(year: 2026, month: 1, day: 1), endDay: nil)
        return aggregate
    }

    @Test func anUnconfiguredWidgetShowsTheEmptyStateAtEveryMomentWithoutOpeningTheStore() async {
        let timeline = PillTypeWidgetTimeline { () throws -> (any PillTypeRepository)? in
            Issue.record("The store was opened for a widget with no Pill Type")
            return nil
        }

        let entries = await timeline.entries(for: nil, at: [now, nextRollover])

        #expect(entries.map(\.date) == [now, nextRollover])
        #expect(entries.map(\.content) == [.noPillType, .noPillType])
        #expect(entries.map(\.tap) == [.configure, .configure])
    }

    @Test func aStoreTheAppHasNotCreatedYetShowsTheEmptyState() async {
        let timeline = PillTypeWidgetTimeline { nil }

        let entries = await timeline.entries(for: UUID(), at: [now])

        #expect(entries.map(\.content) == [.noPillType])
        #expect(entries.map(\.tap) == [.configure])
    }

    @Test func aStoreThatCannotBeReadKeepsThePillTypeAndTriesAgainInFifteenMinutes() async {
        struct Unreadable: Error {}
        let pillTypeID = UUID()
        let timeline = PillTypeWidgetTimeline { throw Unreadable() }

        let result = await timeline.timeline(for: pillTypeID, now: now)

        #expect(result.entries.map(\.content) == [.unreadable, .unreadable])
        #expect(result.entries.map(\.tap) == [.blister(pillTypeID: pillTypeID), .blister(pillTypeID: pillTypeID)])
        #expect(result.policy == .after(now.addingTimeInterval(15 * 60)))
    }

    @Test func aReadableStoreShowsTheDaysDoneSlotsAndTheNextDaysOpenOnes() async throws {
        let repository = try makeRepository()
        var aggregate = try makeAggregate()
        try await repository.create(aggregate)
        let intake = try aggregate.consume(Position(row: 0, column: 0), slot: .morning, doneSlots: [], day: today, instant: now)
        try await repository.update(aggregate, recording: intake)
        let timeline = PillTypeWidgetTimeline { repository }

        let result = await timeline.timeline(for: aggregate.id, now: now)

        #expect(result.entries.map(\.date) == [now, nextRollover])
        #expect(result.entries.map(\.content) == [
            .withActivePrescription(abbreviation: "Vi", slotsDone: [true, false]),
            .withActivePrescription(abbreviation: "Vi", slotsDone: [false, false]),
        ])
        #expect(result.policy == .atEnd)
    }

    @Test func aDeletedPillTypeShowsTheEmptyStateEvenWithAReadableStore() async throws {
        let repository = try makeRepository()
        try await repository.create(try makeAggregate())
        let timeline = PillTypeWidgetTimeline { repository }

        let entries = await timeline.entries(for: UUID(), at: [now])

        #expect(entries.map(\.content) == [.noPillType])
        #expect(entries.map(\.tap) == [.configure])
    }

    @Test func theStoreIsOpenedOncePerTimelineNotOncePerEntry() async throws {
        let repository = try makeRepository()
        let aggregate = try makeAggregate()
        try await repository.create(aggregate)
        let opens = Counter()
        let timeline = PillTypeWidgetTimeline {
            opens.increment()
            return repository
        }

        let result = await timeline.timeline(for: aggregate.id, now: now)

        #expect(result.entries.count == 2)
        #expect(opens.value == 1)
    }
}

/// Counts how often a closure ran; a class, so the closure's copy and the test's are one.
private final class Counter: @unchecked Sendable {
    private(set) var value = 0
    func increment() { value += 1 }
}
