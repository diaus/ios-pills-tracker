import Domain
import SwiftUI

/// Action sheet shown after tapping a Position. A Present one lists the Slots it can be consumed for
/// (today's Open Slots of an Active Prescription), plus "remove without prescription" (a Sync Edit);
/// with nothing consumable only the Sync Edit remains.
/// An Empty one can only be set Present (a Sync Edit) when it has no Intake; Consume from Empty is refused
/// in Domain. An Empty one with an Intake is routed to Undo before this sheet.
private struct PositionActionSheet: ViewModifier {
    @Binding var tapped: TappedPosition?
    /// Shown above the actions when set, e.g. to name a past Day being consumed for.
    let title: Text?
    let consumableSlots: (Position) -> [Slot]
    let canSetPresent: (Position) -> Bool
    let onConsume: (Position, Slot) -> Void
    let onSync: (Position, _ isPresent: Bool) -> Void

    func body(content: Content) -> some View {
        content.confirmationDialog(
            title ?? Text(.blisterPositionTitle),
            isPresented: Binding(get: { tapped != nil }, set: { if !$0 { tapped = nil } }),
            titleVisibility: title == nil ? .hidden : .visible,
            presenting: tapped
        ) { tapped in
            if tapped.isPresent {
                ForEach(consumableSlots(tapped.position), id: \.self) { slot in
                    Button(slot.consumeTitle) {
                        onConsume(tapped.position, slot)
                    }
                }
                Button(.blisterPositionRemoveWithoutPrescription, role: .destructive) {
                    onSync(tapped.position, false)
                }
            } else if canSetPresent(tapped.position) {
                Button(.blisterPositionSetPresent) {
                    onSync(tapped.position, true)
                }
            }
            Button(.commonCancel, role: .cancel) {}
        }
    }
}

extension View {
    func positionActionSheet(
        for tapped: Binding<TappedPosition?>,
        title: Text?,
        consumableSlots: @escaping (Position) -> [Slot],
        canSetPresent: @escaping (Position) -> Bool,
        onConsume: @escaping (Position, Slot) -> Void,
        onSync: @escaping (Position, _ isPresent: Bool) -> Void
    ) -> some View {
        modifier(PositionActionSheet(tapped: tapped, title: title, consumableSlots: consumableSlots, canSetPresent: canSetPresent, onConsume: onConsume, onSync: onSync))
    }
}
