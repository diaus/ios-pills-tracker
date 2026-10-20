import Foundation
@testable import Domain

/// In-memory `PillTypeRepository` for Domain use case tests. Keeps insertion order like the live repository.
actor FakePillTypeRepository: PillTypeRepository {
    private var storage: [PillTypeAggregate]
    /// Every stored Intake, for assertions.
    private(set) var allIntakes: [Intake]

    init(_ aggregates: [PillTypeAggregate] = [], intakes: [Intake] = []) {
        storage = aggregates
        allIntakes = intakes
    }

    func fetchAll() -> [PillTypeAggregate] {
        storage.sorted { $0.pillType.createdAt < $1.pillType.createdAt }
    }

    func fetch(id: UUID) -> PillTypeAggregate? {
        storage.first { $0.id == id }
    }

    func intakes(on day: Day, pillTypeID: UUID?) -> [Intake] {
        allIntakes.filter { $0.day == day && (pillTypeID == nil || $0.pillTypeID == pillTypeID) }
    }

    func intakes(blisterIDs: [UUID]) -> [Intake] {
        allIntakes.filter { blisterIDs.contains($0.blisterID) }.sorted { $0.instant < $1.instant }
    }

    func intake(id: UUID) -> Intake? {
        allIntakes.first { $0.id == id }
    }

    func create(_ aggregate: PillTypeAggregate) {
        storage.append(aggregate)
    }

    func update(_ aggregate: PillTypeAggregate) throws {
        guard let index = storage.firstIndex(where: { $0.id == aggregate.id }) else {
            throw FakeRepositoryError.notFound
        }
        storage[index] = aggregate
    }

    func update(_ aggregate: PillTypeAggregate, recording intake: Intake) throws {
        try update(aggregate)
        allIntakes.append(intake)
    }

    func update(_ aggregate: PillTypeAggregate, removing intake: Intake) throws {
        try update(aggregate)
        allIntakes.removeAll { $0.id == intake.id }
    }

    func delete(id: UUID) {
        storage.removeAll { $0.id == id }
        allIntakes.removeAll { $0.pillTypeID == id }
    }
}

enum FakeRepositoryError: Error {
    case notFound
}
