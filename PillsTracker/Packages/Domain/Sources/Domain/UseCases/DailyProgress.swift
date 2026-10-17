import Foundation

/// Daily Progress: one `PillTypeProgress` per Pill Type for `day`, ordered by Pill Type creation date.
/// It carries the Done/Open state of the Prescription's Slots (that Day's Intakes intersected with the
/// Prescription) and the screen affordances; a Pill Type without a Prescription has no Slots, and a
/// Paused Prescription is reported Paused so the Home screen can list it separately.
public struct DailyProgress: Sendable {
    private let pillTypes: any PillTypeRepository
    private let intakes: any IntakeRepository

    public init(pillTypes: any PillTypeRepository, intakes: any IntakeRepository) {
        self.pillTypes = pillTypes
        self.intakes = intakes
    }

    public func callAsFunction(day: Day) async throws -> [PillTypeProgress] {
        let aggregates = try await pillTypes.fetchAll()
        let dayIntakes = try await intakes.fetch(day: day, pillTypeID: nil)
        return aggregates.map { PillTypeProgress(aggregate: $0, day: day, intakes: dayIntakes) }
    }

    /// Progress of one Pill Type, or nil when it does not exist.
    public func callAsFunction(pillTypeID: UUID, day: Day) async throws -> PillTypeProgress? {
        guard let aggregate = try await pillTypes.fetch(id: pillTypeID) else { return nil }
        let dayIntakes = try await intakes.fetch(day: day, pillTypeID: pillTypeID)
        return PillTypeProgress(aggregate: aggregate, day: day, intakes: dayIntakes)
    }
}
