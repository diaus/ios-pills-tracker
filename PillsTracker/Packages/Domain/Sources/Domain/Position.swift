/// One cell of a Blister's grid, addressed zero-based by row and column.
/// Nothing user-facing shows these indices.
public struct Position: Hashable, Sendable, Codable {
    public var row: Int
    public var column: Int

    public init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }
}
