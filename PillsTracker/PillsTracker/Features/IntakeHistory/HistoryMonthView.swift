import Domain
import SwiftUI

/// One month of Intake History as a calendar grid: a month-and-year title, a weekday header row and
/// one view per Day. Tapping a Day up to today chooses it.
struct HistoryMonthView: View {
    let month: HistoryMonth
    /// nil until the month has loaded.
    let history: PillTypeHistory?
    let today: Day
    let selectedDay: Day
    let onSelect: (Day) -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(month.firstDay.date(), format: .dateTime.month(.wide).year())
                .font(.title2)
                .fontWeight(.semibold)

            Grid(horizontalSpacing: 4, verticalSpacing: 4) {
                GridRow {
                    ForEach(Array(HistoryMonth.weekdaySymbols().enumerated()), id: \.offset) { _, symbol in
                        Text(symbol)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                ForEach(month.weeks(), id: \.first) { week in
                    GridRow {
                        ForEach(week, id: \.self) { day in
                            dayView(for: day)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private func dayView(for day: Day) -> some View {
        let isFuture = day > today
        return Button {
            onSelect(day)
        } label: {
            HistoryDayView(
                day: day,
                historyDay: history?.day(day),
                isInMonth: month.contains(day),
                isToday: day == today,
                isSelected: day == selectedDay,
                isFuture: isFuture
            )
        }
        .buttonStyle(.plain)
        .disabled(isFuture)
    }
}

/// A month whose Days cover every mark: counts, Completed, not Completed, unjudged today and future Days.
private let previewToday = Day(year: 2026, month: 10, day: 20)
private let previewHistory: PillTypeHistory = {
    let pillTypeID = UUID()
    let prescription = try! Prescription(pillTypeID: pillTypeID, slots: [.morning, .evening], startDay: Day(year: 2026, month: 10, day: 5))
    let intakes = [(14, Slot.morning), (14, .evening), (15, .morning), (19, .morning), (19, .evening), (20, .morning), (3, .morning)].map { day, slot in
        Intake(pillTypeID: pillTypeID, blisterID: UUID(), position: Position(row: 0, column: 0), slot: slot, day: Day(year: 2026, month: 10, day: day), instant: .now)
    }
    return PillTypeHistory(prescription: prescription, intakes: intakes, today: previewToday)
}()

#Preview("Light") {
    HistoryMonthView(month: HistoryMonth(containing: previewToday), history: previewHistory, today: previewToday, selectedDay: Day(year: 2026, month: 10, day: 15)) { _ in }
}

#Preview("Dark") {
    HistoryMonthView(month: HistoryMonth(containing: previewToday), history: previewHistory, today: previewToday, selectedDay: previewToday) { _ in }
        .preferredColorScheme(.dark)
}
