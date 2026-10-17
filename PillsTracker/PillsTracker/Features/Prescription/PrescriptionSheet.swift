import Domain
import FactoryKit
import SwiftUI

/// Sheet opened from the Blister toolbar. Creates a Prescription when the Pill Type has none;
/// otherwise edits its Slots and offers pause, resume and delete (with confirmation).
struct PrescriptionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var model: PrescriptionViewModel
    @State private var isConfirmingDelete = false

    init(pillTypeID: UUID) {
        _model = State(initialValue: Container.shared.prescriptionViewModel(pillTypeID))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SlotToggles(selection: $model.selectedSlots)
                    if let validationError = model.validationError {
                        Text(validationError.message)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text(.prescriptionSlots)
                } footer: {
                    Text(.prescriptionSlotsFooter)
                }

                if model.hasPrescription {
                    Section {
                        LabeledContent {
                            Text(model.isPaused ? .prescriptionStatePaused : .prescriptionStateActive)
                        } label: {
                            Text(.prescriptionState)
                        }
                        if model.isPaused {
                            Button(.prescriptionResume, systemImage: "play.circle") {
                                Task { await model.resume() }
                            }
                        } else {
                            Button(.prescriptionPause, systemImage: "pause.circle") {
                                Task { await model.pause() }
                            }
                        }
                    }

                    Section {
                        Button(.prescriptionDelete, role: .destructive) {
                            isConfirmingDelete = true
                        }
                    }
                }
            }
            .disabled(model.isSaving)
            .navigationTitle(model.hasPrescription ? .prescriptionTitleEdit : .prescriptionTitleNew)
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
            .confirmationDialog(.prescriptionDeleteConfirmTitle, isPresented: $isConfirmingDelete, titleVisibility: .visible) {
                Button(.prescriptionDeleteConfirm, role: .destructive) {
                    Task {
                        if await model.delete() { dismiss() }
                    }
                }
                Button(.commonCancel, role: .cancel) {}
            } message: {
                Text(.prescriptionDeleteConfirmMessage)
            }
            .errorAlert(message: $model.errorMessage)
            .task { await model.load() }
        }
    }
}
