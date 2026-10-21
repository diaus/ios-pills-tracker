import SwiftUI
import WidgetKit

/// The circular Lock Screen face: the Abbreviation over a row of today's Slots, or the empty state.
struct PillTypeWidgetView: View {
    let content: PillTypeWidgetContent

    var body: some View {
        switch content {
        case .noPillType, .unreadable:
            Image(systemName: "pills")
                .font(.system(size: 30))
        case .withoutActivePrescription(let abbreviation):
            PillTypeFace(abbreviation: abbreviation) {
                Text(verbatim: "-/-/-")
                    .font(.system(size: 9, weight: .semibold))
            }
            .opacity(0.5)
        case .withActivePrescription(let abbreviation, let slotsDone):
            PillTypeFace(abbreviation: abbreviation) {
                SlotDotsRow(slotsDone: slotsDone, isCompleted: content.isCompleted)
            }
        }
    }
}

/// A Pill Type's face: the small `pill` symbol at the top right, the Abbreviation in the middle, and
/// `footer` at the bottom.
private struct PillTypeFace<Footer: View>: View {
    let abbreviation: String
    @ViewBuilder let footer: Footer

    var body: some View {
        VStack(spacing: 1) {
            Text(abbreviation)
                .font(.system(size: 26, weight: .semibold, design: .rounded))
                .lineLimit(2)
                .minimumScaleFactor(0.4)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            footer
                .frame(height: 9)
        }
        .padding(.horizontal, 9)
        .padding(.top, 13)
        .padding(.bottom, 8)
        .overlay(alignment: .topTrailing) {
            Image(systemName: "pill")
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                // Inside the circle's edge at the top right.
                .padding(.top, 9)
                .padding(.trailing, 13)
        }
    }
}

/// One circle per prescribed Slot, filled when Done, then a checkmark of the same size once Completed.
private struct SlotDotsRow: View {
    let slotsDone: [Bool]
    let isCompleted: Bool

    private let size: CGFloat = 6

    var body: some View {
        HStack(spacing: 3) {
            ForEach(slotsDone.indices, id: \.self) { index in
                if slotsDone[index] {
                    Circle()
                        .frame(width: size, height: size)
                } else {
                    Circle()
                        .strokeBorder(lineWidth: 1)
                        .frame(width: size, height: size)
                }
            }
            if isCompleted {
                Image(systemName: "checkmark")
                    .resizable()
                    .scaledToFit()
                    .fontWeight(.bold)
                    .frame(width: size, height: size)
            }
        }
    }
}
