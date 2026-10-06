import Domain
import FactoryKit
import SwiftUI

struct PillTypesListView: View {
    @State private var model = Container.shared.pillTypesListViewModel()

    var body: some View {
        List(model.pillTypes) { aggregate in
            NavigationLink(value: AppRoute.blister(pillTypeID: aggregate.id)) {
                VStack(alignment: .leading) {
                    Text(aggregate.pillType.name)
                    Text("pillTypes.shape \(aggregate.pillType.shape.rows) \(aggregate.pillType.shape.columns)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .overlay {
            if model.pillTypes.isEmpty {
                ContentUnavailableView("home.empty.title", systemImage: "pills", description: Text("home.empty.body"))
            }
        }
        .navigationTitle("pillTypes.title")
        .task { await model.load() }
        .task { await model.observeChanges() }
    }
}
