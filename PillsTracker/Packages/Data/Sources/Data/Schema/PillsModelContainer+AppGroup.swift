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
}
