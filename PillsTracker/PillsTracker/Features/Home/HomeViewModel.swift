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

    /// Today's read model of every Pill Type, ordered by creation date, oldest first.
    private(set) var progress: [PillTypeProgress] = []
    private(set) var today = TodayTracker.today()
    private(set) var hasLoaded = false
    var errorMessage: LocalizedStringResource?

    var pillTypeCount: Int { progress.count }

    /// True while the user has no Pill Types yet.
    var isEmpty: Bool { hasLoaded && progress.isEmpty }

    var activePrescriptions: [PillTypeProgress] {
        progress.filter { $0.prescriptionState == .active }
    }

    var pausedPrescriptions: [PillTypeProgress] {
        progress.filter { $0.prescriptionState == .paused }
    }

    /// Pill Types exist but none has a Prescription yet.
    var hasNoPrescriptions: Bool {
        !progress.isEmpty && progress.allSatisfy { !$0.hasPrescription }
    }

    func load() async {
        do {
            progress = try await dailyProgress(day: today)
            // Only a successful load may show the empty or not-found state; a failed one keeps loading.
            hasLoaded = true
        } catch {
            errorMessage = error.userMessage
        }
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
        guard var aggregate = progress.first(where: { $0.id == pillTypeID })?.aggregate else { return }
        do {
            try aggregate.resumePrescription()
            try await repository.update(aggregate)
        } catch {
            errorMessage = error.userMessage
        }
    }
}
