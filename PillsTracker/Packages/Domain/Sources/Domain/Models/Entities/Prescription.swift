import Foundation

/// The daily rule for a Pill Type: the non-empty set of Slots in which one pill is taken.
/// A Pill Type has at most one Prescription; it is owned by `PillTypeAggregate`. Its Start Day and End Day
/// only decide which Days Intake History judges Completed; no rule reads them (ADR 0002).
public struct Prescription: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let pillTypeID: UUID
    public private(set) var slots: Set<Slot>
    public var state: PrescriptionState
    /// The first Day the Prescription is meant to cover.
    public var startDay: Day
    /// The last Day the Prescription is meant to cover; nil while it is open-ended.
    public var endDay: Day?

    public init(
        id: UUID = UUID(),
        pillTypeID: UUID,
        slots: Set<Slot>,
        state: PrescriptionState = .active,
        startDay: Day,
        endDay: Day? = nil
    ) throws(DomainError) {
        self.id = id
        self.pillTypeID = pillTypeID
        self.slots = try Self.validated(slots: slots)
        self.state = state
        self.startDay = startDay
        self.endDay = endDay
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
