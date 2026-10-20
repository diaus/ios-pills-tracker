/// Typed validation and rule errors raised by Domain values, the Pill Type aggregate and the use cases.
/// Carries codes only; the app maps them to user-facing text.
public enum DomainError: Error, Equatable, Sendable {
    /// A Pill Type name was empty (after trimming whitespace).
    case emptyName
    /// Grid rows were outside 1…10.
    case invalidRows
    /// Grid columns were outside 1…10.
    case invalidColumns
    /// A Prescription was given no Slots.
    case emptySlots
    /// Pause or resume was requested for a Pill Type without a Prescription.
    case noPrescription
    /// A grid shape change or Start New Blister was asked while a Position of the Current Blister is still Present.
    case currentBlisterNotEmpty
    /// No Pill Type with the given id exists.
    case pillTypeNotFound
    /// The Pill Type has no Current Blister to act on.
    case noCurrentBlister
    /// Consume or Sync Edit was asked for a Position outside the Current Blister's grid.
    case positionOutOfBounds
    /// Consume was asked for a Position that is already Empty.
    case positionEmpty
    /// Consume was asked for a Slot that is not Open on that Day (not prescribed, or already Done).
    case slotNotOpen
    /// Consume was asked for a Pill Type without an Active Prescription.
    case noActivePrescription
    /// A Sync Edit tried to set Present a Position that has an Intake; only Undo makes it Present again.
    case positionHasIntake
    /// Undo was asked for an Intake from a Retired Blister, or one that is not the latest at its Position.
    case undoNotAllowed
}
