import Foundation

/// Whether a Prescription counts toward today's progress and shows as a Home card.
public enum PrescriptionState: String, Sendable, Hashable, Codable {
    case active
    case paused
}

/// The daily rule for a Pill Type: the non-empty set of Slots in which one pill is taken.
/// A Pill Type has at most one Prescription; it is owned by `PillTypeAggregate`.
public struct Prescription: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let pillTypeID: UUID
    public private(set) var slots: Set<Slot>
    public var state: PrescriptionState

    public init(id: UUID = UUID(), pillTypeID: UUID, slots: Set<Slot>, state: PrescriptionState = .active) throws(DomainError) {
        self.id = id
        self.pillTypeID = pillTypeID
        self.slots = try Self.validated(slots: slots)
        self.state = state
    }

    /// Replaces the Slots; the new set must be non-empty.
    public mutating func setSlots(_ slots: Set<Slot>) throws(DomainError) {
        self.slots = try Self.validated(slots: slots)
    }

    public func contains(_ slot: Slot) -> Bool {
        slots.contains(slot)
    }

    private static func validated(slots: Set<Slot>) throws(DomainError) -> Set<Slot> {
        guard !slots.isEmpty else { throw .emptySlots }
        return slots
    }
}
