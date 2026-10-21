import SwiftData

/// Third version of the persisted schema: Pill Types gain an optional Abbreviation.
/// Each `@Model` lives in its own file as a nested type of this enum, like `PillsSchemaV1`.
public enum PillsSchemaV3: VersionedSchema {
    public static let versionIdentifier = Schema.Version(3, 0, 0)

    public static var models: [any PersistentModel.Type] {
        [PillTypeModel.self, BlisterModel.self, PrescriptionModel.self, IntakeModel.self]
    }
}

/// Current-version aliases used by the rest of the Data package.
public typealias PillTypeModel = PillsSchemaV3.PillTypeModel
public typealias BlisterModel = PillsSchemaV3.BlisterModel
public typealias PrescriptionModel = PillsSchemaV3.PrescriptionModel
public typealias IntakeModel = PillsSchemaV3.IntakeModel
