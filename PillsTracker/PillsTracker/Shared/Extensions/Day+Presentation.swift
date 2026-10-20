import Domain
import Foundation

extension Day {
    /// How an Intake's Day reads next to `today`: "today", "yesterday", the weekday for 2–6 days ago,
    /// otherwise the month and day ("Jul 21"). Never shows a year.
    func relativeName(today: Day, calendar: Calendar = .current) -> String {
        switch today.days(from: self) {
        case 0: String(localized: .dayToday)
        case 1: String(localized: .dayYesterday)
        case 2...6: date(in: calendar).formatted(.dateTime.weekday(.wide))
        default: date(in: calendar).formatted(.dateTime.month(.abbreviated).day())
        }
    }
}
