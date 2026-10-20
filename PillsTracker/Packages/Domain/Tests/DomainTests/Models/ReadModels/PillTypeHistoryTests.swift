import Foundation
import Testing
@testable import Domain

struct PillTypeHistoryTests {
    private let today = Day(year: 2026, month: 10, day: 20)
    private let yesterday = Day(year: 2026, month: 10, day: 19)
    private let pillTypeID = UUID()

    private func intake(_ slot: Slot, on day: Day) -> Intake {
        Intake(pillTypeID: pillTypeID, blisterID: UUID(), position: Position(row: 0, column: 0), slot: slot, day: day, instant: .now)
    }

    private func prescription(_ slots: Set<Slot>, startDay: Day = Day(year: 2026, month: 1, day: 1), endDay: Day? = nil) throws -> Prescription {
        try Prescription(pillTypeID: pillTypeID, slots: slots, startDay: startDay, endDay: endDay)
    }

    @Test func aPastDayIsCompletedOnlyWhenEveryCurrentSlotHasAnIntake() throws {
        let twoDaysAgo = Day(year: 2026, month: 10, day: 18)
        let history = PillTypeHistory(
            prescription: try prescription([.morning, .evening]),
            intakes: [intake(.morning, on: yesterday), intake(.evening, on: yesterday), intake(.morning, on: twoDaysAgo)],
            today: today
        )

        #expect(history.day(yesterday).isCompleted == true)
        #expect(history.day(twoDaysAgo).isCompleted == false)
        #expect(history.day(Day(year: 2026, month: 10, day: 17)).isCompleted == false)
    }

    @Test func onlyDaysFromStartDayToEndDayAreJudged() throws {
        let start = Day(year: 2026, month: 10, day: 10)
        let end = Day(year: 2026, month: 10, day: 15)
        let history = PillTypeHistory(prescription: try prescription([.morning], startDay: start, endDay: end), intakes: [], today: today)

        #expect(history.day(Day(year: 2026, month: 10, day: 9)).isCompleted == nil)
        #expect(history.day(start).isCompleted == false)
        #expect(history.day(end).isCompleted == false)
        #expect(history.day(Day(year: 2026, month: 10, day: 16)).isCompleted == nil)
    }

    @Test func todayIsJudgedOnlyOnceCompleted() throws {
        let open = PillTypeHistory(prescription: try prescription([.morning, .evening]), intakes: [intake(.morning, on: today)], today: today)
        let completed = PillTypeHistory(
            prescription: try prescription([.morning, .evening]),
            intakes: [intake(.morning, on: today), intake(.evening, on: today)],
            today: today
        )

        #expect(open.day(today).isCompleted == nil)
        #expect(completed.day(today).isCompleted == true)
    }

    @Test func daysAfterTodayAreNotJudgedEvenBeforeEndDay() throws {
        let history = PillTypeHistory(prescription: try prescription([.morning], endDay: Day(year: 2026, month: 12, day: 31)), intakes: [], today: today)

        #expect(history.day(Day(year: 2026, month: 10, day: 21)).isCompleted == nil)
    }

    @Test func withoutAPrescriptionDaysAreCountedButNotJudged() {
        let history = PillTypeHistory(prescription: nil, intakes: [intake(.morning, on: yesterday)], today: today)

        #expect(history.day(yesterday).intakeCount == 1)
        #expect(history.day(yesterday).isCompleted == nil)
    }

    @Test func aPausedPrescriptionIsStillJudged() throws {
        var paused = try prescription([.morning])
        paused.state = .paused
        let history = PillTypeHistory(prescription: paused, intakes: [intake(.morning, on: yesterday)], today: today)

        #expect(history.day(yesterday).isCompleted == true)
    }

    @Test func anIntakeForASlotNoLongerPrescribedIsCountedButDoesNotCompleteTheDay() throws {
        let history = PillTypeHistory(prescription: try prescription([.evening]), intakes: [intake(.morning, on: yesterday)], today: today)

        #expect(history.day(yesterday).intakeCount == 1)
        #expect(history.day(yesterday).isCompleted == false)
    }

    @Test func countsEachDaysIntakes() {
        let history = PillTypeHistory(
            prescription: nil,
            intakes: [intake(.morning, on: yesterday), intake(.evening, on: yesterday), intake(.morning, on: today)],
            today: today
        )

        #expect(history.day(yesterday).intakeCount == 2)
        #expect(history.day(today).intakeCount == 1)
        #expect(history.day(Day(year: 2026, month: 10, day: 18)).intakeCount == 0)
    }
}
