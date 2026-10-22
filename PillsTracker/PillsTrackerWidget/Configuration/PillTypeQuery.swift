import AppIntents
import Domain
import Foundation

/// The Pill Types the widget can be configured with: the picker suggests those with an Active Prescription,
/// in Home order, and a new widget picks the first of them.
nonisolated struct PillTypeQuery: EntityQuery {
    /// Any stored Pill Type, Active or not, so a widget whose Prescription is Paused or removed keeps its
    /// configuration. A deleted Pill Type isn't found, and the widget shows the empty state.
    func entities(for identifiers: [PillTypeEntity.ID]) async throws -> [PillTypeEntity] {
        try await storedPillTypes()
            .filter { identifiers.contains($0.id) }
            .map { PillTypeEntity($0.pillType) }
    }

    func suggestedEntities() async throws -> [PillTypeEntity] {
        PillTypeChoices.active(in: try await storedPillTypes()).map(PillTypeEntity.init)
    }

    /// The first Active Pill Type, or nil when there is none.
    /// It doesn't skip Pill Types that placed widgets already show: reading their configurations through
    /// `WidgetCenter` rebuilds each intent, and an intent without a Pill Type asks for this default again. That
    /// loop got the extension killed for memory on device.
    func defaultResult() async -> PillTypeEntity? {
        guard let aggregates = try? await storedPillTypes() else { return nil }
        return PillTypeChoices.active(in: aggregates).first.map(PillTypeEntity.init)
    }

    /// Every stored Pill Type in Home order; none while the app hasn't created the store.
    private func storedPillTypes() async throws -> [PillTypeAggregate] {
        try await WidgetStore.repository()?.fetchAll() ?? []
    }
}
