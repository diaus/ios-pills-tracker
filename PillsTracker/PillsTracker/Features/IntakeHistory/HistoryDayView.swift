import Domain
import SwiftUI

/// A single Day of Intake History: the day number, its Intake count top-left when there is one, and
/// top-right a green check for a Completed Day or a red cross for one that isn't. Today has an outline
/// ring, the Selected Day a gray fill, and spill-over and future Days are dimmed.
struct HistoryDayView: View {
    let day: Day
    /// nil until the month's history has loaded.
    let historyDay: PillTypeHistory.HistoryDay?
    let isInMonth: Bool
    let isToday: Bool
    let isSelected: Bool
    let isFuture: Bool

    private let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)

    var body: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                Text(day.day, format: .number)
                    .font(.body)
            }
            .overlay(alignment: .topLeading) {
                if let count = historyDay?.intakeCount, count > 0 {
                    Text(count, format: .number)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .padding(3)
                }
            }
            .overlay(alignment: .topTrailing) {
                if let isCompleted = historyDay?.isCompleted {
                    Image(systemName: isCompleted ? "checkmark" : "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(isCompleted ? .green : .red)
                        .padding(3)
                }
            }
            .background {
                if isSelected {
                    shape.fill(Color(.secondarySystemFill))
                }
            }
            .overlay {
                if isToday {
                    shape.strokeBorder(.primary, lineWidth: 2)
                }
            }
            .opacity(isInMonth && !isFuture ? 1 : 0.35)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var accessibilityLabel: Text {
        var label = Text(day.date(), format: .dateTime.month(.wide).day())
        if let count = historyDay?.intakeCount, count > 0 {
            label = label + Text(verbatim: ", ") + Text(.historyIntakeCount(count: count))
        }
        if let isCompleted = historyDay?.isCompleted {
            label = label + Text(verbatim: ", ") + Text(isCompleted ? .historyCompleted : .historyNotCompleted)
        }
        return label
    }
}
