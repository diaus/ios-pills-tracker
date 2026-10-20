import Domain
import SwiftUI

/// The grid mirroring the Blister. Present and Empty Positions are visually distinct, and an Empty
/// Position consumed today is marked with the Slot it was taken for.
/// Reusable at small sizes (Home mini grid) by passing a smaller `positionSpacing`, no marks and no tap handler.
struct BlisterGridView: View {
    let shape: GridShape
    let presentPositions: Set<Position>
    /// Empty Positions consumed today, with the Slot of their Intake.
    var todaysSlots: [Position: Slot] = [:]
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
                let todaysSlot = todaysSlots[position]
                PositionTile(isPresent: isPresent, todaysSlot: todaysSlot)
                    .aspectRatio(1, contentMode: .fit)
                    .contentShape(Rectangle())
                    .onTapGesture { onTap?(position) }
                    .accessibilityElement(children: .ignore)
                    .accessibilityAddTraits(onTap == nil ? [] : .isButton)
                    .accessibilityLabel(Text(isPresent ? .positionPresent : .positionEmpty))
                    .accessibilityValue(todaysSlot.map { Text(.positionIntakeToday(slot: String(localized: $0.title))) } ?? Text(verbatim: ""))
                    .accessibilityHint(undoablePositions.contains(position) ? Text(.blisterUndoHint) : Text(verbatim: ""))
            }
        }
    }
}

private struct PositionTile: View {
    let isPresent: Bool
    let todaysSlot: Slot?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(.secondary.opacity(0.4), lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 8).fill(.secondary.opacity(0.08)))
            if isPresent {
                Circle()
                    .fill(Color.accentColor)
                    .padding(6)
            } else if let todaysSlot {
                Image(systemName: "checkmark")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.green)
                Image(systemName: todaysSlot.systemImage)
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
        todaysSlots: [Position(row: 0, column: 1): .morning, Position(row: 2, column: 3): .evening]
    )
    .padding()
}
