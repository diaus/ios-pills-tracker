import Foundation
import Testing
@testable import Domain

struct PrescriptionTests {
    private let pillTypeID = UUID()

    @Test func prescriptionRejectsAnEmptySlotSet() {
        #expect(throws: DomainError.emptySlots) {
            try Prescription(pillTypeID: pillTypeID, slots: [])
        }
    }

    @Test func prescriptionStartsActiveWithItsSlots() throws {
        let prescription = try Prescription(pillTypeID: pillTypeID, slots: [.morning, .evening])
        #expect(prescription.pillTypeID == pillTypeID)
        #expect(prescription.slots == [.morning, .evening])
        #expect(prescription.state == .active)
    }

    @Test func editingSlotsToAnEmptySetIsRejectedAndKeepsTheOldSlots() throws {
        var prescription = try Prescription(pillTypeID: pillTypeID, slots: [.day])
        #expect(throws: DomainError.emptySlots) { try prescription.setSlots([]) }
        #expect(prescription.slots == [.day])
    }
}
