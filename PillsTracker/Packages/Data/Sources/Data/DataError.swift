/// Errors specific to the persistence layer. Carries codes only; the app maps them to user-facing text.
public enum DataError: Error, Equatable, Sendable {
    /// The row to update or attach to does not exist.
    case notFound
    /// A stored row no longer satisfies a Domain invariant (unknown raw value, invalid shape, empty name).
    case corruptRecord
}
