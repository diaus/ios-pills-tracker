import Data
import Domain
import FactoryKit
import Foundation
import Observation
import SwiftUI
import Utils

/// Today's progress of every Pill Type, loaded once for the whole app and kept current: it reloads
/// after every write and when Today changes. The one holder of Today in the app (ADR 0001, 0004):
/// it reads `Day.current`, and screens read the Day from here and pass it to the use cases. Home and
/// the Pill Types list show views of it; Blister observes its Selected Day's progress through here,
/// kept current the same way.
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
    private(set) var today = Day.current
    /// Set by `preview`: `state` is fixed and `observeProgress(on:)` serves it instead of loading.
    private var isFixed = false

    /// The loaded progress, or nil while loading or after a failure.
    var progress: [PillTypeProgress]? {
        if case .loaded(let progress) = state { progress } else { nil }
    }

    /// Loads today's progress into `state`, then reloads it after every write and refreshes Today at
    /// every rollover, until the calling task is cancelled.
    func run() async {
        async let rollovers: Void = refreshingTodayAtRollovers()
        await reloadingAfterWrites { await self.loadToday() }
        await rollovers
    }

    /// Loads `day`'s progress and hands it to `deliver`, then again after every write until the calling
    /// task is cancelled. A failed load is delivered as such and the next write retries.
    func observeProgress(
        on day: Day,
        _ deliver: @MainActor (Result<[PillTypeProgress], any Error>) -> Void
    ) async {
        if isFixed {
            deliver(.success(progress ?? []))
            return
        }
        await reloadingAfterWrites {
            let result = await Result { try await self.dailyProgress(day: day) }
            // A load the caller stopped waiting for mid-flight would otherwise land on its next Day.
            guard !Task.isCancelled else { return }
            deliver(result)
        }
    }

    /// Re-evaluates Today and reloads when the Day rolled over or the last load failed.
    func refreshToday() async {
        let current = Day.current
        let hasFailed = if case .failed = state { true } else { false }
        guard current != today || hasFailed else { return }
        today = current
        await loadToday()
    }

    /// Runs `reload` once, then again after every write until the calling task is cancelled.
    private func reloadingAfterWrites(_ reload: () async -> Void) async {
        // Subscribed before the first load, so a write during it still triggers a reload.
        let changes = notifier.changes
        await reload()
        for await _ in changes {
            await reload()
        }
    }

    /// Refreshes Today at each next 03:00 while the app stays open, until the calling task is cancelled.
    /// The significant-time-change notification fires at midnight, not at the rollover (ADR 0004).
    private func refreshingTodayAtRollovers() async {
        let rollover = DateComponents(hour: Day.rolloverHour, minute: 0, second: 0)
        // Recomputed after every wake-up: one that a clock or time zone change put before 03:00 waits again.
        while let next = Calendar.current.nextDate(after: .now, matching: rollover, matchingPolicy: .nextTime) {
            do {
                try await Task.sleep(for: .seconds(next.timeIntervalSinceNow))
            } catch {
                return
            }
            await refreshToday()
        }
    }

    private func loadToday() async {
        do {
            state = .loaded(try await dailyProgress(day: today))
        } catch {
            state = .failed(error.userMessage)
        }
    }
}

extension DailyProgressModel {
    /// A model already in `state`, for previews; it never loads.
    static func preview(_ state: State) -> DailyProgressModel {
        let model = DailyProgressModel()
        model.state = state
        model.isFixed = true
        return model
    }
}
