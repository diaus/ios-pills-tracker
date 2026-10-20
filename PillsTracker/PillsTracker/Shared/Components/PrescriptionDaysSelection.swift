import Domain
import Foundation

/// The Start Day and End Day a Prescription form holds, as its date pickers see them. Shared by the
/// Add Pill Type and Prescription sheets.
struct PrescriptionDaysSelection: Equatable {
    /// Moving it past the End Day moves the End Day along, so the End Day is never before it.
    var startDayDate: Date {
        didSet { if endDayDate < startDayDate { endDayDate = startDayDate } }
    }
    /// Whether the Prescription has an End Day; off means open-ended.
    var hasEndDay: Bool
    /// Kept while `hasEndDay` is off, so turning it back on restores it.
    var endDayDate: Date

    /// Without an End Day, the End Day picker starts on `startDay`.
    init(startDay: Day, endDay: Day?) {
        startDayDate = startDay.date()
        hasEndDay = endDay != nil
        endDayDate = (endDay ?? startDay).date()
    }

    var startDay: Day { Day(date: startDayDate) }
    var endDay: Day? { hasEndDay ? Day(date: endDayDate) : nil }
}
