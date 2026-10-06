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
                    shapeFooter: "addPillType.shape.footer"
                )
            }
            .navigationTitle("addPillType.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.save") {
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
