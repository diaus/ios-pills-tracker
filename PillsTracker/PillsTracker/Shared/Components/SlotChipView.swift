import Domain
import SwiftUI

/// The icon chip of one prescribed Slot on a Home card or the Blister screen: Open, or Done once
/// an Intake exists for the Slot today.
struct SlotChipView: View {
    let slot: Slot
    let isDone: Bool

    var body: some View {
        HStack(spacing: 3) {
            if isDone {
                Image(systemName: "checkmark")
                    .font(.caption2.weight(.bold))
            }
            Image(systemName: slot.systemImage)
                .font(.caption)
        }
        .foregroundStyle(isDone ? .green : .primary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isDone ? Color.green.opacity(0.18) : Color.accentColor.opacity(0.18), in: Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(slot.title))
        .accessibilityValue(Text(isDone ? .slotChipDone : .slotChipOpen))
    }
}

#Preview {
    HStack {
        SlotChipView(slot: .morning, isDone: true)
        SlotChipView(slot: .day, isDone: false)
        SlotChipView(slot: .evening, isDone: false)
    }
    .padding()
}
