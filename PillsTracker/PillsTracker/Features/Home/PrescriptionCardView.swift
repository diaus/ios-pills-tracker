import Domain
import SwiftUI

/// Home card for one Active Prescription: Pill Type name, mini Current Blister grid and the three Slot chips.
struct PrescriptionCardView: View {
    let aggregate: PillTypeAggregate

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text(aggregate.pillType.name)
                    .font(.headline)
                HStack(spacing: 6) {
                    ForEach(Slot.allCases, id: \.self) { slot in
                        SlotChipView(slot: slot, state: chipState(for: slot))
                    }
                }
            }
            Spacer(minLength: 0)
            if let blister = aggregate.currentBlister {
                BlisterGridView(shape: aggregate.pillType.shape, presentPositions: blister.presentPositions, cellSpacing: 3)
                    .frame(width: 84)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, 6)
    }

    private func chipState(for slot: Slot) -> SlotChipState {
        aggregate.prescription?.contains(slot) == true ? .open : .notPrescribed
    }
}
