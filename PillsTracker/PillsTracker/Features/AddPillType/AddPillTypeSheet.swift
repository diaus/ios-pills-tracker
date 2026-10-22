import Domain
import SwiftUI

/// Sheet for creating a Pill Type: name, optional Abbreviation, grid shape and an optional Prescription's
/// Slots, with its Start Day and End Day once a Slot is chosen. Errors show inline under each field.
struct AddPillTypeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var model: AddPillTypeViewModel

    init(today: Day) {
        _model = State(initialValue: AddPillTypeViewModel(today: today))
    }

    var body: some View {
        NavigationStack {
            Form {
                PillTypeFormFields(
                    form: $model.form,
                    error: model.submission.validationError,
                    shapeFooter: .addPillTypeShapeFooter
                )

                Section {
                    SlotToggles(selection: $model.selectedSlots)
                } header: {
                    Text(.addPillTypePrescription)
                } footer: {
                    Text(.addPillTypePrescriptionFooter)
                }

                if !model.selectedSlots.isEmpty {
                    PrescriptionDaysSection(selection: $model.selectedDays)
                }
            }
            .navigationTitle(.addPillTypeTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(.commonCancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(.commonSave) {
                        Task {
                            if await model.save() { dismiss() }
                        }
                    }
                    .disabled(model.submission.isSaving)
                }
            }
            .errorAlert(message: Bindable(model.submission).errorMessage)
        }
    }
}

#Preview {
    AddPillTypeSheet(today: Day.current)
}
