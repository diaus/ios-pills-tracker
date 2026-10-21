import Foundation
import Testing
@testable import Domain

struct PillTypeTests {
    private func makePillType(name: String = "Aspirin", abbreviation: String? = nil) throws -> PillType {
        try PillType(name: name, abbreviation: abbreviation, shape: GridShape(rows: 2, columns: 5), createdAt: Date(timeIntervalSince1970: 0))
    }

    @Test func pillTypeRequiresANonEmptyName() {
        #expect(throws: DomainError.emptyName) {
            try makePillType(name: "   ")
        }
    }

    @Test func pillTypeKeepsTrimmedName() throws {
        let pillType = try makePillType(name: "  Aspirin ")
        #expect(pillType.name == "Aspirin")
    }

    // MARK: Abbreviation

    @Test(arguments: ["", "   ", " \n\t "])
    func blankAbbreviationIsNotSet(_ blank: String) throws {
        #expect(try makePillType(abbreviation: blank).abbreviation == nil)
    }

    @Test func pillTypeKeepsTrimmedAbbreviation() throws {
        #expect(try makePillType(abbreviation: " Asp ").abbreviation == "Asp")
    }

    @Test func displayAbbreviationIsTheAbbreviationWhenSet() throws {
        #expect(try makePillType(name: "Aspirin", abbreviation: "ASA").displayAbbreviation == "ASA")
    }

    @Test func displayAbbreviationFallsBackToTheFirstTwoCharactersOfTheName() throws {
        #expect(try makePillType(name: "Aspirin").displayAbbreviation == "As")
    }

    @Test func displayAbbreviationFallsBackToTheWholeNameWhenItIsShorter() throws {
        #expect(try makePillType(name: "D").displayAbbreviation == "D")
    }

    @Test func displayAbbreviationCountsCharactersNotUnicodeScalars() throws {
        #expect(try makePillType(name: "🇺🇦💊 Vitamins").displayAbbreviation == "🇺🇦💊")
    }

    @Test func setAbbreviationStoresBlankAsNotSet() throws {
        var pillType = try makePillType(abbreviation: "ASA")
        pillType.setAbbreviation("  ")
        #expect(pillType.abbreviation == nil)
        #expect(pillType.displayAbbreviation == "As")
    }
}
