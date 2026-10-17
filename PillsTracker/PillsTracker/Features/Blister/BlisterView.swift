import Domain
import FactoryKit
import SwiftUI

struct BlisterView: View {
    @State private var model: BlisterViewModel
    @State private var isEditingPrescription = false
    @State private var isEditingPillType = false
    /// Called after the Pill Type was deleted so the owner of the navigation path can return to Home.
    private let onPillTypeDeleted: @MainActor () -> Void
    @State private var tappedPosition: TappedPosition?
    @State private var undoCandidate: Intake?

    init(pillTypeID: UUID, onPillTypeDeleted: @escaping @MainActor () -> Void) {
        _model = State(initialValue: Container.shared.blisterViewModel(pillTypeID))
        self.onPillTypeDeleted = onPillTypeDeleted
    }

    var body: some View {
        Group {
            if let pillType = model.pillType, let blister = model.currentBlister {
                ScrollView {
                    VStack(spacing: 16) {
                        if model.showsSlotChips {
                            slotChips
                        }
                        BlisterGridView(shape: blister.shape, presentPositions: blister.presentPositions) { position in
                            tappedPosition = TappedPosition(position: position, isPresent: blister.isPresent(position))
                        }
                        Text(.blisterPillsLeft(count: model.presentCount))
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
                ContentUnavailableView(.blisterNotFound, systemImage: "questionmark.circle")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(.blisterPrescription, systemImage: "calendar.badge.clock") {
                    isEditingPrescription = true
                }
                .disabled(model.pillType == nil)
                Button(.blisterPillType, systemImage: "pills") {
                    isEditingPillType = true
                }
                .disabled(model.pillType == nil)
            }
        }
        .sheet(isPresented: $isEditingPrescription) {
            PrescriptionSheet(pillTypeID: model.pillTypeID)
        }
        .sheet(isPresented: $isEditingPillType) {
            PillTypeSheet(pillTypeID: model.pillTypeID, onDeleted: onPillTypeDeleted)
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
            .blisterUndoTitle,
            isPresented: Binding(get: { undoCandidate != nil }, set: { if !$0 { undoCandidate = nil } }),
            titleVisibility: .visible,
            presenting: undoCandidate
        ) { intake in
            Button(.blisterUndoConfirm, role: .destructive) {
                Task { await model.undo(intake) }
            }
            Button(.commonCancel, role: .cancel) {}
        } message: { _ in
            Text(.blisterUndoMessage)
        }
        .errorAlert(message: $model.errorMessage)
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
                    .accessibilityHint(Text(.blisterUndoHint))
                } else {
                    SlotChipView(slot: slot, state: state)
                }
            }
        }
    }
}
