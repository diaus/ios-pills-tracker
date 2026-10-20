import Domain
import SwiftUI

/// The grid mirroring the Blister. Present and Empty Positions are visually distinct, and an Empty
/// Position consumed on the Selected Day is marked with the Slot it was taken for.
/// Reusable at small sizes (Home mini grid) by passing a smaller `positionSpacing`, no marks and no tap handler.
struct BlisterGridView: View {
    let shape: GridShape
    let presentPositions: Set<Position>
    /// Empty Positions consumed on the Selected Day, with the Slot of their Intake.
    var daySlots: [Position: Slot] = [:]
    /// Empty Positions whose Intake can be undone by tapping them.
    var undoablePositions: Set<Position> = []
    var positionSpacing: CGFloat = 8
    var onTap: ((Position) -> Void)? = nil

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: positionSpacing), count: shape.columns)
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: positionSpacing) {
            ForEach(shape.allPositions, id: \.self) { position in
                let isPresent = presentPositions.contains(position)
                let daySlot = daySlots[position]
                PositionTile(isPresent: isPresent, daySlot: daySlot)
                    .aspectRatio(1, contentMode: .fit)
                    .contentShape(Rectangle())
                    .onTapGesture { onTap?(position) }
                    .accessibilityElement(children: .ignore)
                    .accessibilityAddTraits(onTap == nil ? [] : .isButton)
                    .accessibilityLabel(Text(isPresent ? .positionPresent : .positionEmpty))
                    .accessibilityValue(daySlot.map { Text(.positionIntakeOnDay(slot: String(localized: $0.title))) } ?? Text(verbatim: ""))
                    .accessibilityHint(undoablePositions.contains(position) ? Text(.blisterUndoHint) : Text(verbatim: ""))
            }
        }
    }
}

private struct PositionTile: View {
    let isPresent: Bool
    let daySlot: Slot?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(.secondary.opacity(0.4), lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 8).fill(.secondary.opacity(0.08)))
            if isPresent {
                Circle()
                    .fill(Color.accentColor)
                    .padding(6)
            } else if let daySlot {
                Image(systemName: "checkmark")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.green)
                Image(systemName: daySlot.systemImage)
                    .font(.caption2)
                    .foregroundStyle(.green)
                    .padding(4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
    }
}

#Preview {
    BlisterGridView(
        shape: try! GridShape(rows: 3, columns: 4),
        presentPositions: [Position(row: 0, column: 0), Position(row: 1, column: 2)],
        daySlots: [Position(row: 0, column: 1): .morning, Position(row: 2, column: 3): .evening]
    )
    .padding()
}
