import Foundation

/// A Blister of one Pill Type: its pills laid out as a rectangular grid of Positions.
/// Each Blister keeps the shape it was started with, so a later shape change of the Pill Type
/// applies only to the next Start New Blister. Positions not listed in `presentPositions` are Empty.
public struct Blister: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let pillTypeID: UUID
    public let shape: GridShape
    public var state: BlisterState
    public var presentPositions: Set<Position>

    public init(id: UUID = UUID(), pillTypeID: UUID, shape: GridShape, state: BlisterState, presentPositions: Set<Position>) {
        self.id = id
        self.pillTypeID = pillTypeID
        self.shape = shape
        self.state = state
        self.presentPositions = presentPositions
    }

    /// A fresh Current Blister where every Position of `shape` is Present.
    public static func fresh(pillTypeID: UUID, shape: GridShape) -> Blister {
        Blister(pillTypeID: pillTypeID, shape: shape, state: .current, presentPositions: Set(shape.allPositions))
    }

    public func isPresent(_ position: Position) -> Bool {
        presentPositions.contains(position)
    }

    /// Whether `position` lies inside this Blister's grid.
    public func contains(_ position: Position) -> Bool {
        shape.contains(position)
    }

    public var isEmpty: Bool { presentPositions.isEmpty }
}
