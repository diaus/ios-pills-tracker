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
}
