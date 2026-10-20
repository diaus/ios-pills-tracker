import Foundation
import Testing
@testable import Domain

struct PrescriptionTests {
    private let pillTypeID = UUID()
    private let startDay = Day(year: 2026, month: 1, day: 1)

    @Test func prescriptionRejectsAnEmptySlotSet() {
        #expect(throws: DomainError.emptySlots) {
            try Prescription(pillTypeID: pillTypeID, slots: [], startDay: startDay)
        }
    }

    @Test func prescriptionStartsActiveWithItsSlots() throws {
        let prescription = try Prescription(pillTypeID: pillTypeID, slots: [.morning, .evening], startDay: startDay)
        #expect(prescription.pillTypeID == pillTypeID)
        #expect(prescription.slots == [.morning, .evening])
        #expect(prescription.state == .active)
    }

    @Test func editingSlotsToAnEmptySetIsRejectedAndKeepsTheOldSlots() throws {
        var prescription = try Prescription(pillTypeID: pillTypeID, slots: [.day], startDay: startDay)
        #expect(throws: DomainError.emptySlots) { try prescription.setSlots([]) }
        #expect(prescription.slots == [.day])
    }
}
