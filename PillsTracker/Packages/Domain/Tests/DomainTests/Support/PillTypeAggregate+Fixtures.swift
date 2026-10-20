import Domain

extension PillTypeAggregate {
    /// Sync Edits the Current Blister so exactly `present` are Present, as a user matching the app to the Blister in hand.
    mutating func syncCurrentBlister(present: Set<Position>) throws {
        for position in currentBlister?.shape.allPositions ?? [] {
            try syncPosition(position, isPresent: present.contains(position), blisterIntakes: [])
        }
    }

    /// The same aggregate with `blister` added ahead of the existing Blisters.
    func inserting(_ blister: Blister) -> PillTypeAggregate {
        PillTypeAggregate(pillType: pillType, blisters: [blister] + blisters, prescription: prescription)
    }

    /// Creates a Prescription with `slots` starting on a fixed Day, or edits the existing one's Slots
    /// keeping its Days, for tests where the Start Day and End Day don't matter.
    mutating func setPrescriptionSlots(_ slots: Set<Slot>) throws(DomainError) {
        try setPrescription(
            slots: slots,
            startDay: prescription?.startDay ?? Day(year: 2026, month: 1, day: 1),
            endDay: prescription?.endDay
        )
    }
}
