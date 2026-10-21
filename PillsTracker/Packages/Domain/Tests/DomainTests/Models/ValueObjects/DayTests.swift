import Foundation
import Testing
@testable import Domain

struct DayTests {
    @Test func isBuiltFromADateInTheGivenCalendar() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Athens")!
        // 2026-03-09 23:30 UTC is already 2026-03-10 01:30 in Athens (UTC+2).
        let date = Date(timeIntervalSince1970: 1_773_099_000)

        #expect(Day(date: date, calendar: calendar) == Day(year: 2026, month: 3, day: 10))

        calendar.timeZone = TimeZone(identifier: "UTC")!
        #expect(Day(date: date, calendar: calendar) == Day(year: 2026, month: 3, day: 9))
    }

    @Test func todayIsThePreviousDayUntilTheRollover() {
        let calendar = Self.utc
        // 2026-03-10 at 02:59 and at 03:00 UTC.
        let beforeRollover = Date(timeIntervalSince1970: 1_773_111_540)
        let atRollover = Date(timeIntervalSince1970: 1_773_111_600)

        #expect(Day.current(at: beforeRollover, calendar: calendar) == Day(year: 2026, month: 3, day: 9))
        #expect(Day.current(at: atRollover, calendar: calendar) == Day(year: 2026, month: 3, day: 10))
    }

    @Test func nextRolloverIsTheComingThreeOClock() {
        let calendar = Self.utc
        // 2026-03-10 at 01:30, 03:00 and 22:00 UTC.
        let night = Date(timeIntervalSince1970: 1_773_106_200)
        let atRollover = Date(timeIntervalSince1970: 1_773_111_600)
        let evening = Date(timeIntervalSince1970: 1_773_180_000)
        let nextMorning = Date(timeIntervalSince1970: 1_773_198_000)

        #expect(Day.nextRollover(after: night, calendar: calendar) == atRollover)
        #expect(Day.nextRollover(after: atRollover, calendar: calendar) == nextMorning)
        #expect(Day.nextRollover(after: evening, calendar: calendar) == nextMorning)
    }

    private static var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }

    @Test func ordersChronologically() {
        let days = [
            Day(year: 2026, month: 1, day: 2),
            Day(year: 2025, month: 12, day: 31),
            Day(year: 2026, month: 1, day: 1),
            Day(year: 2026, month: 2, day: 1),
        ]
        #expect(days.sorted() == [
            Day(year: 2025, month: 12, day: 31),
            Day(year: 2026, month: 1, day: 1),
            Day(year: 2026, month: 1, day: 2),
            Day(year: 2026, month: 2, day: 1),
        ])
    }

    @Test func countsCalendarDaysBetweenTwoDays() {
        let today = Day(year: 2026, month: 3, day: 1)

        #expect(today.days(from: today) == 0)
        #expect(today.days(from: Day(year: 2026, month: 2, day: 28)) == 1)
        #expect(today.days(from: Day(year: 2025, month: 12, day: 31)) == 60)
        #expect(Day(year: 2026, month: 2, day: 28).days(from: today) == -1)
        // Europe's spring-forward night (2026-03-29) is still one whole Day.
        #expect(Day(year: 2026, month: 3, day: 30).days(from: Day(year: 2026, month: 3, day: 29)) == 1)
    }
}
