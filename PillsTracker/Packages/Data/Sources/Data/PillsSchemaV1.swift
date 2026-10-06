import SwiftData

/// First version of the persisted schema. Models are added by later tickets.
public enum PillsSchemaV1: VersionedSchema {
    public static let versionIdentifier = Schema.Version(1, 0, 0)

    public static var models: [any PersistentModel.Type] { [] }
}
