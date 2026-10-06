import Foundation

/// The permanent record that one pill of a Pill Type was taken from a Position of a Blister
/// for a Slot on a Day. Created only by Consume, never by Sync Edit; never purged (ADR 0001).
/// Keyed on the Pill Type, not the Prescription, so it survives Prescription changes.
public struct Intake: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let pillTypeID: UUID
    public let blisterID: UUID
    public let position: Position
    public let slot: Slot
    /// The local calendar Day the user experienced; stored explicitly, never derived from `instant`.
    public let day: Day
    /// The moment the pill was taken.
    public let instant: Date

    public init(id: UUID = UUID(), pillTypeID: UUID, blisterID: UUID, position: Position, slot: Slot, day: Day, instant: Date) {
        self.id = id
        self.pillTypeID = pillTypeID
        self.blisterID = blisterID
        self.position = position
        self.slot = slot
        self.day = day
        self.instant = instant
    }
}
