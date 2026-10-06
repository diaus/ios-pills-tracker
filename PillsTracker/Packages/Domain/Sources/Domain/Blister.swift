import Foundation

/// Whether a Blister is the one being consumed right now or a former one kept for history.
public enum BlisterState: String, Sendable, Hashable, Codable {
    case current
    case retired
}

/// A physical strip of pills of one Pill Type, laid out as a rectangular grid.
/// Positions not listed in `presentPositions` are Empty.
public struct Blister: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let pillTypeID: UUID
    public var state: BlisterState
    public var presentPositions: Set<Position>

    public init(id: UUID = UUID(), pillTypeID: UUID, state: BlisterState, presentPositions: Set<Position>) {
        self.id = id
        self.pillTypeID = pillTypeID
        self.state = state
        self.presentPositions = presentPositions
    }

    /// A fresh Current Blister where every Position of `shape` is Present.
    public static func fresh(pillTypeID: UUID, shape: GridShape) -> Blister {
        Blister(pillTypeID: pillTypeID, state: .current, presentPositions: Set(shape.allPositions))
    }

    public func isPresent(_ position: Position) -> Bool {
        presentPositions.contains(position)
    }

    public var isEmpty: Bool { presentPositions.isEmpty }
}
