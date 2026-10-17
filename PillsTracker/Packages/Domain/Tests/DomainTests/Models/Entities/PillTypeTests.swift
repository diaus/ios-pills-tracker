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

struct GridShapeTests {
    @Test(arguments: [0, 11]) func rowsOutsideOneToTenAreRejected(rows: Int) {
        #expect(throws: DomainError.invalidRows) { try GridShape(rows: rows, columns: 3) }
    }

    @Test(arguments: [0, 11]) func columnsOutsideOneToTenAreRejected(columns: Int) {
        #expect(throws: DomainError.invalidColumns) { try GridShape(rows: 3, columns: columns) }
    }

    @Test func boundaryShapesAreAccepted() throws {
        _ = try GridShape(rows: 1, columns: 1)
        _ = try GridShape(rows: 10, columns: 10)
    }

    @Test func allPositionsAreZeroBasedRowMajor() throws {
        let shape = try GridShape(rows: 2, columns: 3)
        #expect(shape.allPositions == [
            Position(row: 0, column: 0), Position(row: 0, column: 1), Position(row: 0, column: 2),
            Position(row: 1, column: 0), Position(row: 1, column: 1), Position(row: 1, column: 2),
        ])
    }
}
