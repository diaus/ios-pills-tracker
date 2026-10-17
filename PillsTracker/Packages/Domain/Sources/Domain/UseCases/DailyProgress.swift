import Foundation

/// Daily Progress: one `PillTypeProgress` per Pill Type for `day`, ordered by Pill Type creation date.
/// It carries the Done/Open state of the Prescription's Slots (that Day's Intakes intersected with the
/// Prescription) and the screen affordances; a Pill Type without a Prescription has no Slots, and a
/// Paused Prescription is reported Paused so the Home screen can list it separately.
public struct DailyProgress: Sendable {
    private let repository: any PillTypeRepository

    public init(repository: any PillTypeRepository) {
        self.repository = repository
    }

    public func callAsFunction(day: Day) async throws -> [PillTypeProgress] {
        let aggregates = try await repository.fetchAll()
        let dayIntakes = try await repository.intakes(on: day, pillTypeID: nil)
        return aggregates.map { PillTypeProgress(aggregate: $0, day: day, intakes: dayIntakes) }
    }
}
