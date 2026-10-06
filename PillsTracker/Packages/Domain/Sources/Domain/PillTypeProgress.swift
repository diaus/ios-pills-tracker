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

/// One Pill Type's progress on a Day: what `DailyProgress` reports per Pill Type with a Prescription.
public struct PillTypeProgress: Identifiable, Hashable, Sendable {
    public let aggregate: PillTypeAggregate
    public let prescriptionState: PrescriptionState
    /// The Prescription's current Slots in Morning/Day/Evening order, Done or Open for the Day.
    public let slots: [SlotProgress]
    /// Present pills on the Current Blister.
    public let presentCount: Int

    public init(aggregate: PillTypeAggregate, prescriptionState: PrescriptionState, slots: [SlotProgress], presentCount: Int) {
        self.aggregate = aggregate
        self.prescriptionState = prescriptionState
        self.slots = slots
        self.presentCount = presentCount
    }

    public var id: UUID { aggregate.id }

    public var openSlots: [Slot] { slots.filter { !$0.isDone }.map(\.slot) }

    /// Completed: no Slot is Open on the Day.
    public var isCompleted: Bool { openSlots.isEmpty }

    /// Fewer Present pills than Open Slots: the user needs a new strip before the Day is over.
    public var isLowStock: Bool { presentCount < openSlots.count }

    public func intake(for slot: Slot) -> Intake? {
        slots.first { $0.slot == slot }?.intake
    }

    public func isDone(_ slot: Slot) -> Bool {
        intake(for: slot) != nil
    }
}
