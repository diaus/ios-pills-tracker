import Data
import Domain
import FactoryKit
import Foundation
import Observation

/// Lists every Pill Type ordered by creation date.
@MainActor @Observable
final class PillTypesListViewModel {
    @ObservationIgnored @Injected(\.pillTypeRepository) private var repository

    private(set) var pillTypes: [PillTypeAggregate] = []
    var errorMessage: String?

    func load() async {
        do {
            pillTypes = try await repository.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func observeChanges() async {
        for await _ in await repository.changes {
            await load()
        }
    }
}
