import Domain
import SwiftUI

/// Every Pill Type ordered by creation date, read from the app's Daily Progress.
struct PillTypesListView: View {
    let dailyProgress: DailyProgressModel

    var body: some View {
        Group {
            switch dailyProgress.state {
            case .loading:
                ProgressView()
            case .failed(let message):
                LoadFailedView(message: message)
            case .loaded(let progress):
                List(progress) { progress in
                    NavigationLink(value: AppRoute.blister(pillTypeID: progress.id)) {
                        VStack(alignment: .leading) {
                            Text(progress.pillType.name)
                            Text(.pillTypesShape(rows: progress.pillType.shape.rows, columns: progress.pillType.shape.columns))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .overlay {
                    if progress.isEmpty {
                        ContentUnavailableView(.homeEmptyTitle, systemImage: "pills", description: Text(.homeEmptyBody))
                    }
                }
            }
        }
        .navigationTitle(.pillTypesTitle)
    }
}

#Preview {
    NavigationStack {
        PillTypesListView(dailyProgress: .preview(.loaded(PillTypeProgress.previewAll)))
    }
}

#Preview("Empty") {
    NavigationStack {
        PillTypesListView(dailyProgress: .preview(.loaded([])))
    }
}
