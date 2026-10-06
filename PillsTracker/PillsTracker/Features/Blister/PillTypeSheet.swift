import Domain
import FactoryKit
import SwiftUI

/// Sheet opened from the Blister toolbar. Renames the Pill Type, changes its grid shape while the
/// Current Blister is empty, or deletes it (with confirmation).
struct PillTypeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var model: PillTypeViewModel
    @State private var isConfirmingDelete = false
    /// Called after the Pill Type was deleted so the presenting screen can leave it.
    private let onDeleted: @MainActor () -> Void

    init(pillTypeID: UUID, onDeleted: @escaping @MainActor () -> Void) {
        _model = State(initialValue: Container.shared.pillTypeViewModel(pillTypeID))
        self.onDeleted = onDeleted
    }

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
                    Stepper(value: $model.columns, in: GridShape.allowedRange) {
                        LabeledContent("addPillType.columns", value: model.columns, format: .number)
                    }
                    fieldError(model.shapeError)
                } header: {
                    Text("addPillType.shape")
                } footer: {
                    Text(model.isShapeLocked ? "pillType.shape.locked" : "pillType.shape.footer")
                }
                .disabled(model.isShapeLocked)

                Section {
                    Button("pillType.delete", role: .destructive) {
                        isConfirmingDelete = true
                    }
                }
            }
            .disabled(model.isSaving)
            .navigationTitle("pillType.title")
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
                    .disabled(!model.hasLoaded)
                }
            }
            .confirmationDialog("pillType.delete.confirm.title", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
                Button("pillType.delete.confirm", role: .destructive) {
                    Task {
                        if await model.delete() {
                            dismiss()
                            onDeleted()
                        }
                    }
                }
                Button("common.cancel", role: .cancel) {}
            } message: {
                Text("pillType.delete.confirm.message")
            }
            .errorAlert(message: $model.errorMessage)
            .task { await model.load() }
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
