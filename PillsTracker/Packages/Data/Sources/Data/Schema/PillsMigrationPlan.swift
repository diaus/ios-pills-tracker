import Domain
import Foundation
import SwiftData

/// Upgrades stores written by earlier app versions to the current schema.
public enum PillsMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] {
        [PillsSchemaV1.self, PillsSchemaV2.self, PillsSchemaV3.self]
    }

    public static var stages: [MigrationStage] {
        [v1ToV2, v2ToV3]
    }

    /// Adds Prescription Start Day and End Day. A Prescription from V1 never recorded when it was
    /// created, so it starts on its Pill Type's creation Day (ADR 0002) and stays open-ended.
    static let v1ToV2 = MigrationStage.custom(
        fromVersion: PillsSchemaV1.self,
        toVersion: PillsSchemaV2.self,
        willMigrate: nil,
        didMigrate: { context in
            for prescription in try context.fetch(FetchDescriptor<PillsSchemaV2.PrescriptionModel>())
            where prescription.startDayYear == nil {
                guard let createdAt = prescription.pillType?.createdAt else { continue }
                prescription.setDays(startDay: Day(date: createdAt, calendar: .current), endDay: nil)
            }
            try context.save()
        }
    )

    /// Adds the optional Pill Type Abbreviation; every Pill Type stored before it has none.
    static let v2ToV3 = MigrationStage.lightweight(fromVersion: PillsSchemaV2.self, toVersion: PillsSchemaV3.self)
}
