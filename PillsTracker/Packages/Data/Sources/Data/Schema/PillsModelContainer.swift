import Foundation
import SwiftData

/// Builds the app's `ModelContainer` for the current schema version, migrating older stores.
public enum PillsModelContainer {
    public static func make(inMemory: Bool) throws -> ModelContainer {
        let schema = Schema(versionedSchema: PillsSchemaV3.self)
        return try make(schema: schema, configuration: ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory))
    }

    /// The container for the store at `url`, so tests can open a store an earlier version wrote.
    static func make(url: URL) throws -> ModelContainer {
        let schema = Schema(versionedSchema: PillsSchemaV3.self)
        return try make(schema: schema, configuration: ModelConfiguration(schema: schema, url: url))
    }

    private static func make(schema: Schema, configuration: ModelConfiguration) throws -> ModelContainer {
        try ModelContainer(for: schema, migrationPlan: PillsMigrationPlan.self, configurations: [configuration])
    }
}
