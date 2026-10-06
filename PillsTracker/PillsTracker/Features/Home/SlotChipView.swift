import Domain
import SwiftUI

/// What a Slot chip conveys for one Prescription today.
enum SlotChipState {
    case notPrescribed
    case open
    /// An Intake exists for the Slot today.
    case done
}

/// One of the three Morning / Day / Evening chips on a Home card or the Blister screen.
struct SlotChipView: View {
    let slot: Slot
    let state: SlotChipState

    var body: some View {
        HStack(spacing: 3) {
            if state == .done {
                Image(systemName: "checkmark")
                    .font(.caption2.weight(.bold))
            }
            Text(slot.title)
                .font(.caption)
                .fontWeight(state == .notPrescribed ? .regular : .medium)
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(background, in: Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(slot.title))
        .accessibilityValue(Text(accessibilityValue))
    }

    private var foreground: Color {
        switch state {
        case .notPrescribed: .secondary
        case .open: .primary
        case .done: .green
        }
    }

    private var background: Color {
        switch state {
        case .notPrescribed: .secondary.opacity(0.1)
        case .open: .accentColor.opacity(0.18)
        case .done: .green.opacity(0.18)
        }
    }

    private var accessibilityValue: LocalizedStringKey {
        switch state {
        case .notPrescribed: "slotChip.notPrescribed"
        case .open: "slotChip.open"
        case .done: "slotChip.done"
        }
    }
}

extension PillTypeProgress {
    /// The chip state of `slot` for this Pill Type today.
    func chipState(for slot: Slot) -> SlotChipState {
        guard let status = slots.first(where: { $0.slot == slot }) else { return .notPrescribed }
        return status.isDone ? .done : .open
    }
}

#Preview {
    HStack {
        SlotChipView(slot: .morning, state: .done)
        SlotChipView(slot: .day, state: .notPrescribed)
        SlotChipView(slot: .evening, state: .open)
    }
    .padding()
}
