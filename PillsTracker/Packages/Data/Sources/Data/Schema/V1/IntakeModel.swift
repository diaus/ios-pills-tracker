import Domain
import Foundation
import SwiftData

extension PillsSchemaV1 {
    /// Persisted Intake: a permanent record keyed on its Pill Type (ADR 0001).
    /// The Day is stored as explicit year/month/day fields and never derived from `instant`.
    @Model
    public final class IntakeModel {
        @Attribute(.unique) public var id: UUID
        /// Denormalised owner id so Intakes can be fetched per Pill Type with a plain predicate.
        public var pillTypeID: UUID
        public var blisterID: UUID
        public var position: Position
        /// Raw value of `Domain.Slot`.
        public var slot: String
        public var dayYear: Int
        public var dayMonth: Int
        public var dayDay: Int
        public var instant: Date
        public var pillType: PillTypeModel?

        public init(id: UUID, pillTypeID: UUID, blisterID: UUID, position: Position, slot: String, dayYear: Int, dayMonth: Int, dayDay: Int, instant: Date) {
            self.id = id
            self.pillTypeID = pillTypeID
            self.blisterID = blisterID
            self.position = position
            self.slot = slot
            self.dayYear = dayYear
            self.dayMonth = dayMonth
            self.dayDay = dayDay
            self.instant = instant
        }
    }
}
