import SwiftData

/// Second version of the persisted schema: Prescriptions gain a Start Day and an optional End Day.
/// Each `@Model` lives in its own file as a nested type of this enum, like `PillsSchemaV1`.
public enum PillsSchemaV2: VersionedSchema {
    public static let versionIdentifier = Schema.Version(2, 0, 0)

    public static var models: [any PersistentModel.Type] {
        [PillTypeModel.self, BlisterModel.self, PrescriptionModel.self, IntakeModel.self]
    }
}

/// Current-version aliases used by the rest of the Data package.
public typealias PillTypeModel = PillsSchemaV2.PillTypeModel
public typealias BlisterModel = PillsSchemaV2.BlisterModel
public typealias PrescriptionModel = PillsSchemaV2.PrescriptionModel
public typealias IntakeModel = PillsSchemaV2.IntakeModel
