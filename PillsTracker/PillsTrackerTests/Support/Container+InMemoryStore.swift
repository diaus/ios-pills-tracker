import Data
import Domain
import FactoryKit
import Utils

extension Container {
    /// Gives this test's container its own in-memory store, seeded with `aggregates`, and its own change notifier,
    /// and returns the repository for further seeding. Both are registered, because Factory's `.singleton` cache is
    /// global even under the `.container` trait: only a registration gives each test its own instance.
    @discardableResult
    func registerInMemoryStore(_ aggregates: [PillTypeAggregate] = []) async throws -> PillTypeRepositoryLive {
        let notifier = ChangeNotifier()
        let repository = PillTypeRepositoryLive(modelContainer: try PillsModelContainer.make(inMemory: true), notifier: notifier)
        dataChangeNotifier.register { notifier }
        pillTypeRepository.register { repository }
        for aggregate in aggregates {
            try await repository.create(aggregate)
        }
        return repository
    }
}
