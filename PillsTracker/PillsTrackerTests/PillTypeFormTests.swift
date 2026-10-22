import Domain
import Foundation
import Testing
@testable import PillsTracker

/// The name, Abbreviation and grid shape the Add Pill Type and Pill Type sheets edit.
@MainActor
struct PillTypeFormTests {
    private let createdAt = Date(timeIntervalSince1970: 0)
    private let today = Day(year: 2026, month: 10, day: 6)

    private func makeAggregate() throws -> PillTypeAggregate {
        try PillTypeAggregate.new(name: "Aspirin", abbreviation: "As", rows: 2, columns: 3, createdAt: createdAt)
    }

    @Test func aNewFormMakesAPillTypeWithItsFields() throws {
        var form = PillTypeForm()
        form.name = "Vitamin D"
        form.abbreviation = "D3"

        let aggregate = try form.makeAggregate(createdAt: createdAt)

        #expect(aggregate.pillType.name == "Vitamin D")
        #expect(aggregate.pillType.abbreviation == "D3")
        #expect(aggregate.pillType.shape == (try GridShape(rows: 2, columns: 5)))
    }

    @Test func aBlankAbbreviationIsNotSet() throws {
        var form = PillTypeForm()
        form.name = "Vitamin D"

        #expect(try form.makeAggregate(createdAt: createdAt).pillType.abbreviation == nil)
    }

    @Test func anEmptyNameIsRefused() {
        #expect(throws: DomainError.emptyName) {
            try PillTypeForm().makeAggregate(createdAt: createdAt)
        }
    }

    @Test func aFormStartsFromThePillType() throws {
        let form = PillTypeForm(try makeAggregate())

        #expect(form.name == "Aspirin")
        #expect(form.abbreviation == "As")
        #expect(form.rows == 2)
        #expect(form.columns == 3)
    }

    @Test func applyingRenamesAndSetsTheAbbreviationAndShape() throws {
        var aggregate = try makeAggregate()
        for position in aggregate.pillType.shape.allPositions {
            try aggregate.syncPosition(position, isPresent: false, blisterIntakes: [])
        }
        var form = PillTypeForm(aggregate)
        form.name = "Aspirin Forte"
        form.abbreviation = ""
        form.rows = 4

        try form.apply(to: &aggregate)

        #expect(aggregate.pillType.name == "Aspirin Forte")
        #expect(aggregate.pillType.abbreviation == nil)
        #expect(aggregate.pillType.shape == (try GridShape(rows: 4, columns: 3)))
    }

    /// The shape can't change while the Current Blister has a Present pill, but renaming still works.
    @Test func anUnchangedShapeIsNotReappliedToABlisterWithPills() throws {
        var aggregate = try makeAggregate()
        var form = PillTypeForm(aggregate)
        form.name = "Aspirin Forte"

        try form.apply(to: &aggregate)

        #expect(aggregate.pillType.name == "Aspirin Forte")
    }

    @Test func aChangedShapeOnABlisterWithPillsIsRefused() throws {
        var aggregate = try makeAggregate()
        var form = PillTypeForm(aggregate)
        form.columns = 4

        #expect(throws: DomainError.currentBlisterNotEmpty) {
            try form.apply(to: &aggregate)
        }
    }

    @Test func eachErrorShowsUnderItsField() {
        #expect(PillTypeForm.field(for: .emptyName) == .name)
        #expect(PillTypeForm.field(for: .invalidRows) == .rows)
        #expect(PillTypeForm.field(for: .invalidColumns) == .columns)
        #expect(PillTypeForm.field(for: .currentBlisterNotEmpty) == .shape)
    }
}
