import Domain
import FactoryKit
import Foundation
import Observation
import SwiftUI

/// Loads one Pill Type's Intake History a month at a time, as the pager reaches each month.
@MainActor @Observable
final class IntakeHistoryViewModel {
    @ObservationIgnored @Injected(\.intakeHistory) private var intakeHistory

    let pillTypeID: UUID
    let today: Day
    /// The history of every month loaded so far, covering the Days each month's page shows.
    private(set) var histories: [HistoryMonth: PillTypeHistory] = [:]
    var errorMessage: LocalizedStringResource?

    init(pillTypeID: UUID, today: Day) {
        self.pillTypeID = pillTypeID
        self.today = today
    }

    /// Loads `month`'s page unless it is already loaded. A Pill Type that no longer exists leaves the page empty.
    func load(_ month: HistoryMonth) async {
        guard histories[month] == nil else { return }
        do {
            if let history = try await intakeHistory(pillTypeID: pillTypeID, days: month.shownDays(), today: today) {
                histories[month] = history
            }
        } catch {
            errorMessage = error.userMessage
        }
    }
}
