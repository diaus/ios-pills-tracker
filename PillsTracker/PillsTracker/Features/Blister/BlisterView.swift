import Domain
import SwiftUI

struct BlisterView: View {
    @State private var model: BlisterViewModel
    @State private var isEditingPrescription = false
    @State private var isEditingPillType = false
    /// Called after the Pill Type was deleted so the owner of the navigation path can return to Home.
    private let onPillTypeDeleted: @MainActor () -> Void
    @State private var tappedPosition: TappedPosition?
    @State private var undoCandidate: Intake?

    init(pillTypeID: UUID, dailyProgress: DailyProgressModel, onPillTypeDeleted: @escaping @MainActor () -> Void) {
        _model = State(initialValue: BlisterViewModel(pillTypeID: pillTypeID, dailyProgress: dailyProgress))
        self.onPillTypeDeleted = onPillTypeDeleted
    }

    var body: some View {
        Group {
            if let progress = model.progress, let blister = progress.currentBlister {
                ScrollView {
                    VStack(spacing: 16) {
                        if progress.hasPrescription {
                            slotChips(progress)
                        }
                        BlisterGridView(
                            shape: blister.shape,
                            presentPositions: blister.presentPositions,
                            todaysSlots: progress.daySlotsByPosition,
                            undoablePositions: progress.undoablePositions
                        ) { position in
                            // An Empty Position with an Intake is only ever undone; any other one opens the sheet.
                            if let intake = progress.undoableIntake(at: position) {
                                undoCandidate = intake
                            } else {
                                tappedPosition = TappedPosition(position: position, isPresent: blister.isPresent(position))
                            }
                        }
                        Text(.blisterPillsLeft(count: progress.presentCount))
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        if progress.canStartNewBlister {
                            StartNewBlisterButton {
                                Task { await model.startNewBlister() }
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle(progress.pillType.name)
            } else {
                switch model.dailyProgress.state {
                case .loading:
                    ProgressView()
                case .failed(let message):
                    LoadFailedView(message: message)
                case .loaded:
                    ContentUnavailableView(.blisterNotFound, systemImage: "questionmark.circle")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(.blisterPrescription, systemImage: "calendar.badge.clock") {
                    isEditingPrescription = true
                }
                .disabled(model.progress == nil)
                Button(.blisterPillType, systemImage: "pills") {
                    isEditingPillType = true
                }
                .disabled(model.progress == nil)
            }
        }
        .sheet(isPresented: $isEditingPrescription) {
            if let aggregate = model.progress?.aggregate {
                PrescriptionSheet(aggregate: aggregate)
            }
        }
        .sheet(isPresented: $isEditingPillType) {
            if let aggregate = model.progress?.aggregate {
                EditPillTypeSheet(aggregate: aggregate, onDeleted: onPillTypeDeleted)
            }
        }
        .positionActionSheet(
            for: $tappedPosition,
            consumableSlots: { model.progress?.consumableSlots(at: $0) ?? [] },
            canSetPresent: { model.progress?.canSetPresent($0) ?? false },
            onConsume: { position, slot in
                Task { await model.consume(position, slot: slot) }
            },
            onSync: { position, isPresent in
                Task { await model.setPosition(position, isPresent: isPresent) }
            }
        )
        .confirmationDialog(
            undoCandidate.map { Text($0.slot.undoTitle) } ?? Text(verbatim: ""),
            isPresented: Binding(get: { undoCandidate != nil }, set: { if !$0 { undoCandidate = nil } }),
            titleVisibility: .visible,
            presenting: undoCandidate
        ) { intake in
            Button(.blisterUndoConfirm, role: .destructive) {
                Task { await model.undo(intake) }
            }
            Button(.commonCancel, role: .cancel) {}
        } message: { intake in
            Text(.blisterUndoMessage(day: intake.day.relativeName(today: model.dailyProgress.today)))
        }
        .errorAlert(message: $model.errorMessage)
    }

    /// Today's chips. A Done chip whose Intake can be undone (Current Blister, latest at its Position) opens the Undo confirmation.
    private func slotChips(_ progress: PillTypeProgress) -> some View {
        HStack(spacing: 8) {
            ForEach(progress.slots, id: \.slot) { slotProgress in
                if let intake = progress.undoableIntake(for: slotProgress.slot) {
                    Button {
                        undoCandidate = intake
                    } label: {
                        SlotChipView(slot: slotProgress.slot, isDone: slotProgress.isDone)
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint(Text(.blisterUndoHint))
                } else {
                    SlotChipView(slot: slotProgress.slot, isDone: slotProgress.isDone)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        BlisterView(
            pillTypeID: PillTypeProgress.previewVitaminD.id,
            dailyProgress: .preview(.loaded([.previewVitaminD]))
        ) {}
    }
}

#Preview("Loading") {
    NavigationStack {
        BlisterView(pillTypeID: UUID(), dailyProgress: .preview(.loading)) {}
    }
}

#Preview("Failed") {
    NavigationStack {
        BlisterView(pillTypeID: UUID(), dailyProgress: .preview(.failed(.commonErrorUnknown))) {}
    }
}
