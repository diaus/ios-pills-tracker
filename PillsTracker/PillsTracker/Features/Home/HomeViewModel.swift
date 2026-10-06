import Data
import Domain
import FactoryKit
import Foundation
import Observation

/// Drives the Home screen: Active Prescription cards, the Paused section and the Pill Types link.
/// Later tickets add Daily Progress (Done Slots) here.
@MainActor @Observable
final class HomeViewModel {
    @ObservationIgnored @Injected(\.pillTypeRepository) private var repository

    /// Every Pill Type ordered by creation date, oldest first.
    private(set) var pillTypes: [PillTypeAggregate] = []
    private(set) var hasLoaded = false
    var errorMessage: String?

    var pillTypeCount: Int { pillTypes.count }

    /// True while the user has no Pill Types yet.
    var isEmpty: Bool { hasLoaded && pillTypes.isEmpty }

    var activePrescriptions: [PillTypeAggregate] {
        pillTypes.filter { $0.prescription?.state == .active }
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
        } catch {
            errorMessage = error.localizedDescription
        }
        hasLoaded = true
    }

    /// Reloads after every write; runs until the owning view's task is cancelled.
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
            errorMessage = error.localizedDescription
        }
    }
}
