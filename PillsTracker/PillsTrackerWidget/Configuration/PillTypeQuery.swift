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
        guard let repository = try WidgetStore.repository() else { return [] }
        return try await repository.fetchAll()
            .filter { identifiers.contains($0.id) }
            .map { PillTypeEntity($0.pillType) }
    }

    func suggestedEntities() async throws -> [PillTypeEntity] {
        try await activePillTypes()
    }

    /// The first Active Pill Type not already configured in a placed widget, or nil when none is left.
    func defaultResult() async -> PillTypeEntity? {
        let placed = (try? await WidgetCenter.shared.currentConfigurations()) ?? []
        let configured = Set(placed.compactMap { $0.widgetConfigurationIntent(of: PillTypeWidgetIntent.self)?.pillType?.id })
        return try? await activePillTypes().first { !configured.contains($0.id) }
    }

    /// Pill Types with an Active Prescription, in Home order: oldest first.
    private func activePillTypes() async throws -> [PillTypeEntity] {
        guard let repository = try WidgetStore.repository() else { return [] }
        return try await repository.fetchAll()
            .filter { $0.prescription?.state == .active }
            .map { PillTypeEntity($0.pillType) }
    }
}
