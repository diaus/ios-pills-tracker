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
        guard let startDay = try Day.stored(year: startDayYear, month: startDayMonth, day: startDayDay) else {
            throw .corruptRecord
        }
        let endDay = try Day.stored(year: endDayYear, month: endDayMonth, day: endDayDay)
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
