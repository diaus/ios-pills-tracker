import Data
import Domain
import FactoryKit
import Foundation
import Observation

/// Drives the Home screen. Later tickets add Daily Progress loading here.
@MainActor @Observable
final class HomeViewModel {
    @ObservationIgnored @Injected(\.pillTypeRepository) private var repository

    private(set) var pillTypeCount = 0
    private(set) var hasLoaded = false
    var errorMessage: String?

    /// True while the user has no Pill Types yet.
    var isEmpty: Bool { hasLoaded && pillTypeCount == 0 }

    func load() async {
        do {
            pillTypeCount = try await repository.fetchAll().count
        } catch {
            errorMessage = error.localizedDescription
        }
        hasLoaded = true
    }

    /// Reloads after every write; runs until the owning view's task is cancelled.
    func observeChanges() async {
        for await _ in await repository.changes {
            await load()
        }
    }
}
