import Foundation

/// Intake History of one Pill Type: its Intakes laid out by Day, from every Blister.
public struct PillTypeHistory: Hashable, Sendable {
    /// One Day of the history.
    public struct HistoryDay: Hashable, Sendable {
        public let day: Day
        /// The Pill Type's Intakes on the Day, whatever their Slot or Blister.
        public let intakeCount: Int
        /// Whether the Day is Completed against the Prescription's current Slots; nil when the Day isn't judged.
        public let isCompleted: Bool?
    }

    private let prescription: Prescription?
    private let intakesByDay: [Day: [Intake]]
    private let today: Day

    /// `intakes` are the Pill Type's Intakes over the Days the history covers.
    public init(prescription: Prescription?, intakes: [Intake], today: Day) {
        self.prescription = prescription
        self.today = today
        intakesByDay = Dictionary(grouping: intakes, by: \.day)
    }

    public func day(_ day: Day) -> HistoryDay {
        let intakes = intakesByDay[day] ?? []
        return HistoryDay(day: day, intakeCount: intakes.count, isCompleted: isCompleted(day, intakes: intakes))
    }

    /// Judged from Start Day to End Day, Paused or not, against the current Slots (ADR 0002). Days after
    /// today aren't judged, and today only once it is Completed, since its Open Slots may still be taken.
    private func isCompleted(_ day: Day, intakes: [Intake]) -> Bool? {
        guard let prescription, day >= prescription.startDay, day <= today else { return nil }
        if let endDay = prescription.endDay, day > endDay { return nil }
        let isCompleted = prescription.slots.isSubset(of: Set(intakes.map(\.slot)))
        return day == today && !isCompleted ? nil : isCompleted
    }
}
