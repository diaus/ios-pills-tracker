import Foundation
import SwiftData

extension PillsSchemaV2 {
    /// Persisted Pill Type. Owns its Blisters, optional Prescription and Intakes; deleting it cascades to them.
    @Model
    public final class PillTypeModel {
        @Attribute(.unique) public var id: UUID
        public var name: String
        public var rows: Int
        public var columns: Int
        public var createdAt: Date

        @Relationship(deleteRule: .cascade, inverse: \BlisterModel.pillType)
        public var blisters: [BlisterModel] = []

        @Relationship(deleteRule: .cascade, inverse: \PrescriptionModel.pillType)
        public var prescription: PrescriptionModel?

        /// Permanent Intake records; untouched by Blister and Prescription changes, deleted with the Pill Type.
        @Relationship(deleteRule: .cascade, inverse: \IntakeModel.pillType)
        public var intakes: [IntakeModel] = []

        public init(id: UUID, name: String, rows: Int, columns: Int, createdAt: Date) {
            self.id = id
            self.name = name
            self.rows = rows
            self.columns = columns
            self.createdAt = createdAt
        }
    }
}
