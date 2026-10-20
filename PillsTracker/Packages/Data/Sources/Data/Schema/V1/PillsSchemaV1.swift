import SwiftData

/// First version of the persisted schema, before Prescriptions had a Start Day and End Day. Frozen:
/// it only describes stores written by that version so `PillsMigrationPlan` can upgrade them. Each `@Model` lives in its own file
/// as a nested type of this enum so later schema versions can evolve independently.
public enum PillsSchemaV1: VersionedSchema {
    public static let versionIdentifier = Schema.Version(1, 0, 0)

    public static var models: [any PersistentModel.Type] {
        [PillTypeModel.self, BlisterModel.self, PrescriptionModel.self, IntakeModel.self]
    }
}
