import Data
import Domain
import FactoryKit
import Foundation
import Observation
import SwiftUI

/// Form state for creating a Pill Type. Validation comes from Domain; this only maps errors to fields.
@MainActor @Observable
final class AddPillTypeViewModel {
    @ObservationIgnored @Injected(\.pillTypeRepository) private var repository

    var name = ""
    var rows = 2
    var columns = 5
    /// Slots of the Prescription to create with the Pill Type; none means no Prescription.
    var selectedSlots: Set<Slot> = []
    /// Start Day and End Day of that Prescription; it starts today unless the user picks another Day.
    var selectedDays: PrescriptionDaysSelection

    /// The rule the form broke; `PillTypeFormFields` shows it under its field.
    private(set) var validationError: DomainError?
    var errorMessage: LocalizedStringResource?
    private(set) var isSaving = false

    init(today: Day) {
        selectedDays = PrescriptionDaysSelection(startDay: today, endDay: nil)
    }

    /// Validates, persists and returns true on success so the sheet can dismiss.
    func save() async -> Bool {
        validationError = nil
        var aggregate: PillTypeAggregate
        do {
            aggregate = try PillTypeAggregate.new(name: name, rows: rows, columns: columns, createdAt: Date())
            if !selectedSlots.isEmpty {
                try aggregate.setPrescription(slots: selectedSlots, startDay: selectedDays.startDay, endDay: selectedDays.endDay)
            }
        } catch {
            validationError = error
            return false
        }

        isSaving = true
        defer { isSaving = false }
        do {
            try await repository.create(aggregate)
            return true
        } catch {
            errorMessage = error.userMessage
            return false
        }
    }
}
