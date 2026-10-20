import Domain
import FactoryKit
import Foundation
import Observation
import SwiftUI

/// Shows one Pill Type's Current Blister with the Selected Day's Slot chips, and lets the user Consume
/// for that Day, Undo and keep the grid in sync with reality. Both today's and a past Selected Day's
/// progress come from the app's Daily Progress, which reloads them after each write.
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
    /// The last load of a past Selected Day; its `day` tells whether it is still the Selected Day's.
    private var pastDay: (day: Day, state: DailyProgressModel.State)?

    init(pillTypeID: UUID, dailyProgress: DailyProgressModel) {
        self.pillTypeID = pillTypeID
        self.dailyProgress = dailyProgress
        selectedDay = dailyProgress.today
    }

    var isOnToday: Bool { selectedDay == dailyProgress.today }

    /// The future can't be consumed for, so today is as far forward as the Selected Day goes.
    var canMoveForward: Bool { selectedDay < dailyProgress.today }

    /// The Pill Type as of today's load, whatever the Selected Day; nil while loading or once it no longer exists.
    var aggregate: PillTypeAggregate? {
        dailyProgress.progress?.first { $0.id == pillTypeID }?.aggregate
    }

    /// Loading, loaded or failed for the Selected Day: Daily Progress's state today, its stream for a past Day.
    var state: DailyProgressModel.State {
        guard !isOnToday else { return dailyProgress.state }
        guard let pastDay, pastDay.day == selectedDay else { return .loading }
        return pastDay.state
    }

    /// The read model of the Pill Type on the Selected Day; nil until loaded or when the Pill Type no longer exists.
    var progress: PillTypeProgress? {
        guard case .loaded(let progress) = state else { return nil }
        return progress.first { $0.id == pillTypeID }
    }

    /// How `day` reads next to today: "today", "yesterday", a weekday or "Jul 21".
    func name(of day: Day) -> String {
        day.relativeName(today: dailyProgress.today)
    }

    func moveBack() {
        selectedDay = selectedDay.adding(days: -1)
    }

    func moveForward() {
        guard canMoveForward else { return }
        selectedDay = selectedDay.adding(days: 1)
    }

    /// At a Day rollover a Selected Day that was today becomes the new today; a past one stays.
    func todayChanged(from old: Day, to new: Day) {
        if selectedDay == old || selectedDay > new {
            selectedDay = new
        }
    }

    /// Keeps a past Selected Day's progress current until the calling task is cancelled. Today's
    /// progress is already kept current by Daily Progress, so it returns at once.
    func run() async {
        guard !isOnToday else { return }
        let day = selectedDay
        for await state in dailyProgress.progress(on: day) {
            pastDay = (day, state)
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

    private func perform(_ action: () async throws -> Void) async {
        do {
            try await action()
        } catch {
            errorMessage = error.userMessage
        }
    }
}
