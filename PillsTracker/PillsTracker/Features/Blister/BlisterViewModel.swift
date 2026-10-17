import Data
import Domain
import FactoryKit
import Foundation
import Observation
import SwiftUI

/// Shows one Pill Type's Current Blister with today's Slot chips, and lets the user Consume, Undo
/// and keep the grid in sync with reality. Owns "today" (ADR 0001).
@MainActor @Observable
final class BlisterViewModel {
    @ObservationIgnored @Injected(\.pillTypeRepository) private var repository
    @ObservationIgnored @Injected(\.syncPosition) private var syncPosition
    @ObservationIgnored @Injected(\.startNewBlister) private var startNewBlister
    @ObservationIgnored @Injected(\.consume) private var consume
    @ObservationIgnored @Injected(\.undo) private var undo
    @ObservationIgnored @Injected(\.dailyProgress) private var dailyProgress

    let pillTypeID: UUID
    /// Today's read model of the Pill Type; nil until loaded or when the Pill Type no longer exists.
    private(set) var progress: PillTypeProgress?
    private(set) var today = TodayTracker.today()
    private(set) var hasLoaded = false
    var errorMessage: LocalizedStringResource?

    init(pillTypeID: UUID) {
        self.pillTypeID = pillTypeID
    }

    func load() async {
        do {
            progress = try await dailyProgress(pillTypeID: pillTypeID, day: today)
        } catch {
            errorMessage = error.userMessage
        }
        hasLoaded = true
    }

    /// Re-evaluates "today" and reloads when the Day rolled over.
    func refreshToday() async {
        let current = TodayTracker.today()
        guard current != today else { return }
        today = current
        await load()
    }

    func observeChanges() async {
        for await _ in await repository.changes {
            await load()
        }
    }

    /// Consume: takes the pill at `position` for one of today's Open Slots.
    func consume(_ position: Position, slot: Slot) async {
        await perform { try await consume(pillTypeID: pillTypeID, position: position, slot: slot, day: today, instant: .now) }
    }

    /// Undo: reverts today's Intake for `slot` from the Current Blister.
    func undo(_ intake: Intake) async {
        await perform { try await undo(intakeID: intake.id, day: today) }
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
            await load()
        } catch {
            errorMessage = error.userMessage
        }
    }
}
