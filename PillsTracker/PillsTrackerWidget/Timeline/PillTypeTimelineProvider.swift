import Domain
import Foundation
import WidgetKit

/// Builds the widget's entries from the App Group store: one for now and one at the next rollover, each
/// with the Pill Type's progress for what Today is at that moment (ADR 0004).
nonisolated struct PillTypeTimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> PillTypeWidgetEntry {
        PillTypeWidgetEntry(date: .now, pillTypeID: nil, content: .sample)
    }

    func snapshot(for configuration: PillTypeWidgetIntent, in context: Context) async -> PillTypeWidgetEntry {
        if context.isPreview, configuration.pillType == nil {
            return PillTypeWidgetEntry(date: .now, pillTypeID: nil, content: .sample)
        }
        return await entries(for: configuration.pillType?.id, at: [.now])[0]
    }

    func timeline(for configuration: PillTypeWidgetIntent, in context: Context) async -> Timeline<PillTypeWidgetEntry> {
        let now = Date.now
        let dates = [now] + [Day.nextRollover(after: now, calendar: .current)].compactMap(\.self)
        let entries = await entries(for: configuration.pillType?.id, at: dates)
        // At the rollover entry WidgetKit asks again, so the timeline always reaches the next one. A store
        // that couldn't be read is tried again soon instead.
        let policy: TimelineReloadPolicy = entries.contains { $0.content == .unreadable }
            ? .after(now.addingTimeInterval(Self.retryDelay))
            : .atEnd
        return Timeline(entries: entries, policy: policy)
    }

    /// How long a widget whose store couldn't be read waits before WidgetKit asks again.
    private static let retryDelay: TimeInterval = 15 * 60

    /// One entry per date, for the Pill Type `pillTypeID`: no Pill Type when it's nil or deleted, and
    /// unreadable when the store can't be read.
    private func entries(for pillTypeID: UUID?, at dates: [Date]) async -> [PillTypeWidgetEntry] {
        var entries: [PillTypeWidgetEntry] = []
        for date in dates {
            let content: PillTypeWidgetContent
            if let pillTypeID {
                do {
                    content = PillTypeWidgetContent(progress: try await progress(of: pillTypeID, on: Day.current(at: date, calendar: .current)))
                } catch {
                    content = .unreadable
                }
            } else {
                content = .noPillType
            }
            entries.append(PillTypeWidgetEntry(date: date, pillTypeID: pillTypeID, content: content))
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
