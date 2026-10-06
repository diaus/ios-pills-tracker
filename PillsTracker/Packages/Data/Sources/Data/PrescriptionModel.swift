import Domain
import Foundation
import SwiftData

extension PillsSchemaV1 {
    /// Persisted Prescription. Slots are stored as one Codable attribute; the state as its raw value.
    @Model
    public final class PrescriptionModel {
        @Attribute(.unique) public var id: UUID
        public var slots: Set<Slot>
        /// Raw value of `Domain.PrescriptionState`.
        public var state: String
        public var pillType: PillTypeModel?

        public init(id: UUID, slots: Set<Slot>, state: String) {
            self.id = id
            self.slots = slots
            self.state = state
        }
    }
}
