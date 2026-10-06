/// Rule errors raised by use cases. Carries codes only; the app maps them to user-facing text.
public enum UseCaseError: Error, Equatable, Sendable {
    /// No Pill Type with the given id exists.
    case pillTypeNotFound
    /// The Pill Type has no Current Blister to act on.
    case noCurrentBlister
    /// Start New Blister was asked while a Position of the Current Blister is still Present.
    case blisterNotEmpty
}
