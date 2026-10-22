import Foundation
import WidgetKit

/// Hands WidgetKit the entries `PillTypeWidgetTimeline` builds from the App Group store for the configured Pill Type.
nonisolated struct PillTypeTimelineProvider: AppIntentTimelineProvider {
    private let timeline = PillTypeWidgetTimeline(openStore: WidgetStore.repository)

    /// The empty state, not `.sample`: iOS keeps showing the placeholder while it has no configuration for a new
    /// widget, and a sample Pill Type there would read as real Slots.
    func placeholder(in context: Context) -> PillTypeWidgetEntry {
        PillTypeWidgetEntry(date: .now, pillTypeID: nil, content: .noPillType)
    }

    func snapshot(for configuration: PillTypeWidgetIntent, in context: Context) async -> PillTypeWidgetEntry {
        if context.isPreview, configuration.pillType == nil {
            return PillTypeWidgetEntry(date: .now, pillTypeID: nil, content: .sample)
        }
        return await timeline.entries(for: configuration.pillType?.id, at: [.now])[0]
    }

    func timeline(for configuration: PillTypeWidgetIntent, in context: Context) async -> Timeline<PillTypeWidgetEntry> {
        await timeline.timeline(for: configuration.pillType?.id, now: .now)
    }
}
