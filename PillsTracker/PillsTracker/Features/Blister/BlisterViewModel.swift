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
    private(set) var pillType: PillType?
    private(set) var currentBlister: Blister?
    /// Today's progress; nil while the Pill Type has no Prescription.
    private(set) var progress: PillTypeProgress?
    private(set) var today = TodayTracker.today()
    private(set) var hasLoaded = false
    var errorMessage: LocalizedStringResource?

    init(pillTypeID: UUID) {
        self.pillTypeID = pillTypeID
    }

    var presentCount: Int { currentBlister?.presentPositions.count ?? 0 }

    /// Start New Blister is offered only once every Position is Empty.
    var canStartNewBlister: Bool { currentBlister?.isEmpty ?? false }

    /// Slots a Present pill can be consumed for right now: today's Open Slots of an Active Prescription.
    var openSlots: [Slot] {
        guard let progress, progress.prescriptionState == .active else { return [] }
        return progress.openSlots
    }

    /// Chips are shown once the Pill Type has a Prescription.
    var showsSlotChips: Bool { progress != nil }

    func chipState(for slot: Slot) -> SlotChipState {
        progress?.chipState(for: slot) ?? .notPrescribed
    }

    /// The Intake behind a Done chip that may be undone: made today, from the Current Blister.
    func undoableIntake(for slot: Slot) -> Intake? {
        guard let intake = progress?.intake(for: slot),
              intake.day == today,
              intake.blisterID == currentBlister?.id else { return nil }
        return intake
    }

    func load() async {
        do {
            let aggregate = try await repository.fetch(id: pillTypeID)
            pillType = aggregate?.pillType
            currentBlister = aggregate?.currentBlister
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
