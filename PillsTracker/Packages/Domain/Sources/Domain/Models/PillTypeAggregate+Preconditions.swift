import Foundation

/// The preconditions of Consume, Undo and Start New Blister, stated once. The aggregate's Blister
/// operations throw them; `PillTypeProgress` turns them into the affordances a screen shows.
extension PillTypeAggregate {
    /// Index of the Current Blister in `blisters`, so a Blister operation can mutate it in place.
    func currentBlisterIndex() throws(DomainError) -> Int {
        guard let index = blisters.firstIndex(where: { $0.state == .current }) else { throw .noCurrentBlister }
        return index
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

    /// Undo needs an Intake of this Pill Type made on `day` from the Current Blister: the user can
    /// no longer verify an Intake from another Day or a Retired Blister against the Blister in hand.
    public func validateUndo(of intake: Intake, on day: Day) throws(DomainError) {
        guard intake.pillTypeID == id, intake.day == day, intake.blisterID == currentBlister?.id else {
            throw .undoNotAllowed
        }
    }

    public func canUndo(_ intake: Intake, on day: Day) -> Bool {
        (try? validateUndo(of: intake, on: day)) != nil
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
