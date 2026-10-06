import Testing
@testable import Domain

struct SlotTests {
    @Test func prescriptionSlotsAreMorningDayEvening() {
        #expect(Slot.allCases == [.morning, .day, .evening])
    }
}
