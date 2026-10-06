import Domain
import SwiftUI

/// The grid mirroring the Blister. Present and Empty Positions are visually distinct.
/// Reusable at small sizes (Home mini grid) by passing a smaller `positionSpacing` and no tap handler.
struct BlisterGridView: View {
    let shape: GridShape
    let presentPositions: Set<Position>
    var positionSpacing: CGFloat = 8
    var onTap: ((Position) -> Void)? = nil

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: positionSpacing), count: shape.columns)
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: positionSpacing) {
            ForEach(shape.allPositions, id: \.self) { position in
                let isPresent = presentPositions.contains(position)
                PositionTile(isPresent: isPresent)
                    .aspectRatio(1, contentMode: .fit)
                    .contentShape(Rectangle())
                    .onTapGesture { onTap?(position) }
                    .accessibilityLabel(Text(isPresent ? "position.present" : "position.empty"))
            }
        }
    }
}

private struct PositionTile: View {
    let isPresent: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(.secondary.opacity(0.4), lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 8).fill(.secondary.opacity(0.08)))
            if isPresent {
                Circle()
                    .fill(Color.accentColor)
                    .padding(6)
            }
        }
    }
}

#Preview {
    BlisterGridView(
        shape: try! GridShape(rows: 3, columns: 4),
        presentPositions: [Position(row: 0, column: 0), Position(row: 1, column: 2)]
    )
    .padding()
}
