import Domain

/// What tapping a Position of the Current Blister offers, from the affordances `PillTypeProgress` draws
/// from the aggregate's preconditions.
enum PositionActions: Hashable {
    /// An Empty Position with an Intake Undo accepts is only ever undone.
    case undo(Intake)
    /// A Present Position: the Slots it can be consumed for, possibly none; removing it without a
    /// Prescription (a Sync Edit) is always offered too.
    case consume(slots: [Slot])
    /// An Empty Position without an Intake can be set Present (a Sync Edit).
    case setPresent
    /// Nothing to offer, such as a Position outside the grid.
    case nothing
}

extension PillTypeProgress {
    func actions(at position: Position) -> PositionActions {
        if let intake = undoableIntake(at: position) {
            return .undo(intake)
        }
        if currentBlister?.isPresent(position) == true {
            return .consume(slots: consumableSlots(at: position))
        }
        return canSetPresent(position) ? .setPresent : .nothing
    }
}
