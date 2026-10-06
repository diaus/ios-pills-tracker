import Domain
import SwiftUI

/// What a Slot chip conveys for one Prescription today.
/// Ticket 05 adds `.done` (an Intake exists for the Slot today).
enum SlotChipState {
    case notPrescribed
    case open
}

/// One of the three Morning / Day / Evening chips on a Home card.
struct SlotChipView: View {
    let slot: Slot
    let state: SlotChipState

    var body: some View {
        Text(slot.title)
            .font(.caption)
            .fontWeight(state == .notPrescribed ? .regular : .medium)
            .foregroundStyle(foreground)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(background, in: Capsule())
            .accessibilityLabel(Text(slot.title))
            .accessibilityValue(Text(accessibilityValue))
    }

    private var foreground: Color {
        switch state {
        case .notPrescribed: .secondary
        case .open: .primary
        }
    }

    private var background: Color {
        switch state {
        case .notPrescribed: .secondary.opacity(0.1)
        case .open: .accentColor.opacity(0.18)
        }
    }

    private var accessibilityValue: LocalizedStringKey {
        switch state {
        case .notPrescribed: "slotChip.notPrescribed"
        case .open: "slotChip.open"
        }
    }
}

#Preview {
    HStack {
        SlotChipView(slot: .morning, state: .open)
        SlotChipView(slot: .day, state: .notPrescribed)
        SlotChipView(slot: .evening, state: .open)
    }
    .padding()
}
