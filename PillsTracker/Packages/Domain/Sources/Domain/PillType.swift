import Foundation

/// A kind of medication the user takes, identified by its name.
/// Defines the grid shape of its Blisters.
public struct PillType: Identifiable, Hashable, Sendable {
    public let id: UUID
    public private(set) var name: String
    public var shape: GridShape
    public let createdAt: Date

    public init(id: UUID = UUID(), name: String, shape: GridShape, createdAt: Date) throws(DomainError) {
        self.id = id
        self.name = try Self.validated(name: name)
        self.shape = shape
        self.createdAt = createdAt
    }

    /// Renames the Pill Type; the trimmed name must be non-empty.
    public mutating func rename(_ name: String) throws(DomainError) {
        self.name = try Self.validated(name: name)
    }

    private static func validated(name: String) throws(DomainError) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw .emptyName }
        return trimmed
    }
}
