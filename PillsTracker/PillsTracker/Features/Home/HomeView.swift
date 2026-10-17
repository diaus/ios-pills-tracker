import Domain
import FactoryKit
import SwiftUI

struct HomeView: View {
    @State private var model = Container.shared.homeViewModel()
    @State private var path: [AppRoute] = []
    @State private var isAddingPillType = false

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if model.isEmpty {
                    ContentUnavailableView(
                        .homeEmptyTitle,
                        systemImage: "pills",
                        description: Text(.homeEmptyBody)
                    )
                } else if model.hasLoaded {
                    List {
                        if !model.activePrescriptions.isEmpty {
                            Section(.homeActive) {
                                ForEach(model.activePrescriptions) { progress in
                                    NavigationLink(value: AppRoute.blister(pillTypeID: progress.id)) {
                                        PrescriptionCardView(progress: progress)
                                    }
                                }
                            }
                        }

                        if !model.pausedPrescriptions.isEmpty {
                            Section(.homePaused) {
                                ForEach(model.pausedPrescriptions) { aggregate in
                                    NavigationLink(value: AppRoute.blister(pillTypeID: aggregate.id)) {
                                        pausedRow(aggregate)
                                    }
                                }
                            }
                        }

                        if model.hasNoPrescriptions {
                            Section {
                                ContentUnavailableView(
                                    .homeNoPrescriptionsTitle,
                                    systemImage: "calendar.badge.clock",
                                    description: Text(.homeNoPrescriptionsBody)
                                )
                            }
                        }

                        Section {
                            NavigationLink(value: AppRoute.pillTypes) {
                                Label(.homeAllPillTypes(count: model.pillTypeCount), systemImage: "list.bullet")
                            }
                        }
                    }
                }
            }
            .navigationTitle(.homeTitle)
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .pillTypes:
                    PillTypesListView()
                case .blister(let pillTypeID):
                    BlisterView(pillTypeID: pillTypeID) { path.removeAll() }
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(.homeAddPillType, systemImage: "plus") {
                        isAddingPillType = true
                    }
                }
            }
        }
        .sheet(isPresented: $isAddingPillType) {
            AddPillTypeSheet()
        }
        .errorAlert(message: $model.errorMessage)
        .task { await model.load() }
        .task { await model.observeChanges() }
        .recomputesToday { Task { await model.refreshToday() } }
    }

    private func pausedRow(_ aggregate: PillTypeAggregate) -> some View {
        HStack {
            Text(aggregate.pillType.name)
            Spacer()
            Button(.prescriptionResume) {
                Task { await model.resumePrescription(pillTypeID: aggregate.id) }
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            .controlSize(.small)
        }
    }
}

#Preview {
    HomeView()
}
