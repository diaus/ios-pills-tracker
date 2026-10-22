import Domain

/// A tapped Position together with what it offered when tapped, so the sheet renders those actions.
struct TappedPosition: Identifiable, Hashable {
    let position: Position
    let actions: PositionActions

    var id: Position { position }
}
