import Domain
import FactoryKit
import Foundation
import Observation
import SwiftUI

/// Shows one Pill Type's Current Blister with today's Slot chips, and lets the user Consume, Undo
/// and keep the grid in sync with reality. Reads the Pill Type and "today" from the app's Daily Progress,
/// which reloads after each write.
@MainActor @Observable
final class BlisterViewModel {
    @ObservationIgnored @Injected(\.syncPosition) private var syncPosition
    @ObservationIgnored @Injected(\.startNewBlister) private var startNewBlister
    @ObservationIgnored @Injected(\.consume) private var consume
    @ObservationIgnored @Injected(\.undo) private var undo

    let pillTypeID: UUID
    let dailyProgress: DailyProgressModel
    var errorMessage: LocalizedStringResource?

    init(pillTypeID: UUID, dailyProgress: DailyProgressModel) {
        self.pillTypeID = pillTypeID
        self.dailyProgress = dailyProgress
    }

    /// Today's read model of the Pill Type; nil until loaded or when the Pill Type no longer exists.
    var progress: PillTypeProgress? {
        dailyProgress.progress?.first { $0.id == pillTypeID }
    }

    /// Consume: takes the pill at `position` for one of today's Open Slots.
    func consume(_ position: Position, slot: Slot) async {
        let day = dailyProgress.today
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
