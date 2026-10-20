import Domain
import Foundation

extension PrescriptionModel {
    convenience init(_ prescription: Prescription) {
        self.init(
            id: prescription.id,
            slots: prescription.slots,
            state: prescription.state.rawValue,
            startDay: prescription.startDay,
            endDay: prescription.endDay
        )
    }

    func toDomain(pillTypeID: UUID) throws(DataError) -> Prescription {
        let state: PrescriptionState = try DataError.rawValue(state)
        guard let startDayYear, let startDayMonth, let startDayDay else { throw .corruptRecord }
        let startDay = Day(year: startDayYear, month: startDayMonth, day: startDayDay)
        let endDay: Day?
        switch (endDayYear, endDayMonth, endDayDay) {
        case (nil, nil, nil): endDay = nil
        case let (year?, month?, day?): endDay = Day(year: year, month: month, day: day)
        default: throw .corruptRecord
        }
        return try DataError.record { () throws(DomainError) in
            try Prescription(id: id, pillTypeID: pillTypeID, slots: slots, state: state, startDay: startDay, endDay: endDay)
        }
    }

    func apply(_ prescription: Prescription) {
        slots = prescription.slots
        state = prescription.state.rawValue
        setDays(startDay: prescription.startDay, endDay: prescription.endDay)
    }
}
