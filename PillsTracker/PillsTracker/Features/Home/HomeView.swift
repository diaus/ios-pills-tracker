import Domain
import SwiftUI

struct HomeView: View {
    @State private var model: HomeViewModel
    @State private var path: [AppRoute] = []
    @State private var isAddingPillType = false

    init(dailyProgress: DailyProgressModel) {
        _model = State(initialValue: HomeViewModel(dailyProgress: dailyProgress))
    }

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                switch model.dailyProgress.state {
                case .loading:
                    ProgressView()
                case .failed(let message):
                    LoadFailedView(message: message)
                case .loaded(let progress) where progress.isEmpty:
                    ContentUnavailableView(
                        .homeEmptyTitle,
                        systemImage: "pills",
                        description: Text(.homeEmptyBody)
                    )
                case .loaded:
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
                                ForEach(model.pausedPrescriptions) { progress in
                                    NavigationLink(value: AppRoute.blister(pillTypeID: progress.id)) {
                                        pausedRow(progress.aggregate)
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
                    PillTypesListView(dailyProgress: model.dailyProgress)
                case .blister(let pillTypeID):
                    BlisterView(pillTypeID: pillTypeID, dailyProgress: model.dailyProgress) { path.removeAll() }
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
    HomeView(dailyProgress: .preview(.loaded(PillTypeProgress.previewAll)))
}
