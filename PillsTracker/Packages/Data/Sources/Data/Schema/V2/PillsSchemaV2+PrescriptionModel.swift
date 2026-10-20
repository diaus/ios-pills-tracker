import Domain
import Foundation
import SwiftData

extension PillsSchemaV2 {
    /// Persisted Prescription. Slots are stored as one Codable attribute; the state as its raw value;
    /// Start Day and End Day as explicit year/month/day fields, like an Intake's Day.
    @Model
    public final class PrescriptionModel {
        @Attribute(.unique) public var id: UUID
        public var slots: Set<Slot>
        /// Raw value of `Domain.PrescriptionState`.
        public var state: String
        /// nil only between the V1 to V2 migration's schema change and its fill-in from the Pill Type's
        /// creation Day; every row written since has them.
        public var startDayYear: Int?
        public var startDayMonth: Int?
        public var startDayDay: Int?
        /// All nil while the Prescription is open-ended.
        public var endDayYear: Int?
        public var endDayMonth: Int?
        public var endDayDay: Int?
        public var pillType: PillTypeModel?

        public init(id: UUID, slots: Set<Slot>, state: String, startDay: Day, endDay: Day?) {
            self.id = id
            self.slots = slots
            self.state = state
            setDays(startDay: startDay, endDay: endDay)
        }

        func setDays(startDay: Day, endDay: Day?) {
            startDayYear = startDay.year
            startDayMonth = startDay.month
            startDayDay = startDay.day
            endDayYear = endDay?.year
            endDayMonth = endDay?.month
            endDayDay = endDay?.day
        }
    }
}
