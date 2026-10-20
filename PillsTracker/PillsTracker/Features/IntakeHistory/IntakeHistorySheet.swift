import Domain
import SwiftUI

/// Intake History of one Pill Type, opened from the Blister screen: one month per page, paged vertically,
/// unbounded into the past and ending at the month of today. Tapping a Day up to today makes it the
/// Selected Day and closes the sheet.
///
/// Pages are identified by their offset from today's month (0, then negative), so months are built and
/// loaded lazily as they scroll into view. The window of offsets grows as the user nears its top, which
/// keeps the scroll content finite while going back never hits a wall.
struct IntakeHistorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var model: IntakeHistoryViewModel
    let selectedDay: Day
    let onSelect: (Day) -> Void

    /// Offsets from today's month that currently have a page; grows into the past on demand.
    @State private var offsets = -Self.growthStep...0
    /// The page the scroll view is on, identified by offset. Starts at 0, today's month.
    @State private var position = ScrollPosition(id: 0)

    private var visibleOffset: Int? { position.viewID(type: Int.self) }

    /// How many months the window grows by at a time, and how close to its top triggers growth.
    private static let growthStep = 12
    private static let edgeThreshold = 3

    init(pillTypeID: UUID, today: Day, selectedDay: Day, onSelect: @escaping (Day) -> Void) {
        _model = State(initialValue: IntakeHistoryViewModel(pillTypeID: pillTypeID, today: today))
        self.selectedDay = selectedDay
        self.onSelect = onSelect
    }

    var body: some View {
        NavigationStack {
            // The scroll view covers the whole sheet, under the navigation bar too, so every page is
            // exactly as tall as what paging scrolls by; each page keeps its content inside the safe area.
            GeometryReader { geometry in
                let insets = geometry.safeAreaInsets
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        let currentMonth = HistoryMonth(containing: model.today)
                        ForEach(offsets, id: \.self) { offset in
                            let month = currentMonth.advanced(by: offset)
                            HistoryMonthView(
                                month: month,
                                history: model.histories[month],
                                today: model.today,
                                selectedDay: selectedDay
                            ) { day in
                                onSelect(day)
                                dismiss()
                            }
                            .padding(insets)
                            .frame(height: geometry.size.height + insets.top + insets.bottom)
                            .task { await model.load(month) }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .scrollIndicators(.hidden)
                .scrollPosition($position)
                .ignoresSafeArea()
            }
            .navigationTitle(.historyTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(.commonDone) { dismiss() }
                }
            }
            .onChange(of: visibleOffset, initial: true) { _, offset in
                extendWindow(around: offset)
            }
            .errorAlert(message: $model.errorMessage)
        }
    }

    /// Adds another chunk of months above when `offset` is close to the top of the window.
    ///
    /// Growing the window above the visible page would otherwise shift the content under the
    /// viewport, so the same page is requested again to keep it in place.
    private func extendWindow(around offset: Int?) {
        guard let offset, offset - offsets.lowerBound < Self.edgeThreshold else { return }
        offsets = (offsets.lowerBound - Self.growthStep)...offsets.upperBound
        position.scrollTo(id: offset)
    }
}
