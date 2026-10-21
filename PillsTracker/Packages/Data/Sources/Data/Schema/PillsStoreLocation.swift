import Foundation
import SwiftData

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
    /// `newURL`'s folder must exist.
    static func moveStore(from oldURL: URL, to newURL: URL) throws {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: oldURL.path(percentEncoded: false)),
              !fileManager.fileExists(atPath: newURL.path(percentEncoded: false)) else { return }
        // The store goes last: if a move is cut short, the App Group still has no store, and the next launch finishes it.
        for suffix in ["-wal", "-shm", ""] {
            let oldFile = file(oldURL, suffix)
            guard fileManager.fileExists(atPath: oldFile.path(percentEncoded: false)) else { continue }
            try fileManager.moveItem(at: oldFile, to: file(newURL, suffix))
        }
    }

    /// The file next to `store` whose name adds `suffix`, such as its `-wal` file.
    static func file(_ store: URL, _ suffix: String) -> URL {
        store.deletingLastPathComponent().appending(path: store.lastPathComponent + suffix)
    }
}
