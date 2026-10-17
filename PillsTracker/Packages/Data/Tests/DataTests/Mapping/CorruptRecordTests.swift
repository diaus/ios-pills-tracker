import Foundation
import SwiftData
import Testing
import Domain
@testable import Data
import Utils

/// A stored row that no longer satisfies a Domain invariant is reported, never silently repaired.
struct CorruptRecordTests {
    private let container: ModelContainer
    private let pillTypes: PillTypeRepositoryLive
    private let pillTypeID = UUID()

    init() throws {
        container = try PillsModelContainer.make(inMemory: true)
        pillTypes = PillTypeRepositoryLive(modelContainer: container, notifier: ChangeNotifier())
    }

    /// Inserts a Pill Type row directly, with `configure` adding the corrupt child rows.
    private func seed(_ configure: (PillTypeModel, ModelContext) -> Void) throws {
        let context = ModelContext(container)
        let pillType = PillTypeModel(id: pillTypeID, name: "Aspirin", rows: 1, columns: 2, createdAt: Date(timeIntervalSince1970: 1_000))
        context.insert(pillType)
        configure(pillType, context)
        try context.save()
    }

    @Test func aBlisterWithAnUnknownStateIsCorrupt() async throws {
        try seed { pillType, _ in
            pillType.blisters = [BlisterModel(id: UUID(), rows: 1, columns: 2, state: "bogus", presentPositions: [])]
        }
        await #expect(throws: DataError.corruptRecord) { try await pillTypes.fetch(id: pillTypeID) }
        await #expect(throws: DataError.corruptRecord) { try await pillTypes.fetchAll() }
    }

    @Test func aBlisterWithAnInvalidShapeIsCorrupt() async throws {
        try seed { pillType, _ in
            pillType.blisters = [BlisterModel(id: UUID(), rows: 11, columns: 2, state: "current", presentPositions: [])]
        }
        await #expect(throws: DataError.corruptRecord) { try await pillTypes.fetch(id: pillTypeID) }
    }

    @Test func aPrescriptionWithAnUnknownStateIsCorrupt() async throws {
        try seed { pillType, _ in
            pillType.prescription = PrescriptionModel(id: UUID(), slots: [.morning], state: "bogus")
        }
        await #expect(throws: DataError.corruptRecord) { try await pillTypes.fetch(id: pillTypeID) }
    }

    @Test func aPillTypeWithAnEmptyNameIsCorrupt() async throws {
        try seed { pillType, _ in pillType.name = " " }
        await #expect(throws: DataError.corruptRecord) { try await pillTypes.fetch(id: pillTypeID) }
    }

    @Test func anIntakeWithAnUnknownSlotIsCorrupt() async throws {
        let intakeID = UUID()
        try seed { pillType, context in
            let intake = IntakeModel(id: intakeID, pillTypeID: pillTypeID, blisterID: UUID(), position: Position(row: 0, column: 0), slot: "bogus", dayYear: 2026, dayMonth: 10, dayDay: 6, instant: Date(timeIntervalSince1970: 1_000))
            context.insert(intake)
            intake.pillType = pillType
        }
        await #expect(throws: DataError.corruptRecord) { try await pillTypes.intake(id: intakeID) }
        await #expect(throws: DataError.corruptRecord) { try await pillTypes.intakes(on: Day(year: 2026, month: 10, day: 6), pillTypeID: nil) }
    }
}
