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

    var form = PillTypeForm()
    /// Slots of the Prescription to create with the Pill Type; none means no Prescription.
    var selectedSlots: Set<Slot> = []
    /// Start Day and End Day of that Prescription; it starts today unless the user picks another Day.
    var selectedDays: PrescriptionDaysSelection
    let submission = FormSubmission()

    init(today: Day) {
        selectedDays = PrescriptionDaysSelection(startDay: today, endDay: nil)
    }

    /// Validates, persists and returns true on success so the sheet can dismiss.
    func save() async -> Bool {
        await submission.run {
            var aggregate = try form.makeAggregate(createdAt: Date())
            if !selectedSlots.isEmpty {
                try aggregate.setPrescription(slots: selectedSlots, startDay: selectedDays.startDay, endDay: selectedDays.endDay)
            }
            try await repository.create(aggregate)
        }
    }
}
