import Foundation
import Testing
@testable import Domain

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

    @Test func settingThePrescriptionStoresItsStartDayAndEndDay() throws {
        var aggregate = try makeAggregate()
        let start = Day(year: 2026, month: 9, day: 1)
        let end = Day(year: 2026, month: 9, day: 30)

        try aggregate.setPrescription(slots: [.morning], startDay: start, endDay: end)

        #expect(aggregate.prescription?.startDay == start)
        #expect(aggregate.prescription?.endDay == end)
    }

    @Test func editingThePrescriptionsDaysKeepsItsIdentityAndState() throws {
        var aggregate = try makeAggregate()
        try aggregate.setPrescription(slots: [.morning], startDay: Day(year: 2026, month: 9, day: 1), endDay: nil)
        let originalID = try #require(aggregate.prescription?.id)
        try aggregate.pausePrescription()
        let newStart = Day(year: 2026, month: 8, day: 15)
        let newEnd = Day(year: 2026, month: 12, day: 31)

        try aggregate.setPrescription(slots: [.day], startDay: newStart, endDay: newEnd)

        #expect(aggregate.prescription?.id == originalID)
        #expect(aggregate.prescription?.state == .paused)
        #expect(aggregate.prescription?.slots == [.day])
        #expect(aggregate.prescription?.startDay == newStart)
        #expect(aggregate.prescription?.endDay == newEnd)
    }

    @Test func settingEmptySlotsIsRejected() throws {
        var aggregate = try makeAggregate()
        #expect(throws: DomainError.emptySlots) { try aggregate.setPrescriptionSlots([]) }
        #expect(aggregate.prescription == nil)
    }

    @Test func pauseThenResumeRestoresActiveState() throws {
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
