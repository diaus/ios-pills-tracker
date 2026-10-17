import Data
import Domain
import FactoryKit
import Foundation
import Observation
import SwiftUI
import Utils

/// Today's progress of every Pill Type, loaded once for the whole app and kept current: it reloads
/// after every write and when "today" changes. The one owner of "today" (ADR 0001): screens read the
/// Day from here and pass it to the use cases. Home, Blister and the Pill Types list show views of it.
@MainActor @Observable
final class DailyProgressModel {
    enum State {
        case loading
        /// Every Pill Type's progress, ordered by creation date, oldest first.
        case loaded([PillTypeProgress])
        /// The last load failed; screens show the message instead of an empty or not-found state.
        case failed(LocalizedStringResource)
    }

    @ObservationIgnored @Injected(\.dailyProgress) private var dailyProgress
    @ObservationIgnored @Injected(\.dataChangeNotifier) private var notifier

    private(set) var state = State.loading
    private(set) var today = DailyProgressModel.currentDay()

    /// The loaded progress, or nil while loading or after a failure.
    var progress: [PillTypeProgress]? {
        if case .loaded(let progress) = state { progress } else { nil }
    }

    /// Loads, then reloads after every write until the calling task is cancelled.
    func run() async {
        // Subscribed before the first load, so a write during it still triggers a reload.
        let changes = notifier.changes
        await load()
        for await _ in changes {
            await load()
        }
    }

    /// Re-evaluates "today" and reloads when the Day rolled over or the last load failed.
    func refreshToday() async {
        let current = Self.currentDay()
        let hasFailed = if case .failed = state { true } else { false }
        guard current != today || hasFailed else { return }
        today = current
        await load()
    }

    private func load() async {
        do {
            state = .loaded(try await dailyProgress(day: today))
        } catch {
            state = .failed(error.userMessage)
        }
    }

    private static func currentDay() -> Day {
        Day(date: .now, calendar: .current)
    }
}
