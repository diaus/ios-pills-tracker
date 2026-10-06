/// Typed validation and rule errors raised by Domain values and use cases.
/// Carries codes only; the app maps them to user-facing text.
public enum DomainError: Error, Equatable, Sendable {
    /// A Pill Type name was empty (after trimming whitespace).
    case emptyName
    /// Grid rows were outside 1…10.
    case invalidRows
    /// Grid columns were outside 1…10.
    case invalidColumns
}
