import Domain
import Foundation

extension Day {
    /// The Day `date` falls on in the device's calendar, the one a date picker shows.
    init(date: Date) {
        self.init(date: date, calendar: .current)
    }

    /// Noon of this Day in `calendar`, safely inside the Day whatever its daylight-saving shift.
    func date(in calendar: Calendar = .current) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }
}
