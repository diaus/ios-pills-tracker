import Domain
import Foundation
import WidgetKit

/// Builds the widget's entries from the App Group store: one for now and one at the next rollover, each
/// with the Pill Type's progress for what Today is at that moment (ADR 0004).
nonisolated struct PillTypeTimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> PillTypeWidgetEntry {
        PillTypeWidgetEntry(date: .now, content: .sample)
    }

    func snapshot(for configuration: PillTypeWidgetIntent, in context: Context) async -> PillTypeWidgetEntry {
        if context.isPreview, configuration.pillType == nil {
            return PillTypeWidgetEntry(date: .now, content: .sample)
        }
        return await entries(for: configuration.pillType?.id, at: [.now])[0]
    }

    func timeline(for configuration: PillTypeWidgetIntent, in context: Context) async -> Timeline<PillTypeWidgetEntry> {
        let now = Date.now
        let dates = [now] + [Day.nextRollover(after: now, calendar: .current)].compactMap(\.self)
        // At the rollover entry WidgetKit asks again, so the timeline always reaches the next one.
        return Timeline(entries: await entries(for: configuration.pillType?.id, at: dates), policy: .atEnd)
    }

    /// One entry per date, for the Pill Type `pillTypeID`; the empty state when it's nil, deleted or unreadable.
    private func entries(for pillTypeID: UUID?, at dates: [Date]) async -> [PillTypeWidgetEntry] {
        var entries: [PillTypeWidgetEntry] = []
        for date in dates {
            var progress: PillTypeProgress?
            if let pillTypeID {
                progress = try? await self.progress(of: pillTypeID, on: Day.current(at: date, calendar: .current))
            }
            entries.append(PillTypeWidgetEntry(date: date, content: PillTypeWidgetContent(progress: progress)))
        }
        return entries
    }

    /// The Pill Type's progress on `day`, from a fresh read of the store; nil when there's no such Pill Type.
    private func progress(of pillTypeID: UUID, on day: Day) async throws -> PillTypeProgress? {
        guard let repository = try WidgetStore.repository(),
              let aggregate = try await repository.fetch(id: pillTypeID) else { return nil }
        let intakes = try await repository.intakes(on: day, pillTypeID: pillTypeID)
        return PillTypeProgress(aggregate: aggregate, day: day, intakes: intakes)
    }
}
