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
                    ForEach(Slot.allCases, id: \.self) { slot in
                        Toggle(slot.title, isOn: Binding(
                            get: { model.isSelected(slot) },
                            set: { model.setSelected(slot, $0) }
                        ))
                    }
                    if let slotsError = model.slotsError {
                        Text(slotsError)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("prescription.slots")
                } footer: {
                    Text("prescription.slots.footer")
                }

                if model.hasPrescription {
                    Section {
                        LabeledContent("prescription.state") {
                            Text(model.isPaused ? "prescription.state.paused" : "prescription.state.active")
                        }
                        if model.isPaused {
                            Button("prescription.resume", systemImage: "play.circle") {
                                Task { await model.resume() }
                            }
                        } else {
                            Button("prescription.pause", systemImage: "pause.circle") {
                                Task { await model.pause() }
                            }
                        }
                    }

                    Section {
                        Button("prescription.delete", role: .destructive) {
                            isConfirmingDelete = true
                        }
                    }
                }
            }
            .disabled(model.isSaving)
            .navigationTitle(model.hasPrescription ? "prescription.title.edit" : "prescription.title.new")
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
            .confirmationDialog("prescription.delete.confirm.title", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
                Button("prescription.delete.confirm", role: .destructive) {
                    Task {
                        if await model.delete() { dismiss() }
                    }
                }
                Button("common.cancel", role: .cancel) {}
            } message: {
                Text("prescription.delete.confirm.message")
            }
            .alert("common.error", isPresented: Binding(
                get: { model.errorMessage != nil },
                set: { if !$0 { model.errorMessage = nil } }
            )) {
                Button("common.ok") {}
            } message: {
                Text(model.errorMessage ?? "")
            }
            .task { await model.load() }
        }
    }
}
