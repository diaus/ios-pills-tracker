import Domain
import Foundation
import Testing
@testable import PillsTracker

@MainActor
struct HistoryMonthTests {
    private func calendar(firstWeekday: Int) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Kyiv")!
        calendar.locale = Locale(identifier: "en_GB")
        calendar.firstWeekday = firstWeekday
        return calendar
    }

    @Test func weeksStartOnTheCalendarsFirstWeekdayAndSpillIntoTheNeighbouringMonths() {
        // October 2026 begins on a Thursday and ends on a Saturday.
        let october = HistoryMonth(containing: Day(year: 2026, month: 10, day: 20))

        let mondayFirst = october.weeks(in: calendar(firstWeekday: 2))
        let sundayFirst = october.weeks(in: calendar(firstWeekday: 1))

        #expect(mondayFirst.count == 5)
        #expect(mondayFirst.first?.first == Day(year: 2026, month: 9, day: 28))
        #expect(mondayFirst.last?.last == Day(year: 2026, month: 11, day: 1))
        #expect(sundayFirst.first?.first == Day(year: 2026, month: 9, day: 27))
        #expect(sundayFirst.last?.last == Day(year: 2026, month: 10, day: 31))
        #expect(mondayFirst.allSatisfy { $0.count == 7 })
    }

    @Test func aMonthStartingOnTheFirstWeekdayHasNoLeadingSpillOver() {
        // February 2027 begins on a Monday and has exactly four weeks.
        let february = HistoryMonth(containing: Day(year: 2027, month: 2, day: 1))

        let weeks = february.weeks(in: calendar(firstWeekday: 2))

        #expect(weeks.count == 4)
        #expect(weeks.first?.first == Day(year: 2027, month: 2, day: 1))
        #expect(weeks.last?.last == Day(year: 2027, month: 2, day: 28))
    }

    @Test func shownDaysSpanTheFirstToTheLastDayOfTheWeeks() {
        let october = HistoryMonth(containing: Day(year: 2026, month: 10, day: 1))

        let shown = october.shownDays(in: calendar(firstWeekday: 2))

        #expect(shown == Day(year: 2026, month: 9, day: 28)...Day(year: 2026, month: 11, day: 1))
    }

    @Test func advancingCrossesYearBoundariesBothWays() {
        let january = HistoryMonth(containing: Day(year: 2026, month: 1, day: 15))

        #expect(january.advanced(by: -1) == HistoryMonth(containing: Day(year: 2025, month: 12, day: 1)))
        #expect(january.advanced(by: -13) == HistoryMonth(containing: Day(year: 2024, month: 12, day: 1)))
        #expect(january.advanced(by: 11) == HistoryMonth(containing: Day(year: 2026, month: 12, day: 1)))
        #expect(january.advanced(by: 12) == HistoryMonth(containing: Day(year: 2027, month: 1, day: 1)))
    }

    @Test func weekdaySymbolsFollowTheCalendarsFirstWeekday() {
        #expect(HistoryMonth.weekdaySymbols(in: calendar(firstWeekday: 2)) == ["M", "T", "W", "T", "F", "S", "S"])
        #expect(HistoryMonth.weekdaySymbols(in: calendar(firstWeekday: 1)) == ["S", "M", "T", "W", "T", "F", "S"])
    }
}
