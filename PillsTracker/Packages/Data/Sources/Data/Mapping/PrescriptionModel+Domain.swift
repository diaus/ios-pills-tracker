import Domain
import Foundation

extension PrescriptionModel {
    convenience init(_ prescription: Prescription) {
        self.init(id: prescription.id, slots: prescription.slots, state: prescription.state.rawValue)
    }

    func toDomain(pillTypeID: UUID) throws(DataError) -> Prescription {
        let state: PrescriptionState = try DataError.rawValue(state)
        return try DataError.record { () throws(DomainError) in
            try Prescription(id: id, pillTypeID: pillTypeID, slots: slots, state: state)
        }
    }

    func apply(_ prescription: Prescription) {
        slots = prescription.slots
        state = prescription.state.rawValue
    }
}
