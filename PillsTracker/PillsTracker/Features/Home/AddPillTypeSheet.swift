import Domain
import FactoryKit
import SwiftUI

/// Sheet for creating a Pill Type: name plus grid shape. Errors show inline under each field.
struct AddPillTypeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var model = Container.shared.addPillTypeViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("addPillType.name", text: $model.name)
                        .textInputAutocapitalization(.words)
                    fieldError(model.nameError)
                }

                Section {
                    Stepper(value: $model.rows, in: GridShape.allowedRange) {
                        LabeledContent("addPillType.rows", value: model.rows, format: .number)
                    }
                    fieldError(model.rowsError)
                    Stepper(value: $model.columns, in: GridShape.allowedRange) {
                        LabeledContent("addPillType.columns", value: model.columns, format: .number)
                    }
                    fieldError(model.columnsError)
                } header: {
                    Text("addPillType.shape")
                } footer: {
                    Text("addPillType.shape.footer")
                }
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

    @ViewBuilder
    private func fieldError(_ message: LocalizedStringKey?) -> some View {
        if let message {
            Text(message)
                .font(.footnote)
                .foregroundStyle(.red)
        }
    }
}

#Preview {
    AddPillTypeSheet()
}
