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
