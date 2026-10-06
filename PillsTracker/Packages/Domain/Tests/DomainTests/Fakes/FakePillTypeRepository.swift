import Foundation
@testable import Domain

/// In-memory `PillTypeRepository` for Domain use case tests. Keeps insertion order like the live repository.
actor FakePillTypeRepository: PillTypeRepository {
    private var storage: [PillTypeAggregate]
    private let (stream, continuation) = AsyncStream<Void>.makeStream()

    init(_ aggregates: [PillTypeAggregate] = []) {
        storage = aggregates
    }

    var changes: AsyncStream<Void> { stream }

    func fetchAll() -> [PillTypeAggregate] {
        storage.sorted { $0.pillType.createdAt < $1.pillType.createdAt }
    }

    func fetch(id: UUID) -> PillTypeAggregate? {
        storage.first { $0.id == id }
    }

    func create(_ aggregate: PillTypeAggregate) {
        storage.append(aggregate)
        continuation.yield()
    }

    func update(_ aggregate: PillTypeAggregate) throws {
        guard let index = storage.firstIndex(where: { $0.id == aggregate.id }) else {
            throw FakeRepositoryError.notFound
        }
        storage[index] = aggregate
        continuation.yield()
    }

    func delete(id: UUID) {
        storage.removeAll { $0.id == id }
        continuation.yield()
    }
}

enum FakeRepositoryError: Error {
    case notFound
}
