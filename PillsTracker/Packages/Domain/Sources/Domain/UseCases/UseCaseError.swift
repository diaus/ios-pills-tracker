/// Rule errors raised by use cases. Carries codes only; the app maps them to user-facing text.
public enum UseCaseError: Error, Equatable, Sendable {
    /// No Pill Type with the given id exists.
    case pillTypeNotFound
    /// The Pill Type has no Current Blister to act on.
    case noCurrentBlister
    /// Start New Blister was asked while a Position of the Current Blister is still Present.
    case blisterNotEmpty
    /// Consume was asked for a Position that is already Empty.
    case positionEmpty
    /// Consume was asked for a Slot that is not Open on that Day (not prescribed, or already Done).
    case slotNotOpen
    /// Consume was asked for a Pill Type without an Active Prescription.
    case noActivePrescription
    /// Undo was asked for an Intake from another Day or from a Retired Blister.
    case undoNotAllowed
}
