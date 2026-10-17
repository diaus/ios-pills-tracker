import FactoryKit
import SwiftUI

/// Sheet for creating a Pill Type: name, grid shape and optional Prescription Slots. Errors show inline under each field.
struct AddPillTypeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var model = Container.shared.addPillTypeViewModel()

    var body: some View {
        NavigationStack {
            Form {
                PillTypeFormFields(
                    name: $model.name,
                    rows: $model.rows,
                    columns: $model.columns,
                    error: model.validationError,
                    shapeFooter: .addPillTypeShapeFooter
                )

                Section {
                    SlotToggles(selection: $model.selectedSlots)
                } header: {
                    Text(.addPillTypePrescription)
                } footer: {
                    Text(.addPillTypePrescriptionFooter)
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
                    .disabled(model.isSaving)
                }
            }
            .errorAlert(message: $model.errorMessage)
        }
    }
}

#Preview {
    AddPillTypeSheet()
}
