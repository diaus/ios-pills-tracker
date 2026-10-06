import Data
import Domain
import FactoryKit
import Foundation
import Observation
import SwiftUI

/// Shows one Pill Type's Current Blister and lets the user keep it in sync with reality.
@MainActor @Observable
final class BlisterViewModel {
    @ObservationIgnored @Injected(\.pillTypeRepository) private var repository
    @ObservationIgnored @Injected(\.syncPosition) private var syncPosition
    @ObservationIgnored @Injected(\.startNewBlister) private var startNewBlister

    let pillTypeID: UUID
    private(set) var pillType: PillType?
    private(set) var currentBlister: Blister?
    private(set) var hasLoaded = false
    var errorMessage: LocalizedStringKey?

    init(pillTypeID: UUID) {
        self.pillTypeID = pillTypeID
    }

    var presentCount: Int { currentBlister?.presentPositions.count ?? 0 }

    /// Start New Blister is offered only once every Position is Empty.
    var canStartNewBlister: Bool { currentBlister?.isEmpty ?? false }

    func load() async {
        do {
            let aggregate = try await repository.fetch(id: pillTypeID)
            pillType = aggregate?.pillType
            currentBlister = aggregate?.currentBlister
        } catch {
            errorMessage = error.userMessage
        }
        hasLoaded = true
    }

    func observeChanges() async {
        for await _ in await repository.changes {
            await load()
        }
    }

    /// Sync Edit: sets `position` Present or Empty on the Current Blister.
    func setPosition(_ position: Position, isPresent: Bool) async {
        await perform { try await syncPosition(pillTypeID: pillTypeID, position: position, isPresent: isPresent) }
    }

    func startNewBlister() async {
        await perform { try await startNewBlister(pillTypeID: pillTypeID) }
    }

    private func perform(_ action: () async throws -> Void) async {
        do {
            try await action()
            await load()
        } catch {
            errorMessage = error.userMessage
        }
    }
}
