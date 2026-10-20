import Foundation

/// Done/Open state of one prescribed Slot on a Day.
public struct SlotProgress: Hashable, Sendable {
    public let slot: Slot
    /// The Intake that made the Slot Done on that Day, or nil while it is Open.
    public let intake: Intake?

    public init(slot: Slot, intake: Intake?) {
        self.slot = slot
        self.intake = intake
    }

    public var isDone: Bool { intake != nil }
}
