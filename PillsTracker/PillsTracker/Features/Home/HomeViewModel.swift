import Domain
import FactoryKit
import Foundation
import Observation
import SwiftUI

/// Drives the Home screen: Active Prescription cards with today's progress, the Paused section
/// and the Pill Types link, all drawn from the app's Daily Progress. Taps on the Lock Screen widget
/// go through `WidgetTapRouter`.
@MainActor @Observable
final class HomeViewModel {
    @ObservationIgnored @Injected(\.updatePillType) private var updatePillType

    let dailyProgress: DailyProgressModel
    var errorMessage: LocalizedStringResource?

    init(dailyProgress: DailyProgressModel) {
        self.dailyProgress = dailyProgress
    }

    private var progress: [PillTypeProgress] { dailyProgress.progress ?? [] }

    var pillTypeCount: Int { progress.count }

    var activePrescriptions: [PillTypeProgress] {
        progress.filter { $0.prescriptionState == .active }
    }

    var pausedPrescriptions: [PillTypeProgress] {
        progress.filter { $0.prescriptionState == .paused }
    }

    /// Pill Types exist but none has a Prescription yet.
    var hasNoPrescriptions: Bool {
        !progress.isEmpty && progress.allSatisfy { !$0.hasPrescription }
    }

    /// Resumes a Paused Prescription straight from the Paused section.
    func resumePrescription(pillTypeID: UUID) async {
        do {
            try await updatePillType(pillTypeID: pillTypeID) { aggregate throws(DomainError) in
                try aggregate.resumePrescription()
            }
        } catch {
            errorMessage = error.userMessage
        }
    }
}
