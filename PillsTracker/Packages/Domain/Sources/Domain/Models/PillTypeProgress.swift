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

/// Everything a screen needs about one Pill Type on a Day: the aggregate, its Prescription's Slots
/// Done or Open for the Day, and the affordances (what can be consumed, undone or started) drawn from
/// the same preconditions the use cases enforce. Built by `DailyProgress` for every Pill Type.
public struct PillTypeProgress: Identifiable, Hashable, Sendable {
    public let aggregate: PillTypeAggregate
    public let day: Day
    /// nil while the Pill Type has no Prescription.
    public let prescriptionState: PrescriptionState?
    /// The Prescription's current Slots in Morning/Day/Evening order, Done or Open for the Day; empty without a Prescription.
    public let slots: [SlotProgress]

    /// `intakes` may hold any Pill Type's Intakes from any Day; only this Pill Type's Intakes on `day` count.
    public init(aggregate: PillTypeAggregate, day: Day, intakes: [Intake]) {
        self.aggregate = aggregate
        self.day = day
        prescriptionState = aggregate.prescription?.state
        let own = intakes.filter { $0.pillTypeID == aggregate.id && $0.day == day }
        slots = Slot.allCases
            .filter { aggregate.prescription?.contains($0) ?? false }
            .map { slot in SlotProgress(slot: slot, intake: own.first { $0.slot == slot }) }
    }

    public var id: UUID { aggregate.id }
    public var pillType: PillType { aggregate.pillType }
    public var currentBlister: Blister? { aggregate.currentBlister }
    public var hasPrescription: Bool { prescriptionState != nil }

    /// Present pills on the Current Blister.
    public var presentCount: Int { currentBlister?.presentPositions.count ?? 0 }

    public var openSlots: [Slot] { slots.filter { !$0.isDone }.map(\.slot) }
    public var doneSlots: Set<Slot> { Set(slots.filter(\.isDone).map(\.slot)) }

    /// Completed: no Slot is Open on the Day.
    public var isCompleted: Bool { openSlots.isEmpty }

    /// Fewer Present pills than Open Slots: the user needs a new Blister before the Day is over.
    public var isLowStock: Bool { presentCount < openSlots.count }

    public func intake(for slot: Slot) -> Intake? {
        slots.first { $0.slot == slot }?.intake
    }

    public func isDone(_ slot: Slot) -> Bool {
        intake(for: slot) != nil
    }

    // MARK: Affordances

    /// Start New Blister is offered only once every Position is Empty.
    public var canStartNewBlister: Bool { aggregate.canStartNewBlister }

    /// The Intake behind a Done chip that Undo would accept, or nil.
    public func undoableIntake(for slot: Slot) -> Intake? {
        guard let intake = intake(for: slot), aggregate.canUndo(intake, on: day) else { return nil }
        return intake
    }

    /// The Slots a pill at `position` can be consumed for right now, in Morning/Day/Evening order.
    public func consumableSlots(at position: Position) -> [Slot] {
        let done = doneSlots
        return openSlots.filter { slot in
            (try? aggregate.validateConsume(position: position, slot: slot, doneSlots: done)) != nil
        }
    }
}
