import Domain
import FactoryKit
import SwiftUI

struct BlisterView: View {
    @State private var model: BlisterViewModel

    init(pillTypeID: UUID) {
        _model = State(initialValue: Container.shared.blisterViewModel(pillTypeID))
    }

    var body: some View {
        Group {
            if let pillType = model.pillType, let blister = model.currentBlister {
                ScrollView {
                    VStack(spacing: 16) {
                        BlisterGridView(shape: pillType.shape, presentPositions: blister.presentPositions)
                        Text("blister.pillsLeft \(model.presentCount)")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }
                .navigationTitle(pillType.name)
            } else if model.hasLoaded {
                ContentUnavailableView("blister.notFound", systemImage: "questionmark.circle")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await model.load() }
        .task { await model.observeChanges() }
    }
}
