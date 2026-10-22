import Domain
import Foundation
import WidgetKit

/// Builds the widget's entries for one Pill Type at given moments, each with the Pill Type's progress for what
/// Today is at that moment (ADR 0004), from a store opened once per call through `openStore`.
nonisolated struct PillTypeWidgetTimeline {
    /// A fresh repository over the App Group store, or nil while the app hasn't created it; throws when the store
    /// can't be read. Called once per `entries` or `timeline` call, so a long-lived widget process sees the app's
    /// latest save.
    private let openStore: () throws -> (any PillTypeRepository)?

    init(openStore: @escaping () throws -> (any PillTypeRepository)?) {
        self.openStore = openStore
    }

    /// How long a widget whose store couldn't be read waits before WidgetKit asks again.
    static let retryDelay: TimeInterval = 15 * 60

    /// One entry for `now` and one at the next rollover, so the widget always reaches the next Day. At the rollover
    /// entry WidgetKit asks again; a store that couldn't be read is tried again after `retryDelay` instead.
    func timeline(for pillTypeID: UUID?, now: Date) async -> Timeline<PillTypeWidgetEntry> {
        let moments = [now] + [Day.nextRollover(after: now, calendar: .current)].compactMap(\.self)
        let entries = await entries(for: pillTypeID, at: moments)
        let policy: TimelineReloadPolicy = entries.contains { $0.content == .unreadable }
            ? .after(now.addingTimeInterval(Self.retryDelay))
            : .atEnd
        return Timeline(entries: entries, policy: policy)
    }

    /// One entry per moment for the Pill Type `pillTypeID`: no Pill Type when it's nil, deleted or the store doesn't
    /// exist yet, and unreadable when the store can't be read.
    func entries(for pillTypeID: UUID?, at moments: [Date]) async -> [PillTypeWidgetEntry] {
        guard let pillTypeID else {
            return moments.map { PillTypeWidgetEntry(date: $0, pillTypeID: nil, content: .noPillType) }
        }
        let repository = Result { try openStore() }
        var entries: [PillTypeWidgetEntry] = []
        for moment in moments {
            let content: PillTypeWidgetContent
            do {
                let day = Day.current(at: moment, calendar: .current)
                content = PillTypeWidgetContent(progress: try await progress(of: pillTypeID, on: day, in: repository.get()))
            } catch {
                content = .unreadable
            }
            entries.append(PillTypeWidgetEntry(date: moment, pillTypeID: pillTypeID, content: content))
        }
        return entries
    }

    /// The Pill Type's progress on `day`, as Daily Progress computes it for the app (ADR 0003); nil when there's
    /// no such Pill Type, or no store yet.
    private func progress(of pillTypeID: UUID, on day: Day, in repository: (any PillTypeRepository)?) async throws -> PillTypeProgress? {
        guard let repository else { return nil }
        return try await DailyProgress(repository: repository)(day: day).first { $0.id == pillTypeID }
    }
}
