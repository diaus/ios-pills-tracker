import SwiftUI

/// Sheet opened from the Blister toolbar. Renames the Pill Type, changes its grid shape while the
/// Current Blister is empty, or deletes it (with confirmation).
struct EditPillTypeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var model: EditPillTypeViewModel
    @State private var isConfirmingDelete = false
    /// Called after the Pill Type was deleted so the presenting screen can leave it.
    private let onDeleted: @MainActor () -> Void

    init(pillTypeID: UUID, onDeleted: @escaping @MainActor () -> Void) {
        _model = State(initialValue: EditPillTypeViewModel(pillTypeID: pillTypeID))
        self.onDeleted = onDeleted
    }

    var body: some View {
        NavigationStack {
            Form {
                PillTypeFormFields(
                    name: $model.name,
                    rows: $model.rows,
                    columns: $model.columns,
                    error: model.validationError,
                    shapeFooter: model.isShapeLocked ? .pillTypeShapeLocked : .pillTypeShapeFooter,
                    isShapeLocked: model.isShapeLocked
                )

                Section {
                    Button(.pillTypeDelete, role: .destructive) {
                        isConfirmingDelete = true
                    }
                }
            }
            .disabled(model.isSaving)
            .navigationTitle(.pillTypeTitle)
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
                    .disabled(!model.hasLoaded)
                }
            }
            .confirmationDialog(.pillTypeDeleteConfirmTitle, isPresented: $isConfirmingDelete, titleVisibility: .visible) {
                Button(.pillTypeDeleteConfirm, role: .destructive) {
                    Task {
                        if await model.delete() {
                            dismiss()
                            onDeleted()
                        }
                    }
                }
                Button(.commonCancel, role: .cancel) {}
            } message: {
                Text(.pillTypeDeleteConfirmMessage)
            }
            .errorAlert(message: $model.errorMessage)
            .task { await model.load() }
        }
    }
}
