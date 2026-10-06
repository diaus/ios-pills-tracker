/// The rectangular layout of a Pill Type's Blisters. Rows and columns are each 1…10.
public struct GridShape: Hashable, Sendable, Codable {
    public static let allowedRange = 1...10

    public let rows: Int
    public let columns: Int

    public init(rows: Int, columns: Int) throws(DomainError) {
        guard Self.allowedRange.contains(rows) else { throw .invalidRows }
        guard Self.allowedRange.contains(columns) else { throw .invalidColumns }
        self.rows = rows
        self.columns = columns
    }

    /// Every Position of the grid, row-major.
    public var allPositions: [Position] {
        (0..<rows).flatMap { row in (0..<columns).map { Position(row: row, column: $0) } }
    }

    public var positionCount: Int { rows * columns }
}
