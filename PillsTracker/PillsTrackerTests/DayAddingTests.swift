import Domain
import Testing
@testable import PillsTracker

@MainActor
struct DayAddingTests {
    @Test func addingCrossesMonthAndYearBoundariesBothWays() {
        #expect(Day(year: 2026, month: 12, day: 31).adding(days: 1) == Day(year: 2027, month: 1, day: 1))
        #expect(Day(year: 2026, month: 3, day: 1).adding(days: -1) == Day(year: 2026, month: 2, day: 28))
        #expect(Day(year: 2028, month: 2, day: 28).adding(days: 1) == Day(year: 2028, month: 2, day: 29))
    }
}
