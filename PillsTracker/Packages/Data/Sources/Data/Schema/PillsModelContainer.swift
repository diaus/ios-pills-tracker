import Foundation
import SwiftData

/// Builds the app's `ModelContainer` for the current schema version, migrating older stores.
public enum PillsModelContainer {
    /// The current schema version, which every container opens the store with.
    static let schema = Schema(versionedSchema: PillsSchemaV3.self)

    public static func make(inMemory: Bool) throws -> ModelContainer {
        try make(configuration: ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory))
    }

    /// The container for the store at `url`, so tests can open a store an earlier version wrote.
    static func make(url: URL) throws -> ModelContainer {
        try make(configuration: ModelConfiguration(schema: schema, url: url))
    }

    static func make(configuration: ModelConfiguration) throws -> ModelContainer {
        try ModelContainer(for: schema, migrationPlan: PillsMigrationPlan.self, configurations: [configuration])
    }
}
