import Data
import Foundation
import Testing
@testable import PillsTracker

/// Where tapping the widget opens the app. `PillTypeWidgetEntry` is compiled in from the widget's sources.
@MainActor
struct PillTypeWidgetEntryTests {
    private let pillTypeID = UUID()

    @Test func tappingAPillTypeOpensItsBlisterScreen() {
        let entry = PillTypeWidgetEntry(date: .now, pillTypeID: pillTypeID, content: .active(abbreviation: "Vi", slotsDone: [false], isCompleted: false))

        #expect(entry.tap == .blister(pillTypeID: pillTypeID))
    }

    @Test func tappingADimmedPillTypeStillOpensItsBlisterScreen() {
        let entry = PillTypeWidgetEntry(date: .now, pillTypeID: pillTypeID, content: .inactive(abbreviation: "Om"))

        #expect(entry.tap == .blister(pillTypeID: pillTypeID))
    }

    @Test func tappingTheEmptyStateOfADeletedPillTypeExplainsHowToConfigure() {
        let entry = PillTypeWidgetEntry(date: .now, pillTypeID: pillTypeID, content: .empty)

        #expect(entry.tap == .configure)
    }

    @Test func tappingAnUnconfiguredWidgetExplainsHowToConfigure() {
        let entry = PillTypeWidgetEntry(date: .now, pillTypeID: nil, content: .empty)

        #expect(entry.tap == .configure)
    }
}
