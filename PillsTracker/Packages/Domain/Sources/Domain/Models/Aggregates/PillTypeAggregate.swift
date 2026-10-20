import Foundation

/// The Pill Type aggregate: the Pill Type together with everything it owns.
public struct PillTypeAggregate: Identifiable, Hashable, Sendable {
    public var pillType: PillType
    /// Every Blister of the Pill Type (Current and Retired), changed only through the Blister operations
    /// below so that at most one is Current.
    public private(set) var blisters: [Blister]
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

    // MARK: Pill Type

    /// Renames the Pill Type; the trimmed name must be non-empty.
    public mutating func rename(_ name: String) throws(DomainError) {
        try pillType.rename(name)
    }

    /// Changes the grid shape used by the next Start New Blister. Allowed only while the Current Blister
    /// is empty (or absent); the empty Current Blister itself is left untouched.
    public mutating func changeShape(_ shape: GridShape) throws(DomainError) {
        try validateChangeShape()
        pillType.shape = shape
    }

    // MARK: Blister

    /// Consume: empties a Present `position` of the Current Blister for an Open `slot` and returns the
    /// Intake to record. `doneSlots` are the Slots already Done on `day`.
    public mutating func consume(_ position: Position, slot: Slot, doneSlots: Set<Slot>, day: Day, instant: Date) throws(DomainError) -> Intake {
        try validateConsume(position: position, slot: slot, doneSlots: doneSlots)
        let index = try currentBlisterIndex()
        blisters[index].presentPositions.remove(position)
        return Intake(pillTypeID: id, blisterID: blisters[index].id, position: position, slot: slot, day: day, instant: instant)
    }

    /// Undo: makes the Position of `intake` Present again on the Current Blister. The caller removes the Intake.
    /// `blisterIntakes` are the Current Blister's Intakes.
    public mutating func undo(_ intake: Intake, blisterIntakes: [Intake]) throws(DomainError) {
        try validateUndo(of: intake, blisterIntakes: blisterIntakes)
        let index = try currentBlisterIndex()
        blisters[index].presentPositions.insert(intake.position)
    }

    /// Start New Blister: retires the empty Current Blister and adds a fresh one in the Pill Type's
    /// shape as it is now. The Retired Blister keeps its final grid and shape.
    public mutating func startNewBlister() throws(DomainError) {
        try validateStartNewBlister()
        let index = try currentBlisterIndex()
        blisters[index].state = .retired
        blisters.append(.fresh(pillTypeID: id, shape: pillType.shape))
    }

    /// Sync Edit: sets one Position of the Current Blister Present or Empty. Retired Blisters stay as they are.
    /// `blisterIntakes` are the Current Blister's Intakes.
    public mutating func syncPosition(_ position: Position, isPresent: Bool, blisterIntakes: [Intake]) throws(DomainError) {
        try validateSyncPosition(position, isPresent: isPresent, blisterIntakes: blisterIntakes)
        let index = try currentBlisterIndex()
        if isPresent {
            blisters[index].presentPositions.insert(position)
        } else {
            blisters[index].presentPositions.remove(position)
        }
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
