import Domain
import FactoryKit
import Foundation
import Observation
import SwiftUI

/// Shows one Pill Type's Current Blister with the Selected Day's Slot chips, and lets the user Consume
/// for that Day, Undo and keep the grid in sync with reality. The Selected Day's progress is streamed
/// from the app's Daily Progress, which reloads it after each write.
@MainActor @Observable
final class BlisterViewModel {
    @ObservationIgnored @Injected(\.syncPosition) private var syncPosition
    @ObservationIgnored @Injected(\.startNewBlister) private var startNewBlister
    @ObservationIgnored @Injected(\.consume) private var consume
    @ObservationIgnored @Injected(\.undo) private var undo

    let pillTypeID: UUID
    let dailyProgress: DailyProgressModel
    var errorMessage: LocalizedStringResource?
    /// The Day the screen shows and Consumes for: today when the screen opens, never after today.
    private(set) var selectedDay: Day
    /// The read model of the Pill Type on the Selected Day; nil until that Day's first load or when
    /// the Pill Type no longer exists. Starts as today's, which the app has already loaded.
    private(set) var progress: PillTypeProgress?

    init(pillTypeID: UUID, dailyProgress: DailyProgressModel) {
        self.pillTypeID = pillTypeID
        self.dailyProgress = dailyProgress
        selectedDay = dailyProgress.today
        progress = dailyProgress.progress?.first { $0.id == pillTypeID }
    }

    var isOnToday: Bool { selectedDay == dailyProgress.today }

    /// The future can't be consumed for, so today is as far forward as the Selected Day goes.
    var canMoveForward: Bool { selectedDay < dailyProgress.today }

    /// The Pill Type as of today's load, whatever the Selected Day; nil while loading or once it no longer exists.
    var aggregate: PillTypeAggregate? {
        dailyProgress.progress?.first { $0.id == pillTypeID }?.aggregate
    }

    /// How `day` reads next to today: "today", "yesterday", a weekday or "Jul 21".
    func name(of day: Day) -> String {
        day.relativeName(today: dailyProgress.today)
    }

    func moveBack() {
        select(selectedDay.adding(days: -1))
    }

    func moveForward() {
        guard canMoveForward else { return }
        select(selectedDay.adding(days: 1))
    }

    /// At a Day rollover a Selected Day that was today becomes the new today; a past one stays.
    func todayChanged(from old: Day, to new: Day) {
        if selectedDay == old || selectedDay > new {
            select(new)
        }
    }

    /// Loads the Selected Day's progress, then reloads it after every write until the calling task is cancelled.
    func run() async {
        for await result in dailyProgress.progress(on: selectedDay) {
            switch result {
            case .success(let progress):
                self.progress = progress.first { $0.id == pillTypeID }
            case .failure(let error):
                errorMessage = error.userMessage
            }
        }
    }

    /// Consume: takes the pill at `position` for one of the Selected Day's Open Slots.
    func consume(_ position: Position, slot: Slot) async {
        guard let day = progress?.day else { return }
        await perform { try await consume(pillTypeID: pillTypeID, position: position, slot: slot, day: day, instant: .now) }
    }

    /// Undo: reverts an Intake from the Current Blister, made on any Day.
    func undo(_ intake: Intake) async {
        await perform { try await undo(intakeID: intake.id) }
    }

    /// Sync Edit: sets `position` Present or Empty on the Current Blister.
    func setPosition(_ position: Position, isPresent: Bool) async {
        await perform { try await syncPosition(pillTypeID: pillTypeID, position: position, isPresent: isPresent) }
    }

    func startNewBlister() async {
        await perform { try await startNewBlister(pillTypeID: pillTypeID) }
    }

    /// Moves the Selected Day; its progress is gone until `run` loads the new Day's.
    private func select(_ day: Day) {
        selectedDay = day
        progress = nil
    }

    private func perform(_ action: () async throws -> Void) async {
        do {
            try await action()
        } catch {
            errorMessage = error.userMessage
        }
    }
}
