import Data
import Domain
import FactoryKit
import Foundation
import Observation
import SwiftUI

/// Drives the Home screen: Active Prescription cards with today's progress, the Paused section
/// and the Pill Types link, all drawn from the app's Daily Progress. Owns the navigation path, which a tap
/// on the Lock Screen widget resets.
@MainActor @Observable
final class HomeViewModel {
    @ObservationIgnored @Injected(\.updatePillType) private var updatePillType

    let dailyProgress: DailyProgressModel
    var errorMessage: LocalizedStringResource?
    var path: [AppRoute] = []
    /// A widget tap with no Pill Type asks how to choose one: the alert explains it.
    var isShowingWidgetHelp = false
    /// Counts widget taps that open a Blister screen, so each one opens it afresh, on Today, even when
    /// the same Pill Type's Blister screen is already on top with another Selected Day.
    private(set) var widgetTapCount = 0
    /// The Pill Type a widget tap asked for, held until Today's progress has loaded to tell whether it exists.
    private var pillTypeIDToOpen: UUID?

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

    var isLoading: Bool {
        if case .loading = dailyProgress.state { true } else { false }
    }

    /// Follows a tap on the Lock Screen widget: its Pill Type's Blister screen on Today, or Home with how to
    /// choose a Pill Type. Any other URL is ignored.
    func open(_ url: URL) {
        guard let tap = WidgetTap(url: url) else { return }
        switch tap {
        case .blister(let pillTypeID):
            pillTypeIDToOpen = pillTypeID
            openRequestedBlister()
        case .configure:
            pillTypeIDToOpen = nil
            path = []
            isShowingWidgetHelp = true
        }
    }

    /// Opens the Blister screen a widget tap asked for, once Today's progress has loaded. An unknown or
    /// deleted Pill Type, or a failed load, opens Home instead.
    func openRequestedBlister() {
        guard let pillTypeID = pillTypeIDToOpen, !isLoading else { return }
        pillTypeIDToOpen = nil
        guard progress.contains(where: { $0.id == pillTypeID }) else {
            path = []
            return
        }
        widgetTapCount += 1
        path = [.blister(pillTypeID: pillTypeID)]
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
