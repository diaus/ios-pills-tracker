import FactoryKit
import SwiftUI

/// Sheet for creating a Pill Type: name plus grid shape. Errors show inline under each field.
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
                    nameError: model.nameError,
                    rowsError: model.rowsError,
                    columnsError: model.columnsError,
                    shapeFooter: .addPillTypeShapeFooter
                )
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
