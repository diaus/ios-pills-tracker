import Domain
import Foundation
import SwiftData

extension PillsSchemaV1 {
    /// Persisted Blister. Present Positions are stored as one Codable attribute.
    @Model
    public final class BlisterModel {
        @Attribute(.unique) public var id: UUID
        /// Grid shape of this Blister. 0 means the row was written before Blisters carried a shape;
        /// the mapping then uses the owning Pill Type's shape.
        public var rows: Int = 0
        public var columns: Int = 0
        /// Raw value of `Domain.BlisterState`.
        public var state: String
        public var presentPositions: Set<Position>
        public var pillType: PillTypeModel?

        public init(id: UUID, rows: Int, columns: Int, state: String, presentPositions: Set<Position>) {
            self.id = id
            self.rows = rows
            self.columns = columns
            self.state = state
            self.presentPositions = presentPositions
        }
    }
}
