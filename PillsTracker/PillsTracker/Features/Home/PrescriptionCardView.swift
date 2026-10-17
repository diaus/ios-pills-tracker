import Domain
import SwiftUI

/// Home card for one Active Prescription: Pill Type name, today's Slot chips (Done / Open / not prescribed),
/// a Completed state when nothing is Open, a low-stock warning, and the mini Current Blister grid.
struct PrescriptionCardView: View {
    let progress: PillTypeProgress

    private var aggregate: PillTypeAggregate { progress.aggregate }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text(aggregate.pillType.name)
                    .font(.headline)
                HStack(spacing: 6) {
                    ForEach(Slot.allCases, id: \.self) { slot in
                        SlotChipView(slot: slot, state: progress.chipState(for: slot))
                    }
                }
                if progress.isCompleted {
                    Label(.homeCompleted, systemImage: "checkmark.circle.fill")
                        .font(.footnote)
                        .foregroundStyle(.green)
                }
                if progress.isLowStock {
                    Label(.homeLowStock, systemImage: "exclamationmark.triangle.fill")
                        .font(.footnote)
                        .foregroundStyle(.orange)
                }
            }
            Spacer(minLength: 0)
            if let blister = aggregate.currentBlister {
                BlisterGridView(shape: blister.shape, presentPositions: blister.presentPositions, positionSpacing: 3)
                    .frame(width: 84)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, 6)
    }
}
