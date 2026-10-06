import Domain
import Foundation
import SwiftData

extension PillsSchemaV1 {
    /// Persisted Blister. Present Positions are stored as one Codable attribute.
    @Model
    public final class BlisterModel {
        @Attribute(.unique) public var id: UUID
        /// Raw value of `Domain.BlisterState`.
        public var state: String
        public var presentPositions: Set<Position>
        public var pillType: PillTypeModel?

        public init(id: UUID, state: String, presentPositions: Set<Position>) {
            self.id = id
            self.state = state
            self.presentPositions = presentPositions
        }
    }
}
