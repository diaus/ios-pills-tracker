import Foundation

/// Persistence boundary for Intakes.
public protocol IntakeRepository: Sendable {
    /// Every Intake recorded on `day`, optionally only those of one Pill Type.
    func fetch(day: Day, pillTypeID: UUID?) async throws -> [Intake]
    func fetch(id: UUID) async throws -> Intake?
    func create(_ intake: Intake) async throws
    func delete(id: UUID) async throws

    /// Fires after every write to any repository in the Data layer.
    var changes: AsyncStream<Void> { get async }
}
