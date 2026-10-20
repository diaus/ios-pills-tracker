import Domain
import Testing
@testable import PillsTracker

@MainActor
struct PrescriptionDaysSelectionTests {
    private let october1 = Day(year: 2026, month: 10, day: 1)
    private let october10 = Day(year: 2026, month: 10, day: 10)
    private let october20 = Day(year: 2026, month: 10, day: 20)

    @Test func movingTheStartDayPastTheEndDayMovesTheEndDayAlong() {
        var selection = PrescriptionDaysSelection(startDay: october1, endDay: october10)

        selection.startDayDate = october20.date()

        #expect(selection.startDay == october20)
        #expect(selection.endDay == october20)
    }

    @Test func movingTheStartDayBeforeTheEndDayKeepsTheEndDay() {
        var selection = PrescriptionDaysSelection(startDay: october10, endDay: october20)

        selection.startDayDate = october1.date()

        #expect(selection.endDay == october20)
    }

    @Test func turningTheEndDayOffMakesItOpenEndedAndTurningItBackOnRestoresIt() {
        var selection = PrescriptionDaysSelection(startDay: october1, endDay: october10)

        selection.hasEndDay = false
        #expect(selection.endDay == nil)

        selection.hasEndDay = true
        #expect(selection.endDay == october10)
    }

    @Test func anOpenEndedPrescriptionsEndDayPickerStartsOnItsStartDay() {
        var selection = PrescriptionDaysSelection(startDay: october10, endDay: nil)

        #expect(selection.endDay == nil)
        selection.hasEndDay = true
        #expect(selection.endDay == october10)
    }
}
