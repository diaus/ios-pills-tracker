import Domain

// Mapping between SwiftData models and Domain values. Models never leave the Data actor.
// Reading a row that no longer satisfies a Domain invariant throws `DataError.corruptRecord`
// instead of guessing a value.

extension DataError {
    /// Runs a Domain constructor over stored fields; a Domain error means the row is corrupt.
    static func record<T>(_ build: () throws(DomainError) -> T) throws(DataError) -> T {
        do {
            return try build()
        } catch {
            throw .corruptRecord
        }
    }

    /// Decodes a stored raw value; an unknown one means the row is corrupt.
    static func rawValue<T: RawRepresentable>(_ raw: T.RawValue) throws(DataError) -> T {
        guard let value = T(rawValue: raw) else { throw .corruptRecord }
        return value
    }
}
