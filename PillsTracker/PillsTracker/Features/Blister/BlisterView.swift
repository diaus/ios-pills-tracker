import Domain
import FactoryKit
import SwiftUI

struct BlisterView: View {
    @State private var model: BlisterViewModel
    @State private var isEditingPrescription = false
    @State private var tappedPosition: TappedPosition?
    @State private var undoCandidate: Intake?

    init(pillTypeID: UUID) {
        _model = State(initialValue: Container.shared.blisterViewModel(pillTypeID))
    }

    var body: some View {
        Group {
            if let pillType = model.pillType, let blister = model.currentBlister {
                ScrollView {
                    VStack(spacing: 16) {
                        if model.showsSlotChips {
                            slotChips
                        }
                        BlisterGridView(shape: pillType.shape, presentPositions: blister.presentPositions) { position in
                            tappedPosition = TappedPosition(position: position, isPresent: blister.isPresent(position))
                        }
                        Text("blister.pillsLeft \(model.presentCount)")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        if model.canStartNewBlister {
                            StartNewBlisterButton {
                                Task { await model.startNewBlister() }
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle(pillType.name)
            } else if model.hasLoaded {
                ContentUnavailableView("blister.notFound", systemImage: "questionmark.circle")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("blister.prescription", systemImage: "calendar.badge.clock") {
                    isEditingPrescription = true
                }
                .disabled(model.pillType == nil)
            }
        }
        .sheet(isPresented: $isEditingPrescription) {
            PrescriptionSheet(pillTypeID: model.pillTypeID)
        }
        .positionActionSheet(
            for: $tappedPosition,
            openSlots: model.openSlots,
            onConsume: { position, slot in
                Task { await model.consume(position, slot: slot) }
            },
            onSync: { position, isPresent in
                Task { await model.setPosition(position, isPresent: isPresent) }
            }
        )
        .confirmationDialog(
            "blister.undo.title",
            isPresented: Binding(get: { undoCandidate != nil }, set: { if !$0 { undoCandidate = nil } }),
            titleVisibility: .visible,
            presenting: undoCandidate
        ) { intake in
            Button("blister.undo.confirm", role: .destructive) {
                Task { await model.undo(intake) }
            }
            Button("common.cancel", role: .cancel) {}
        } message: { _ in
            Text("blister.undo.message")
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
        .task { await model.observeChanges() }
        .recomputesToday { Task { await model.refreshToday() } }
    }

    /// Today's chips. A Done chip whose Intake can be undone (today, Current Blister) opens the Undo confirmation.
    private var slotChips: some View {
        HStack(spacing: 8) {
            ForEach(Slot.allCases, id: \.self) { slot in
                let state = model.chipState(for: slot)
                if let intake = model.undoableIntake(for: slot) {
                    Button {
                        undoCandidate = intake
                    } label: {
                        SlotChipView(slot: slot, state: state)
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint(Text("blister.undo.hint"))
                } else {
                    SlotChipView(slot: slot, state: state)
                }
            }
        }
    }
}
