import Foundation
import SwiftData
import Testing
import Domain
@testable import Data
import Utils

struct SchemaMigrationTests {
    @Test func aPrescriptionStoredBeforeStartDayExistedStartsOnItsPillTypesCreationDay() async throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "Pills.store")
        let pillTypeID = UUID()
        let createdAt = Date(timeIntervalSince1970: 1_790_000_000)
        try writeV1Store(at: url, pillTypeID: pillTypeID, createdAt: createdAt)

        let repository = PillTypeRepositoryLive(modelContainer: try PillsModelContainer.make(url: url), notifier: ChangeNotifier())
        let prescription = try #require(try await repository.fetch(id: pillTypeID)?.prescription)

        #expect(prescription.startDay == Day(date: createdAt, calendar: .current))
        #expect(prescription.endDay == nil)
        #expect(prescription.slots == [.morning, .evening])
    }

    /// A store as the version 1 app left it: one Pill Type with a Prescription.
    private func writeV1Store(at url: URL, pillTypeID: UUID, createdAt: Date) throws {
        let schema = Schema(versionedSchema: PillsSchemaV1.self)
        let container = try ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, url: url)])
        let context = ModelContext(container)
        let pillType = PillsSchemaV1.PillTypeModel(id: pillTypeID, name: "Aspirin", rows: 1, columns: 1, createdAt: createdAt)
        context.insert(pillType)
        pillType.prescription = PillsSchemaV1.PrescriptionModel(id: UUID(), slots: [.morning, .evening], state: PrescriptionState.active.rawValue)
        pillType.blisters = [
            PillsSchemaV1.BlisterModel(id: UUID(), rows: 1, columns: 1, state: BlisterState.current.rawValue, presentPositions: [Position(row: 0, column: 0)]),
        ]
        try context.save()
    }
}
