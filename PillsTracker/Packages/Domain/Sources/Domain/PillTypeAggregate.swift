import Foundation

/// The Pill Type aggregate: the Pill Type together with everything it owns.
public struct PillTypeAggregate: Identifiable, Hashable, Sendable {
    public var pillType: PillType
    /// Every Blister of the Pill Type (Current and Retired).
    public var blisters: [Blister]
    /// The at-most-one daily rule for this Pill Type.
    public var prescription: Prescription?

    public var id: UUID { pillType.id }

    public init(pillType: PillType, blisters: [Blister], prescription: Prescription? = nil) {
        self.pillType = pillType
        self.blisters = blisters
        self.prescription = prescription
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

    // MARK: Prescription

    /// Creates an Active Prescription with `slots`, or edits the Slots of the existing one
    /// (keeping its identity and Active/Paused state). Empty `slots` are rejected.
    public mutating func setPrescriptionSlots(_ slots: Set<Slot>) throws(DomainError) {
        if var existing = prescription {
            try existing.setSlots(slots)
            prescription = existing
        } else {
            prescription = try Prescription(pillTypeID: id, slots: slots)
        }
    }

    public mutating func pausePrescription() throws(DomainError) {
        try setPrescriptionState(.paused)
    }

    public mutating func resumePrescription() throws(DomainError) {
        try setPrescriptionState(.active)
    }

    /// Drops the Prescription. The Pill Type and its Blisters are untouched.
    public mutating func removePrescription() {
        prescription = nil
    }

    private mutating func setPrescriptionState(_ state: PrescriptionState) throws(DomainError) {
        guard prescription != nil else { throw .noPrescription }
        prescription?.state = state
    }
}
