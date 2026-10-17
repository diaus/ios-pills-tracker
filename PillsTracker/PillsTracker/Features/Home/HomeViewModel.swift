import Data
import Domain
import FactoryKit
import Foundation
import Observation
import SwiftUI

/// Drives the Home screen: Active Prescription cards with today's progress, the Paused section
/// and the Pill Types link. Owns "today" and recomputes it when the view asks (scene active, clock change).
@MainActor @Observable
final class HomeViewModel {
    @ObservationIgnored @Injected(\.pillTypeRepository) private var repository
    @ObservationIgnored @Injected(\.dailyProgress) private var dailyProgress

    /// Every Pill Type ordered by creation date, oldest first.
    private(set) var pillTypes: [PillTypeAggregate] = []
    /// Today's progress for every Pill Type with a Prescription, ordered by creation date.
    private(set) var progress: [PillTypeProgress] = []
    private(set) var today = TodayTracker.today()
    private(set) var hasLoaded = false
    var errorMessage: LocalizedStringResource?

    var pillTypeCount: Int { pillTypes.count }

    /// True while the user has no Pill Types yet.
    var isEmpty: Bool { hasLoaded && pillTypes.isEmpty }

    var activePrescriptions: [PillTypeProgress] {
        progress.filter { $0.prescriptionState == .active }
    }

    var pausedPrescriptions: [PillTypeAggregate] {
        pillTypes.filter { $0.prescription?.state == .paused }
    }

    /// Pill Types exist but none has a Prescription yet.
    var hasNoPrescriptions: Bool {
        !pillTypes.isEmpty && pillTypes.allSatisfy { $0.prescription == nil }
    }

    func load() async {
        do {
            pillTypes = try await repository.fetchAll()
            progress = try await dailyProgress(day: today)
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

    /// Reloads after every write (including Consume and Undo on the Blister screen); runs until the owning view's task is cancelled.
    func observeChanges() async {
        for await _ in await repository.changes {
            await load()
        }
    }

    /// Resumes a Paused Prescription straight from the Paused section.
    func resumePrescription(pillTypeID: UUID) async {
        guard var aggregate = pillTypes.first(where: { $0.id == pillTypeID }) else { return }
        do {
            try aggregate.resumePrescription()
            try await repository.update(aggregate)
        } catch {
            errorMessage = error.userMessage
        }
    }
}
