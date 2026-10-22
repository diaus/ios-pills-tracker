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

    /// The store at `url` opened read-only, or nil when there is none, in which case nothing is created.
    static func makeReader(existingStoreAt url: URL) throws -> ModelContainer? {
        guard FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) else { return nil }
        return try make(configuration: ModelConfiguration(schema: schema, url: url, allowsSave: false))
    }

    static func make(configuration: ModelConfiguration) throws -> ModelContainer {
        try ModelContainer(for: schema, migrationPlan: PillsMigrationPlan.self, configurations: [configuration])
    }
}
