import Data
import Foundation
import Testing
@testable import PillsTracker

/// Where tapping the widget opens the app. `PillTypeWidgetEntry` is compiled in from the widget's sources.
@MainActor
struct PillTypeWidgetEntryTests {
    private let pillTypeID = UUID()

    @Test func tappingAPillTypeOpensItsBlisterScreen() {
        let entry = PillTypeWidgetEntry(date: .now, pillTypeID: pillTypeID, content: .withActivePrescription(abbreviation: "Vi", slotsDone: [false]))

        #expect(entry.tap == .blister(pillTypeID: pillTypeID))
    }

    @Test func tappingADimmedPillTypeStillOpensItsBlisterScreen() {
        let entry = PillTypeWidgetEntry(date: .now, pillTypeID: pillTypeID, content: .withoutActivePrescription(abbreviation: "Om"))

        #expect(entry.tap == .blister(pillTypeID: pillTypeID))
    }

    @Test func tappingTheEmptyStateOfADeletedPillTypeExplainsHowToConfigure() {
        let entry = PillTypeWidgetEntry(date: .now, pillTypeID: pillTypeID, content: .noPillType)

        #expect(entry.tap == .configure)
    }

    @Test func tappingAnUnconfiguredWidgetExplainsHowToConfigure() {
        let entry = PillTypeWidgetEntry(date: .now, pillTypeID: nil, content: .noPillType)

        #expect(entry.tap == .configure)
    }
}
