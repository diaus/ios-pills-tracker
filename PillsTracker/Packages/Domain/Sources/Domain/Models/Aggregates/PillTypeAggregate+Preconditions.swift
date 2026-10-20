import Foundation

/// The preconditions of Consume, Undo, Sync Edit, Start New Blister and a shape change, stated once. The aggregate's Blister
/// operations throw them; `PillTypeProgress` turns them into the affordances a screen shows.
extension PillTypeAggregate {
    /// Index of the Current Blister in `blisters`, so a Blister operation can mutate it in place.
    func currentBlisterIndex() throws(DomainError) -> Int {
        guard let index = blisters.firstIndex(where: { $0.state == .current }) else { throw .noCurrentBlister }
        return index
    }

    // MARK: Change shape

    /// A shape change needs the Current Blister (if any) to have every Position Empty.
    public func validateChangeShape() throws(DomainError) {
        if let currentBlister, !currentBlister.isEmpty { throw .currentBlisterNotEmpty }
    }

    public var canChangeShape: Bool {
        (try? validateChangeShape()) != nil
    }

    // MARK: Start New Blister

    /// Start New Blister needs a Current Blister with every Position Empty.
    public func validateStartNewBlister() throws(DomainError) {
        let index = try currentBlisterIndex()
        guard blisters[index].isEmpty else { throw .currentBlisterNotEmpty }
    }

    public var canStartNewBlister: Bool {
        (try? validateStartNewBlister()) != nil
    }

    // MARK: Undo

    /// Undo needs an Intake of this Pill Type from the Current Blister, made on any Day, that is the latest
    /// Intake at its Position. Intakes from a Retired Blister are locked (ADR 0001). `blisterIntakes` are
    /// the Current Blister's Intakes.
    public func validateUndo(of intake: Intake, blisterIntakes: [Intake]) throws(DomainError) {
        guard intake.pillTypeID == id, intake.blisterID == currentBlister?.id,
              Self.latestIntake(at: intake.position, in: blisterIntakes)?.id == intake.id else {
            throw .undoNotAllowed
        }
    }

    public func canUndo(_ intake: Intake, blisterIntakes: [Intake]) -> Bool {
        (try? validateUndo(of: intake, blisterIntakes: blisterIntakes)) != nil
    }

    /// The most recent of `intakes` taken from `position`.
    static func latestIntake(at position: Position, in intakes: [Intake]) -> Intake? {
        intakes.filter { $0.position == position }.max { $0.instant < $1.instant }
    }

    // MARK: Sync Edit

    /// A Sync Edit needs a Position inside the Current Blister's grid. Setting it Present also needs it to
    /// have no Intake, so a Consume is reverted only by Undo. `blisterIntakes` are the Current Blister's Intakes.
    public func validateSyncPosition(_ position: Position, isPresent: Bool, blisterIntakes: [Intake]) throws(DomainError) {
        let index = try currentBlisterIndex()
        guard blisters[index].contains(position) else { throw .positionOutOfBounds }
        if isPresent, blisterIntakes.contains(where: { $0.blisterID == blisters[index].id && $0.position == position }) {
            throw .positionHasIntake
        }
    }

    // MARK: Consume

    /// Consume needs a Current Blister, an Active Prescription, a Present Position inside the grid and
    /// a Slot that is Open on the Day. `doneSlots` are the Slots already Done on that Day.
    public func validateConsume(position: Position, slot: Slot, doneSlots: Set<Slot>) throws(DomainError) {
        let index = try currentBlisterIndex()
        guard let prescription, prescription.state == .active else { throw .noActivePrescription }
        guard blisters[index].contains(position) else { throw .positionOutOfBounds }
        guard blisters[index].isPresent(position) else { throw .positionEmpty }
        guard prescription.contains(slot), !doneSlots.contains(slot) else { throw .slotNotOpen }
    }
}
