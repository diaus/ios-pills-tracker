import Foundation

/// Persistence boundary for the Pill Type aggregate (Pill Type with its Blisters; Prescription later).
public protocol PillTypeRepository: Sendable {
    /// Every aggregate ordered by Pill Type creation date, oldest first.
    func fetchAll() async throws -> [PillTypeAggregate]
    func fetch(id: UUID) async throws -> PillTypeAggregate?
    func create(_ aggregate: PillTypeAggregate) async throws
    /// Replaces the stored aggregate (Pill Type fields and Blisters) with `aggregate`.
    func update(_ aggregate: PillTypeAggregate) async throws
    func delete(id: UUID) async throws

    /// Fires after every write to any repository in the Data layer.
    var changes: AsyncStream<Void> { get }
}
