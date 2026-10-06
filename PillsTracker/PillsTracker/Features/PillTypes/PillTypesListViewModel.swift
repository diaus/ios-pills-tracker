import Data
import Domain
import FactoryKit
import Foundation
import Observation
import SwiftUI

/// Lists every Pill Type ordered by creation date.
@MainActor @Observable
final class PillTypesListViewModel {
    @ObservationIgnored @Injected(\.pillTypeRepository) private var repository

    private(set) var pillTypes: [PillTypeAggregate] = []
    var errorMessage: LocalizedStringKey?

    func load() async {
        do {
            pillTypes = try await repository.fetchAll()
        } catch {
            errorMessage = error.userMessage
        }
    }

    func observeChanges() async {
        for await _ in await repository.changes {
            await load()
        }
    }
}
