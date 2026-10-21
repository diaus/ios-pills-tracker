import Foundation

/// A kind of medication the user takes, identified by its name.
/// Defines the grid shape of its Blisters.
public struct PillType: Identifiable, Hashable, Sendable {
    public let id: UUID
    public private(set) var name: String
    /// The optional short form of the name, trimmed; `nil` when not set.
    public private(set) var abbreviation: String?
    public var shape: GridShape
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        abbreviation: String? = nil,
        shape: GridShape,
        createdAt: Date
    ) throws(DomainError) {
        self.id = id
        self.name = try Self.validated(name: name)
        self.abbreviation = Self.normalized(abbreviation: abbreviation)
        self.shape = shape
        self.createdAt = createdAt
    }

    /// Renames the Pill Type; the trimmed name must be non-empty.
    public mutating func rename(_ name: String) throws(DomainError) {
        self.name = try Self.validated(name: name)
    }

    /// Sets the Abbreviation; blank after trimming clears it.
    public mutating func setAbbreviation(_ abbreviation: String?) {
        self.abbreviation = Self.normalized(abbreviation: abbreviation)
    }

    /// The text to show where the full name doesn't fit: the Abbreviation when set, otherwise the first
    /// two characters of the name.
    public var displayAbbreviation: String {
        abbreviation ?? String(name.prefix(2))
    }

    private static func validated(name: String) throws(DomainError) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw .emptyName }
        return trimmed
    }

    private static func normalized(abbreviation: String?) -> String? {
        let trimmed = abbreviation?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == false ? trimmed : nil
    }
}
