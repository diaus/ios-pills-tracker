import Domain
import Foundation

extension Day {
    /// The Day `days` calendar days after this one; negative goes back.
    /// Counted in UTC, like `days(from:)`, so a daylight-saving night is still one Day.
    func adding(days: Int) -> Day {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        let start = calendar.date(from: DateComponents(year: year, month: month, day: day))!
        return Day(date: calendar.date(byAdding: .day, value: days, to: start)!, calendar: calendar)
    }
}
