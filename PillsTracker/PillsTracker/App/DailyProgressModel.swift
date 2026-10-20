import Data
import Domain
import FactoryKit
import Foundation
import Observation
import SwiftUI
import Utils

/// Today's progress of every Pill Type, loaded once for the whole app and kept current: it reloads
/// after every write and when "today" changes. The one owner of "today" (ADR 0001): screens read the
/// Day from here and pass it to the use cases. Home and the Pill Types list show views of it; Blister
/// streams its Selected Day's progress from here, kept current the same way.
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
    /// Set by `preview`: `state` is fixed and `progress(on:)` serves it instead of loading.
    private var isFixed = false

    /// The loaded progress, or nil while loading or after a failure.
    var progress: [PillTypeProgress]? {
        if case .loaded(let progress) = state { progress } else { nil }
    }

    /// Loads, then reloads after every write until the calling task is cancelled.
    func run() async {
        await reloadingAfterWrites { await self.load() }
    }

    /// Progress on `day`, for a screen showing one Day: loaded at once, then reloaded after every
    /// write until the caller stops iterating. A failed load is reported and the next write retries.
    func progress(on day: Day) -> AsyncStream<Result<[PillTypeProgress], any Error>> {
        AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            if isFixed {
                continuation.yield(.success(progress ?? []))
                continuation.finish()
                return
            }
            let task = Task {
                await reloadingAfterWrites {
                    continuation.yield(await Result { try await self.load(on: day) })
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
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

    /// Runs `load`, then again after every write until the calling task is cancelled.
    private func reloadingAfterWrites(_ load: () async -> Void) async {
        // Subscribed before the first load, so a write during it still triggers a reload.
        let changes = notifier.changes
        await load()
        for await _ in changes {
            await load()
        }
    }

    private func load() async {
        do {
            state = .loaded(try await load(on: today))
        } catch {
            state = .failed(error.userMessage)
        }
    }

    private func load(on day: Day) async throws -> [PillTypeProgress] {
        try await dailyProgress(day: day)
    }

    private static func currentDay() -> Day {
        Day(date: .now, calendar: .current)
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
