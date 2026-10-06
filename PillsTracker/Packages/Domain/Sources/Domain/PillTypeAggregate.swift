import Foundation

/// The Pill Type aggregate: the Pill Type together with everything it owns.
/// Later tickets add the optional Prescription here.
public struct PillTypeAggregate: Identifiable, Hashable, Sendable {
    public var pillType: PillType
    /// Every Blister of the Pill Type (Current and Retired).
    public var blisters: [Blister]

    public var id: UUID { pillType.id }

    public init(pillType: PillType, blisters: [Blister]) {
        self.pillType = pillType
        self.blisters = blisters
    }

    /// The single Blister being consumed right now.
    public var currentBlister: Blister? {
        blisters.first { $0.state == .current }
    }

    /// Creates a new Pill Type with a Current Blister where every Position is Present.
    public static func new(name: String, rows: Int, columns: Int, id: UUID = UUID(), createdAt: Date) throws(DomainError) -> PillTypeAggregate {
        let shape = try GridShape(rows: rows, columns: columns)
        let pillType = try PillType(id: id, name: name, shape: shape, createdAt: createdAt)
        return PillTypeAggregate(pillType: pillType, blisters: [.fresh(pillTypeID: pillType.id, shape: shape)])
    }
}
