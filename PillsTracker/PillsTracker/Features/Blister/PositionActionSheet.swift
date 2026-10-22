import Domain
import SwiftUI

/// Action sheet shown after tapping a Position, rendering the actions it offered when tapped. A Present
/// one lists the Slots it can be consumed for, plus "remove without prescription" (a Sync Edit); an Empty
/// one without an Intake can be set Present (a Sync Edit). Undo is routed to its own confirmation.
private struct PositionActionSheet: ViewModifier {
    @Binding var tapped: TappedPosition?
    /// Shown above the actions when set, e.g. to name a past Day being consumed for.
    let title: Text?
    let onConsume: (Position, Slot) -> Void
    let onSync: (Position, _ isPresent: Bool) -> Void

    func body(content: Content) -> some View {
        content.confirmationDialog(
            title ?? Text(.blisterPositionTitle),
            isPresented: Binding(get: { tapped != nil }, set: { if !$0 { tapped = nil } }),
            titleVisibility: title == nil ? .hidden : .visible,
            presenting: tapped
        ) { tapped in
            switch tapped.actions {
            case .consume(let slots):
                ForEach(slots, id: \.self) { slot in
                    Button(slot.consumeTitle) {
                        onConsume(tapped.position, slot)
                    }
                }
                Button(.blisterPositionRemoveWithoutPrescription, role: .destructive) {
                    onSync(tapped.position, false)
                }
            case .setPresent:
                Button(.blisterPositionSetPresent) {
                    onSync(tapped.position, true)
                }
            case .undo, .nothing:
                EmptyView()
            }
            Button(.commonCancel, role: .cancel) {}
        }
    }
}

extension View {
    func positionActionSheet(
        for tapped: Binding<TappedPosition?>,
        title: Text?,
        onConsume: @escaping (Position, Slot) -> Void,
        onSync: @escaping (Position, _ isPresent: Bool) -> Void
    ) -> some View {
        modifier(PositionActionSheet(tapped: tapped, title: title, onConsume: onConsume, onSync: onSync))
    }
}
