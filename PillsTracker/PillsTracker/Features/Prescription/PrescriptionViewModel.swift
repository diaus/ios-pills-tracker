import Domain
import FactoryKit
import Foundation
import Observation
import SwiftUI

/// Creates, edits, pauses, resumes or deletes the Prescription of one Pill Type.
/// Rules live in Domain (`PillTypeAggregate`); this only drives the form and persists.
@MainActor @Observable
final class PrescriptionViewModel {
    @ObservationIgnored @Injected(\.updatePillType) private var updatePillType

    /// The Pill Type as last stored by this sheet.
    private(set) var aggregate: PillTypeAggregate
    var selectedSlots: Set<Slot>
    var selectedDays: PrescriptionDaysSelection
    /// The rule the change broke, shown under the Slots.
    private(set) var validationError: DomainError?
    var errorMessage: LocalizedStringResource?
    private(set) var isSaving = false

    /// A new Prescription starts on `today` unless the user picks another Day.
    init(aggregate: PillTypeAggregate, today: Day) {
        self.aggregate = aggregate
        selectedSlots = aggregate.prescription?.slots ?? []
        selectedDays = PrescriptionDaysSelection(
            startDay: aggregate.prescription?.startDay ?? today,
            endDay: aggregate.prescription?.endDay
        )
    }

    var prescription: Prescription? { aggregate.prescription }
    var hasPrescription: Bool { prescription != nil }
    var isPaused: Bool { prescription?.state == .paused }

    /// Creates the Prescription or replaces its Slots, Start Day and End Day. Returns true on success so the sheet can dismiss.
    func save() async -> Bool {
        let slots = selectedSlots
        let startDay = selectedDays.startDay, endDay = selectedDays.endDay
        return await update { aggregate throws(DomainError) in
            try aggregate.setPrescription(slots: slots, startDay: startDay, endDay: endDay)
        }
    }

    func pause() async -> Bool {
        await update { aggregate throws(DomainError) in try aggregate.pausePrescription() }
    }

    func resume() async -> Bool {
        await update { aggregate throws(DomainError) in try aggregate.resumePrescription() }
    }

    /// Removes the Prescription; the Pill Type and its Blisters stay.
    func delete() async -> Bool {
        await update { aggregate throws(DomainError) in aggregate.removePrescription() }
    }

    private func update(_ change: @escaping @Sendable (inout PillTypeAggregate) throws(DomainError) -> Void) async -> Bool {
        validationError = nil
        isSaving = true
        defer { isSaving = false }
        do {
            aggregate = try await updatePillType(pillTypeID: aggregate.id, change)
            return true
        } catch let error as DomainError {
            validationError = error
            return false
        } catch {
            errorMessage = error.userMessage
            return false
        }
    }
}
