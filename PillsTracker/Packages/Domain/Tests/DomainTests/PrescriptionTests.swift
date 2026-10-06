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

struct PillTypeAggregatePrescriptionTests {
    private func makeAggregate() throws -> PillTypeAggregate {
        try PillTypeAggregate.new(name: "Aspirin", rows: 2, columns: 5, createdAt: Date(timeIntervalSince1970: 0))
    }

    @Test func newPillTypeHasNoPrescription() throws {
        #expect(try makeAggregate().prescription == nil)
    }

    @Test func settingSlotsCreatesAnActivePrescriptionOwnedByThePillType() throws {
        var aggregate = try makeAggregate()
        try aggregate.setPrescriptionSlots([.morning])

        let prescription = try #require(aggregate.prescription)
        #expect(prescription.pillTypeID == aggregate.id)
        #expect(prescription.slots == [.morning])
        #expect(prescription.state == .active)
    }

    @Test func settingSlotsAgainEditsTheExistingPrescriptionAndKeepsItsIdentityAndState() throws {
        var aggregate = try makeAggregate()
        try aggregate.setPrescriptionSlots([.morning])
        let originalID = try #require(aggregate.prescription?.id)
        try aggregate.pausePrescription()

        try aggregate.setPrescriptionSlots([.day, .evening])

        #expect(aggregate.prescription?.id == originalID)
        #expect(aggregate.prescription?.slots == [.day, .evening])
        #expect(aggregate.prescription?.state == .paused)
    }

    @Test func settingEmptySlotsIsRejected() throws {
        var aggregate = try makeAggregate()
        #expect(throws: DomainError.emptySlots) { try aggregate.setPrescriptionSlots([]) }
        #expect(aggregate.prescription == nil)
    }

    @Test func pauseAndResumeToggleThePrescriptionState() throws {
        var aggregate = try makeAggregate()
        try aggregate.setPrescriptionSlots([.morning])

        try aggregate.pausePrescription()
        #expect(aggregate.prescription?.state == .paused)

        try aggregate.resumePrescription()
        #expect(aggregate.prescription?.state == .active)
    }

    @Test func pausingOrResumingWithoutAPrescriptionIsRejected() throws {
        var aggregate = try makeAggregate()
        #expect(throws: DomainError.noPrescription) { try aggregate.pausePrescription() }
        #expect(throws: DomainError.noPrescription) { try aggregate.resumePrescription() }
    }

    @Test func removingThePrescriptionLeavesThePillTypeAndBlistersIntact() throws {
        var aggregate = try makeAggregate()
        try aggregate.setPrescriptionSlots([.morning])
        let blisters = aggregate.blisters

        aggregate.removePrescription()

        #expect(aggregate.prescription == nil)
        #expect(aggregate.pillType.name == "Aspirin")
        #expect(aggregate.blisters == blisters)
    }
}
