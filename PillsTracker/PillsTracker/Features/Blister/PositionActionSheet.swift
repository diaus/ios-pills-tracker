import Domain
import SwiftUI

/// A tapped Position together with the state it had when tapped, so the sheet offers the right action.
struct TappedPosition: Identifiable, Hashable {
    let position: Position
    let isPresent: Bool

    var id: Position { position }
}

/// Action sheet shown after tapping a Position: an Empty one can be marked Present,
/// a Present one can be removed without a Prescription. Both are Sync Edits.
private struct PositionActionSheet: ViewModifier {
    @Binding var tapped: TappedPosition?
    let onSync: (Position, _ isPresent: Bool) -> Void

    func body(content: Content) -> some View {
        content.confirmationDialog(
            "blister.position.title",
            isPresented: Binding(get: { tapped != nil }, set: { if !$0 { tapped = nil } }),
            titleVisibility: .hidden,
            presenting: tapped
        ) { tapped in
            if tapped.isPresent {
                Button("blister.position.removeWithoutPrescription", role: .destructive) {
                    onSync(tapped.position, false)
                }
            } else {
                Button("blister.position.markPresent") {
                    onSync(tapped.position, true)
                }
            }
            Button("common.cancel", role: .cancel) {}
        }
    }
}

extension View {
    func positionActionSheet(
        for tapped: Binding<TappedPosition?>,
        onSync: @escaping (Position, _ isPresent: Bool) -> Void
    ) -> some View {
        modifier(PositionActionSheet(tapped: tapped, onSync: onSync))
    }
}
