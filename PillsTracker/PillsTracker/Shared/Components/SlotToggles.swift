import Domain
import SwiftUI

/// One toggle per Slot, in Morning / Day / Evening order, shared by the Add Pill Type and Prescription sheets.
struct SlotToggles: View {
    @Binding var selection: Set<Slot>

    var body: some View {
        ForEach(Slot.allCases, id: \.self) { slot in
            Toggle(isOn: Binding(
                get: { selection.contains(slot) },
                set: { isOn in
                    if isOn { selection.insert(slot) } else { selection.remove(slot) }
                }
            )) {
                Label {
                    Text(slot.title)
                } icon: {
                    Image(systemName: slot.systemImage)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selection: Set<Slot> = [.evening]
    Form {
        SlotToggles(selection: $selection)
    }
}
