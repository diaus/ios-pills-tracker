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
}
