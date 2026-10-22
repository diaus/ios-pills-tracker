import Data
import Domain
import Foundation
import Observation

/// Follows taps on the Lock Screen widget into Home's navigation: its Pill Type's Blister screen on Today, or
/// Home with how to choose a Pill Type. Owns the navigation path, which a tap resets.
@MainActor @Observable
final class WidgetTapRouter {
    var path: [AppRoute] = []
    /// A widget tap with no Pill Type asks how to choose one: the alert explains it.
    var isShowingWidgetHelp = false
    /// Counts widget taps that open a Blister screen, so each one opens it afresh, on Today, even when
    /// the same Pill Type's Blister screen is already on top with another Selected Day.
    private var blisterTapCount = 0
    /// The Pill Type a widget tap asked for, held until Today's progress has loaded to tell whether it exists.
    private var pillTypeIDToOpen: UUID?

    private let dailyProgress: DailyProgressModel

    init(dailyProgress: DailyProgressModel) {
        self.dailyProgress = dailyProgress
    }

    /// The identity of `pillTypeID`'s Blister screen: new on every widget tap that opens it, and never shared
    /// with another Pill Type's. A tap bumps the count before the navigation path reaches its destination, so
    /// the destination is first rebuilt with the Pill Type it showed; keyed on the count alone, the tapped
    /// Pill Type's screen would then inherit that one's state and keep showing it.
    func blisterIdentity(of pillTypeID: UUID) -> some Hashable {
        BlisterIdentity(pillTypeID: pillTypeID, tapCount: blisterTapCount)
    }

    private struct BlisterIdentity: Hashable {
        let pillTypeID: UUID
        let tapCount: Int
    }

    /// Follows a widget tap's URL. Any other URL is ignored.
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
        guard let pillTypeID = pillTypeIDToOpen, !dailyProgress.state.isLoading else { return }
        pillTypeIDToOpen = nil
        guard dailyProgress.progress?.contains(where: { $0.id == pillTypeID }) == true else {
            path = []
            return
        }
        blisterTapCount += 1
        path = [.blister(pillTypeID: pillTypeID)]
    }
}
