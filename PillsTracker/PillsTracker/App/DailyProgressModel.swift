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

        var isLoading: Bool {
            if case .loading = self { true } else { false }
        }

        var isFailed: Bool {
            if case .failed = self { true } else { false }
        }
    }

    @ObservationIgnored @Injected(\.dailyProgress) private var dailyProgress
    @ObservationIgnored @Injected(\.dataChangeNotifier) private var notifier

    private(set) var state = State.loading
    private(set) var today = Day.current
    /// The wait for the next 03:00, which `refreshToday()` restarts.
    @ObservationIgnored private var rolloverWait: Task<Void, any Error>?

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
        await reloadingAfterWrites {
            let result = await Result { try await self.dailyProgress(day: day) }
            // A load the caller stopped waiting for mid-flight would otherwise land on its next Day.
            guard !Task.isCancelled else { return }
            deliver(result)
        }
    }

    /// Re-evaluates Today and reloads when the Day rolled over or the last load failed. Also restarts the
    /// wait for the next 03:00: a time zone or clock change moves it, and the wait would keep the old instant.
    func refreshToday() async {
        rolloverWait?.cancel()
        let current = Day.current
        guard current != today || state.isFailed else { return }
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
        // Recomputed after every wake-up and every restart: one that a clock or time zone change put before
        // 03:00 waits again.
        while let next = Day.nextRollover(after: .now, calendar: .current) {
            let wait = Task { try await Task.sleep(for: .seconds(next.timeIntervalSinceNow)) }
            rolloverWait = wait
            do {
                try await withTaskCancellationHandler { try await wait.value } onCancel: { wait.cancel() }
            } catch {
                // Cancelled with the calling task: stop. Restarted by `refreshToday()`: wait for the new 03:00.
                if Task.isCancelled { return }
                continue
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
