import Data
import Domain
import FactoryKit
import Foundation
import Observation

/// Shows one Pill Type's Current Blister. Read-only in this ticket.
@MainActor @Observable
final class BlisterViewModel {
    @ObservationIgnored @Injected(\.pillTypeRepository) private var repository

    let pillTypeID: UUID
    private(set) var pillType: PillType?
    private(set) var currentBlister: Blister?
    private(set) var hasLoaded = false
    var errorMessage: String?

    init(pillTypeID: UUID) {
        self.pillTypeID = pillTypeID
    }

    var presentCount: Int { currentBlister?.presentPositions.count ?? 0 }

    func load() async {
        do {
            let aggregate = try await repository.fetch(id: pillTypeID)
            pillType = aggregate?.pillType
            currentBlister = aggregate?.currentBlister
        } catch {
            errorMessage = error.localizedDescription
        }
        hasLoaded = true
    }

    func observeChanges() async {
        for await _ in await repository.changes {
            await load()
        }
    }
}
