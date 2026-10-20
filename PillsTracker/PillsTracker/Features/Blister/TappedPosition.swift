import Domain

/// A tapped Position together with the state it had when tapped, so the sheet offers the right action.
struct TappedPosition: Identifiable, Hashable {
    let position: Position
    let isPresent: Bool

    var id: Position { position }
}
