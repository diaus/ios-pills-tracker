import Domain
import Foundation

/// A `PillTypeRepository` for SwiftUI previews: sample Pill Types and Intakes held in memory and edited in place,
/// so a preview is interactive, or a store that never loads or always fails, so a preview can show those states.
actor PreviewPillTypeRepository: PillTypeRepository {
    enum Behaviour {
        case loaded
        case neverLoads
        case fails
    }

    struct Failure: Error {}

    private let behaviour: Behaviour
    private var aggregates: [PillTypeAggregate]
    private var intakes: [Intake]

    /// The Pill Types of `progress` with their Current Blister's Intakes, as `PillTypeProgress.previewAll` holds them.
    init(_ progress: [PillTypeProgress] = [], behaviour: Behaviour = .loaded) {
        self.behaviour = behaviour
        aggregates = progress.map(\.aggregate)
        intakes = progress.flatMap(\.blisterIntakes)
    }

    static var neverLoads: PreviewPillTypeRepository { PreviewPillTypeRepository(behaviour: .neverLoads) }
    static var fails: PreviewPillTypeRepository { PreviewPillTypeRepository(behaviour: .fails) }

    func fetchAll() async throws -> [PillTypeAggregate] {
        try await read()
        return aggregates
    }

    func fetch(id: UUID) async throws -> PillTypeAggregate? {
        try await read()
        return aggregates.first { $0.id == id }
    }

    func intakes(on day: Day, pillTypeID: UUID?) async throws -> [Intake] {
        try await read()
        return intakes.filter { $0.day == day && (pillTypeID == nil || $0.pillTypeID == pillTypeID) }
    }

    func intakes(blisterIDs: [UUID]) async throws -> [Intake] {
        try await read()
        return intakes.filter { blisterIDs.contains($0.blisterID) }
    }

    func intakes(pillTypeID: UUID, days: ClosedRange<Day>) async throws -> [Intake] {
        try await read()
        return intakes.filter { $0.pillTypeID == pillTypeID && days.contains($0.day) }
    }

    func intake(id: UUID) async throws -> Intake? {
        try await read()
        return intakes.first { $0.id == id }
    }

    func create(_ aggregate: PillTypeAggregate) {
        aggregates.append(aggregate)
    }

    func update(_ aggregate: PillTypeAggregate) {
        if let index = aggregates.firstIndex(where: { $0.id == aggregate.id }) {
            aggregates[index] = aggregate
        }
    }

    func update(_ aggregate: PillTypeAggregate, recording intake: Intake) {
        update(aggregate)
        intakes.append(intake)
    }

    func update(_ aggregate: PillTypeAggregate, removing intake: Intake) {
        update(aggregate)
        intakes.removeAll { $0.id == intake.id }
    }

    func delete(id: UUID) {
        aggregates.removeAll { $0.id == id }
        intakes.removeAll { $0.pillTypeID == id }
    }

    /// Returns at once when loaded, waits for as long as a preview lasts when it never loads, or throws.
    private func read() async throws {
        switch behaviour {
        case .loaded: return
        case .neverLoads: try await Task.sleep(for: .seconds(24 * 60 * 60))
        case .fails: throw Failure()
        }
    }
}
