import Foundation
import SwiftData

extension PillsSchemaV1 {
    /// Persisted Pill Type. Owns its Blisters; deleting it cascades to them.
    @Model
    public final class PillTypeModel {
        @Attribute(.unique) public var id: UUID
        public var name: String
        public var rows: Int
        public var columns: Int
        public var createdAt: Date

        @Relationship(deleteRule: .cascade, inverse: \BlisterModel.pillType)
        public var blisters: [BlisterModel] = []

        public init(id: UUID, name: String, rows: Int, columns: Int, createdAt: Date) {
            self.id = id
            self.name = name
            self.rows = rows
            self.columns = columns
            self.createdAt = createdAt
        }
    }
}
