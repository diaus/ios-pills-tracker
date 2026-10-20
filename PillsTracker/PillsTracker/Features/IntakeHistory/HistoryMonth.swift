import Domain
import Foundation

/// One calendar month as Intake History pages it, laid out in whole weeks of the device's calendar,
/// or of the one passed in.
struct HistoryMonth: Hashable, Sendable {
    let year: Int
    let month: Int

    init(containing day: Day) {
        year = day.year
        month = day.month
    }

    /// The month `months` after this one; negative goes back.
    func advanced(by months: Int) -> HistoryMonth {
        let index = year * 12 + (month - 1) + months
        return HistoryMonth(containing: Day(year: index / 12, month: index % 12 + 1, day: 1))
    }

    var firstDay: Day { Day(year: year, month: month, day: 1) }

    /// The month's Days in whole weeks starting on `calendar`'s first weekday; the first and last
    /// weeks spill over into the neighbouring months.
    func weeks(in calendar: Calendar = .current) -> [[Day]] {
        let first = firstDay.date(in: calendar)
        let dayCount = calendar.range(of: .day, in: .month, for: first)!.count
        let leading = (calendar.component(.weekday, from: first) - calendar.firstWeekday + 7) % 7
        let weekCount = (leading + dayCount + 6) / 7
        let start = firstDay.adding(days: -leading)
        return (0..<weekCount).map { week in
            (0..<7).map { start.adding(days: week * 7 + $0) }
        }
    }

    /// Every Day `weeks(in:)` shows, spill-over included.
    func shownDays(in calendar: Calendar = .current) -> ClosedRange<Day> {
        let weeks = weeks(in: calendar)
        return weeks.first!.first!...weeks.last!.last!
    }

    func contains(_ day: Day) -> Bool {
        day.year == year && day.month == month
    }

    /// Short weekday names in the order `weeks(in:)` lays them out.
    static func weekdaySymbols(in calendar: Calendar = .current) -> [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let shift = calendar.firstWeekday - 1
        return Array(symbols[shift...] + symbols[..<shift])
    }
}
