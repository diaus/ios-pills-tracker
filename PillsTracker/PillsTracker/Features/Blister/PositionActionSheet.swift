import Domain
import SwiftUI

/// A tapped Position together with the state it had when tapped, so the sheet offers the right action.
struct TappedPosition: Identifiable, Hashable {
    let position: Position
    let isPresent: Bool

    var id: Position { position }
}

/// Action sheet shown after tapping a Position. A Present one lists today's Open Slots to Consume for,
/// plus "remove without prescription" (a Sync Edit); with no Open Slot only the Sync Edit remains.
/// An Empty one can only be marked Present (a Sync Edit); Consume from Empty is refused in Domain.
private struct PositionActionSheet: ViewModifier {
    @Binding var tapped: TappedPosition?
    let openSlots: [Slot]
    let onConsume: (Position, Slot) -> Void
    let onSync: (Position, _ isPresent: Bool) -> Void

    func body(content: Content) -> some View {
        content.confirmationDialog(
            "blister.position.title",
            isPresented: Binding(get: { tapped != nil }, set: { if !$0 { tapped = nil } }),
            titleVisibility: .hidden,
            presenting: tapped
        ) { tapped in
            if tapped.isPresent {
                ForEach(openSlots, id: \.self) { slot in
                    Button(slot.consumeTitle) {
                        onConsume(tapped.position, slot)
                    }
                }
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
        openSlots: [Slot],
        onConsume: @escaping (Position, Slot) -> Void,
        onSync: @escaping (Position, _ isPresent: Bool) -> Void
    ) -> some View {
        modifier(PositionActionSheet(tapped: tapped, openSlots: openSlots, onConsume: onConsume, onSync: onSync))
    }
}
