import FactoryKit
import SwiftUI

struct HomeView: View {
    @State private var model = Container.shared.homeViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if model.isEmpty {
                    ContentUnavailableView(
                        "home.empty.title",
                        systemImage: "pills",
                        description: Text("home.empty.body")
                    )
                }
            }
            .navigationTitle("home.title")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("home.addPillType", systemImage: "plus") {
                        // Adding a Pill Type arrives in a later ticket.
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
