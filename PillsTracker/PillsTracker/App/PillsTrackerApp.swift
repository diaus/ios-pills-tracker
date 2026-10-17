import SwiftUI

@main
struct PillsTrackerApp: App {
    @State private var dailyProgress = DailyProgressModel()

    var body: some Scene {
        WindowGroup {
            HomeView(dailyProgress: dailyProgress)
                .task { await dailyProgress.run() }
                .recomputesToday { Task { await dailyProgress.refreshToday() } }
        }
    }
}
