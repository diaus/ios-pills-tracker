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
        VStack(spacing: 0) {
            // Pinned outside the Selected Day's content, so it stays while a past Day loads.
            if model.aggregate != nil {
                daySwitcher
                    .padding([.horizontal, .top])
            }
            selectedDayContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle(model.aggregate?.pillType.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(.blisterPrescription, systemImage: "calendar.badge.clock") {
                    isEditingPrescription = true
                }
                .disabled(model.aggregate == nil)
                Button(.blisterPillType, systemImage: "pills") {
                    isEditingPillType = true
                }
                .disabled(model.aggregate == nil)
            }
        }
        .sheet(isPresented: $isEditingPrescription) {
            if let aggregate = model.aggregate {
                PrescriptionSheet(aggregate: aggregate)
            }
        }
        .sheet(isPresented: $isEditingPillType) {
            if let aggregate = model.aggregate {
                EditPillTypeSheet(aggregate: aggregate, onDeleted: onPillTypeDeleted)
            }
        }
        .task(id: model.selectedDay) { await model.run() }
        .onChange(of: model.dailyProgress.today) { old, new in
            model.todayChanged(from: old, to: new)
        }
        .positionActionSheet(
            for: $tappedPosition,
            title: consumeTitle,
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
            Text(.blisterUndoMessage(day: model.name(of: intake.day)))
        }
        .errorAlert(message: $model.errorMessage)
    }

    /// The Selected Day's chips and grid, or its loading, failed or not-found state.
    @ViewBuilder
    private var selectedDayContent: some View {
        if let progress = model.progress, let blister = progress.currentBlister {
            ScrollView {
                VStack(spacing: 16) {
                    if progress.hasPrescription {
                        slotChips(progress)
                    }
                    BlisterGridView(
                        shape: blister.shape,
                        presentPositions: blister.presentPositions,
                        daySlots: progress.daySlotsByPosition,
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
        } else if model.aggregate != nil {
            // The Pill Type exists; the Selected Day's progress is still loading.
            ProgressView()
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

    /// The Selected Day between arrows that move it; the forward one stops at today.
    private var daySwitcher: some View {
        HStack {
            Button(.blisterDayPrevious, systemImage: "chevron.left") {
                model.moveBack()
            }
            Spacer()
            Text(model.name(of: model.selectedDay).localizedCapitalized)
                .font(.headline)
            Spacer()
            Button(.blisterDayNext, systemImage: "chevron.right") {
                model.moveForward()
            }
            .disabled(!model.canMoveForward)
        }
        .labelStyle(.iconOnly)
        .font(.title3)
    }

    /// Names the Selected Day a Present Position would be consumed for, when it isn't today.
    private var consumeTitle: Text? {
        guard tappedPosition?.isPresent == true, !model.isOnToday else { return nil }
        return Text(.blisterPositionTitleForDay(day: model.name(of: model.selectedDay)))
    }

    /// The Selected Day's chips. A Done chip whose Intake can be undone (Current Blister, latest at its Position) opens the Undo confirmation.
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
