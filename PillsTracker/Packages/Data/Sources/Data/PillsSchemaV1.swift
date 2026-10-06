import SwiftData

/// First version of the persisted schema. Each `@Model` lives in its own file
/// as a nested type of this enum so later schema versions can evolve independently.
public enum PillsSchemaV1: VersionedSchema {
    public static let versionIdentifier = Schema.Version(1, 0, 0)

    public static var models: [any PersistentModel.Type] {
        [PillTypeModel.self, BlisterModel.self]
    }
}

/// Current-version aliases used by the rest of the Data package.
public typealias PillTypeModel = PillsSchemaV1.PillTypeModel
public typealias BlisterModel = PillsSchemaV1.BlisterModel
