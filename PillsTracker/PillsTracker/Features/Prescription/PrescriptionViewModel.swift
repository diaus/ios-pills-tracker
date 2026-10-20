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
    /// The Start Day as the picker holds it. Moving it past the End Day moves the End Day along.
    var startDayDate: Date {
        didSet { if endDayDate < startDayDate { endDayDate = startDayDate } }
    }
    /// Whether the Prescription has an End Day; off means open-ended.
    var hasEndDay: Bool
    /// The End Day as the picker holds it, kept while `hasEndDay` is off so turning it back on restores it.
    var endDayDate: Date
    /// The rule the change broke, shown under the Slots.
    private(set) var validationError: DomainError?
    var errorMessage: LocalizedStringResource?
    private(set) var isSaving = false

    /// A new Prescription starts on `today` unless the user picks another Day.
    init(aggregate: PillTypeAggregate, today: Day) {
        self.aggregate = aggregate
        selectedSlots = aggregate.prescription?.slots ?? []
        let startDayDate = (aggregate.prescription?.startDay ?? today).date()
        self.startDayDate = startDayDate
        hasEndDay = aggregate.prescription?.endDay != nil
        endDayDate = aggregate.prescription?.endDay?.date() ?? startDayDate
    }

    var prescription: Prescription? { aggregate.prescription }
    var hasPrescription: Bool { prescription != nil }
    var isPaused: Bool { prescription?.state == .paused }

    /// Creates the Prescription or replaces its Slots, Start Day and End Day. Returns true on success so the sheet can dismiss.
    func save() async -> Bool {
        let slots = selectedSlots
        let startDay = Day(date: startDayDate)
        let endDay = hasEndDay ? Day(date: endDayDate) : nil
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
