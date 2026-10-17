import Domain
import SwiftUI

struct PillTypesListView: View {
    @State private var model = PillTypesListViewModel()

    var body: some View {
        List(model.pillTypes) { aggregate in
            NavigationLink(value: AppRoute.blister(pillTypeID: aggregate.id)) {
                VStack(alignment: .leading) {
                    Text(aggregate.pillType.name)
                    Text(.pillTypesShape(rows: aggregate.pillType.shape.rows, columns: aggregate.pillType.shape.columns))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .overlay {
            if model.pillTypes.isEmpty {
                ContentUnavailableView(.homeEmptyTitle, systemImage: "pills", description: Text(.homeEmptyBody))
            }
        }
        .navigationTitle(.pillTypesTitle)
        .errorAlert(message: $model.errorMessage)
        .task { await model.load() }
        .task { await model.observeChanges() }
    }
}
