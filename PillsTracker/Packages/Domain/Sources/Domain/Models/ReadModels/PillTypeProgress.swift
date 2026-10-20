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
/// the same preconditions the aggregate enforces. Built by `DailyProgress` for every Pill Type.
public struct PillTypeProgress: Identifiable, Hashable, Sendable {
    public let aggregate: PillTypeAggregate
    public let day: Day
    /// The Prescription's current Slots in Morning/Day/Evening order, Done or Open for the Day; empty without a Prescription.
    public let slots: [SlotProgress]
    /// Every Intake from the Current Blister, on any Day.
    public let blisterIntakes: [Intake]

    /// `intakes` may hold any Pill Type's Intakes from any Day; this Pill Type's Intakes on `day` make
    /// its Slots Done, and those on the Current Blister drive Undo and Sync Edit.
    public init(aggregate: PillTypeAggregate, day: Day, intakes: [Intake]) {
        self.aggregate = aggregate
        self.day = day
        blisterIntakes = intakes.filter { $0.pillTypeID == aggregate.id && $0.blisterID == aggregate.currentBlister?.id }
        let own = intakes.filter { $0.pillTypeID == aggregate.id && $0.day == day }
        slots = Slot.allCases
            .filter { aggregate.prescription?.contains($0) ?? false }
            .map { slot in SlotProgress(slot: slot, intake: own.first { $0.slot == slot }) }
    }

    public var id: UUID { aggregate.id }
    public var pillType: PillType { aggregate.pillType }
    public var currentBlister: Blister? { aggregate.currentBlister }
    /// nil while the Pill Type has no Prescription.
    public var prescriptionState: PrescriptionState? { aggregate.prescription?.state }
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
        guard let intake = intake(for: slot), aggregate.canUndo(intake, blisterIntakes: blisterIntakes) else { return nil }
        return intake
    }

    /// The Intake that emptied `position` of the Current Blister, on any Day, which Undo would accept.
    /// nil for a Present Position, or one emptied by a Sync Edit.
    public func undoableIntake(at position: Position) -> Intake? {
        guard let blister = currentBlister, blister.contains(position), !blister.isPresent(position),
              let intake = PillTypeAggregate.latestIntake(at: position, in: blisterIntakes),
              aggregate.canUndo(intake, blisterIntakes: blisterIntakes) else { return nil }
        return intake
    }

    /// The Intake that emptied `position` of the Current Blister on the Day, which the grid marks.
    public func intakeOnDay(at position: Position) -> Intake? {
        guard let intake = undoableIntake(at: position), intake.day == day else { return nil }
        return intake
    }

    /// The Slot of each Empty Position of the Current Blister consumed on the Day, for the grid's mark.
    public var daySlotsByPosition: [Position: Slot] {
        Dictionary(uniqueKeysWithValues: (currentBlister?.shape.allPositions ?? []).compactMap { position in
            intakeOnDay(at: position).map { (position, $0.slot) }
        })
    }

    /// Empty Positions of the Current Blister whose Intake Undo would accept.
    public var undoablePositions: Set<Position> {
        Set((currentBlister?.shape.allPositions ?? []).filter { undoableIntake(at: $0) != nil })
    }

    /// A Sync Edit can set `position` Present only when it has no Intake: a Consume is reverted by Undo.
    public func canSetPresent(_ position: Position) -> Bool {
        (try? aggregate.validateSyncPosition(position, isPresent: true, blisterIntakes: blisterIntakes)) != nil
    }

    /// The Slots a pill at `position` can be consumed for right now, in Morning/Day/Evening order.
    public func consumableSlots(at position: Position) -> [Slot] {
        let done = doneSlots
        return openSlots.filter { slot in
            (try? aggregate.validateConsume(position: position, slot: slot, doneSlots: done)) != nil
        }
    }
}
