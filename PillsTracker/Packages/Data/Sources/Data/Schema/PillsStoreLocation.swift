import Foundation
import SwiftData

public extension PillsModelContainer {
    /// The on-disk container the app and the widget extension share: the store in the App Group container (ADR 0003).
    /// A store an earlier build left in Application Support is moved there first, so its data carries over.
    static func makeInAppGroup() throws -> ModelContainer {
        let storeURL = try PillsStoreLocation.appGroupStoreURL()
        try FileManager.default.createDirectory(at: storeURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try PillsStoreLocation.moveStore(from: PillsStoreLocation.applicationSupportStoreURL, to: storeURL)
        return try make(url: storeURL)
    }

    /// The App Group store opened read-only, for the widget extension, or nil while the app hasn't created it.
    /// Only the app creates the store: an empty one a reader created first would win over the store the app
    /// still has to move out of Application Support. The widget's own sandbox has no old store to move.
    static func makeReaderInAppGroup() throws -> ModelContainer? {
        try makeReader(existingStoreAt: PillsStoreLocation.appGroupStoreURL())
    }

    /// The store at `url` opened read-only, or nil when there is none, in which case nothing is created.
    internal static func makeReader(existingStoreAt url: URL) throws -> ModelContainer? {
        guard FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) else { return nil }
        return try make(configuration: ModelConfiguration(schema: schema, url: url, allowsSave: false))
    }
}

/// Where the on-disk store lives: the App Group container the app and the widget extension share (ADR 0003).
public enum PillsStoreLocation {
    /// The App Group the app and the widget extension share. Each target's `.entitlements` file lists this same identifier.
    public static let appGroupIdentifier = "group.com.andrew.PillsTracker"

    /// The process isn't entitled to the App Group, so it has no container to open the store in.
    struct AppGroupUnavailable: Error {
        let identifier: String
    }

    /// SwiftData's default store name, kept so the store has the same file name in both places.
    private static let storeFileName = "default.store"

    /// Where the store lived before the App Group: SwiftData's default location in the app's own Application Support.
    /// Spelled out, because once the app has an App Group entitlement, SwiftData's default moves into the group.
    static var applicationSupportStoreURL: URL {
        URL.applicationSupportDirectory.appending(path: storeFileName)
    }

    /// The store in the App Group container, at the path SwiftData itself would pick there.
    static func appGroupStoreURL() throws -> URL {
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            throw AppGroupUnavailable(identifier: appGroupIdentifier)
        }
        return container.appending(path: "Library/Application Support").appending(path: storeFileName)
    }

    /// Moves the store at `oldURL`, with its `-wal` and `-shm` files, to `newURL`. Does nothing when there is
    /// no store at `oldURL`, or already one at `newURL`: then the store at `newURL` wins and the old one is left alone.
    static func moveStore(from oldURL: URL, to newURL: URL) throws {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: oldURL.path(percentEncoded: false)),
              !fileManager.fileExists(atPath: newURL.path(percentEncoded: false)) else { return }
        try fileManager.createDirectory(at: newURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        // The store goes last: if a move is cut short, the App Group still has no store, and the next launch finishes it.
        for suffix in ["-wal", "-shm", ""] {
            let oldFile = file(oldURL, suffix)
            guard fileManager.fileExists(atPath: oldFile.path(percentEncoded: false)) else { continue }
            try fileManager.moveItem(at: oldFile, to: file(newURL, suffix))
        }
    }

    private static func file(_ store: URL, _ suffix: String) -> URL {
        store.deletingLastPathComponent().appending(path: store.lastPathComponent + suffix)
    }
}
