import Domain
import FactoryKit
import SwiftUI

struct BlisterView: View {
    @State private var model: BlisterViewModel
    @State private var tappedPosition: TappedPosition?

    init(pillTypeID: UUID) {
        _model = State(initialValue: Container.shared.blisterViewModel(pillTypeID))
    }

    var body: some View {
        Group {
            if let pillType = model.pillType, let blister = model.currentBlister {
                ScrollView {
                    VStack(spacing: 16) {
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
        .positionActionSheet(for: $tappedPosition) { position, isPresent in
            Task { await model.setPosition(position, isPresent: isPresent) }
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
    }
}
