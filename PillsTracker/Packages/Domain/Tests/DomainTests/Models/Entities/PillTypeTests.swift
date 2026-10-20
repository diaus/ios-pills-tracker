import Foundation
import Testing
@testable import Domain

struct PillTypeTests {
    @Test func pillTypeRequiresANonEmptyName() {
        #expect(throws: DomainError.emptyName) {
            try PillType(name: "   ", shape: GridShape(rows: 2, columns: 5), createdAt: Date(timeIntervalSince1970: 0))
        }
    }

    @Test func pillTypeKeepsTrimmedName() throws {
        let pillType = try PillType(name: "  Aspirin ", shape: GridShape(rows: 2, columns: 5), createdAt: Date(timeIntervalSince1970: 0))
        #expect(pillType.name == "Aspirin")
    }
}
