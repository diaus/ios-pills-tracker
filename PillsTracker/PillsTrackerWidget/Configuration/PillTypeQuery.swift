import AppIntents
import Domain
import Foundation
import WidgetKit

/// The Pill Types the widget can be configured with: the picker suggests those with an Active Prescription,
/// in Home order, and a new widget picks the first one no placed widget shows yet.
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

    /// The first Active Pill Type not already configured in a placed widget, or nil when none is left.
    /// Best effort: iOS is reported to reuse the first answer for later widgets (FB15592256).
    func defaultResult() async -> PillTypeEntity? {
        let widgets = (try? await WidgetCenter.shared.currentConfigurations()) ?? []
        let placed = Set(widgets.filter { $0.kind == PillTypeWidget.kind }.compactMap {
            $0.widgetConfigurationIntent(of: PillTypeWidgetIntent.self)?.pillType?.id
        })
        guard let aggregates = try? await storedPillTypes() else { return nil }
        return PillTypeChoices.firstUnplaced(in: PillTypeChoices.active(in: aggregates), placed: placed).map(PillTypeEntity.init)
    }

    /// Every stored Pill Type in Home order; none while the app hasn't created the store.
    private func storedPillTypes() async throws -> [PillTypeAggregate] {
        try await WidgetStore.repository()?.fetchAll() ?? []
    }
}
