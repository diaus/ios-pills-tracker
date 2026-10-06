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
                        "home.empty.title",
                        systemImage: "pills",
                        description: Text("home.empty.body")
                    )
                } else if model.hasLoaded {
                    List {
                        if !model.activePrescriptions.isEmpty {
                            Section("home.active") {
                                ForEach(model.activePrescriptions) { progress in
                                    NavigationLink(value: AppRoute.blister(pillTypeID: progress.id)) {
                                        PrescriptionCardView(progress: progress)
                                    }
                                }
                            }
                        }

                        if !model.pausedPrescriptions.isEmpty {
                            Section("home.paused") {
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
                                    "home.noPrescriptions.title",
                                    systemImage: "calendar.badge.clock",
                                    description: Text("home.noPrescriptions.body")
                                )
                            }
                        }

                        Section {
                            NavigationLink(value: AppRoute.pillTypes) {
                                Label("home.allPillTypes \(model.pillTypeCount)", systemImage: "list.bullet")
                            }
                        }
                    }
                }
            }
            .navigationTitle("home.title")
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
                    Button("home.addPillType", systemImage: "plus") {
                        isAddingPillType = true
                    }
                }
            }
        }
        .sheet(isPresented: $isAddingPillType) {
            AddPillTypeSheet()
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

    private func pausedRow(_ aggregate: PillTypeAggregate) -> some View {
        HStack {
            Text(aggregate.pillType.name)
            Spacer()
            Button("prescription.resume") {
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
