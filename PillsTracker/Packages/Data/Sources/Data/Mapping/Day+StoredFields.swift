import Domain

extension Day {
    /// A Day stored as separate year, month and day fields: nil when none is stored, corrupt when only some are.
    static func stored(year: Int?, month: Int?, day: Int?) throws(DataError) -> Day? {
        switch (year, month, day) {
        case (nil, nil, nil): nil
        case let (year?, month?, day?): Day(year: year, month: month, day: day)
        default: throw .corruptRecord
        }
    }
}
