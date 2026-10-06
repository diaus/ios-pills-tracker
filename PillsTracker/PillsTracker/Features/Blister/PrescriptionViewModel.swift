import Data
import Domain
import FactoryKit
import Foundation
import Observation
import SwiftUI

/// Creates, edits, pauses, resumes or deletes the Prescription of one Pill Type.
/// Rules live in Domain (`PillTypeAggregate`); this only drives the form and persists.
@MainActor @Observable
final class PrescriptionViewModel {
    @ObservationIgnored @Injected(\.pillTypeRepository) private var repository

    let pillTypeID: UUID
    private(set) var aggregate: PillTypeAggregate?
    private(set) var hasLoaded = false
    var selectedSlots: Set<Slot> = []
    private(set) var slotsError: LocalizedStringKey?
    var errorMessage: String?
    private(set) var isSaving = false

    init(pillTypeID: UUID) {
        self.pillTypeID = pillTypeID
    }

    var prescription: Prescription? { aggregate?.prescription }
    var hasPrescription: Bool { prescription != nil }
    var isPaused: Bool { prescription?.state == .paused }

    func load() async {
        do {
            aggregate = try await repository.fetch(id: pillTypeID)
            selectedSlots = aggregate?.prescription?.slots ?? []
        } catch {
            errorMessage = error.localizedDescription
        }
        hasLoaded = true
    }

    func isSelected(_ slot: Slot) -> Bool {
        selectedSlots.contains(slot)
    }

    func setSelected(_ slot: Slot, _ isSelected: Bool) {
        if isSelected { selectedSlots.insert(slot) } else { selectedSlots.remove(slot) }
    }

    /// Creates the Prescription or replaces its Slots. Returns true on success so the sheet can dismiss.
    func save() async -> Bool {
        slotsError = nil
        let slots = selectedSlots
        return await mutate { aggregate throws(DomainError) in try aggregate.setPrescriptionSlots(slots) }
    }

    func pause() async -> Bool {
        await mutate { aggregate throws(DomainError) in try aggregate.pausePrescription() }
    }

    func resume() async -> Bool {
        await mutate { aggregate throws(DomainError) in try aggregate.resumePrescription() }
    }

    /// Removes the Prescription; the Pill Type and its Blisters stay.
    func delete() async -> Bool {
        await mutate { aggregate throws(DomainError) in aggregate.removePrescription() }
    }

    private func mutate(_ change: (inout PillTypeAggregate) throws(DomainError) -> Void) async -> Bool {
        guard var updated = aggregate else { return false }
        do {
            try change(&updated)
        } catch {
            show(error)
            return false
        }

        isSaving = true
        defer { isSaving = false }
        do {
            try await repository.update(updated)
            aggregate = updated
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private func show(_ error: DomainError) {
        switch error {
        case .emptySlots: slotsError = error.message
        default: errorMessage = String(localized: "common.error")
        }
    }
}
