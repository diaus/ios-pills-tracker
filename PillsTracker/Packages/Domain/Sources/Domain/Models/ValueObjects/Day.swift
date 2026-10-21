import Foundation

/// A local calendar day. Progress is computed per Day. Stored explicitly on an Intake; never derived
/// from an instant at read time (ADR 0001). Only Today, `current`, rolls over at 03:00 (ADR 0004).
public struct Day: Hashable, Comparable, Sendable, Codable {
    /// The local hour Today rolls over at: before it, Today is still the previous calendar Day.
    public static let rolloverHour = 3

    public let year: Int
    public let month: Int
    public let day: Int

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    /// The calendar day `date` falls on in `calendar` (including its time zone).
    public init(date: Date, calendar: Calendar) {
        self.init(
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date),
            day: calendar.component(.day, from: date)
        )
    }

    /// Today: the calendar Day it is now on the device, or the previous one before `rolloverHour`.
    /// Use cases never read it; they take the Day as a parameter (ADR 0004).
    public static var current: Day {
        current(at: .now, calendar: .current)
    }

    /// What Today is at `date` in `calendar`: its calendar Day, or the previous one before `rolloverHour`.
    /// For a moment ahead of now, such as a widget timeline entry at the next rollover.
    public static func current(at date: Date, calendar: Calendar) -> Day {
        guard calendar.component(.hour, from: date) < rolloverHour else { return Day(date: date, calendar: calendar) }
        return Day(date: calendar.date(byAdding: .day, value: -1, to: date)!, calendar: calendar)
    }

    /// The first moment after `date` at which Today rolls over: the next `rolloverHour` o'clock in `calendar`.
    public static func nextRollover(after date: Date, calendar: Calendar) -> Date? {
        let rollover = DateComponents(hour: rolloverHour, minute: 0, second: 0)
        return calendar.nextDate(after: date, matching: rollover, matchingPolicy: .nextTime)
    }

    /// Whole calendar days from `earlier` to this Day; negative when `earlier` is in fact later.
    /// Counted in UTC, where every Day is 24 hours, so a daylight-saving night is still one Day.
    public func days(from earlier: Day) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        func start(of day: Day) -> Date {
            calendar.date(from: DateComponents(year: day.year, month: day.month, day: day.day))!
        }
        return calendar.dateComponents([.day], from: start(of: earlier), to: start(of: self)).day!
    }

    public static func < (lhs: Day, rhs: Day) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }
}
