import Foundation
import Testing
@testable import Data

struct StoreMoveTests {
    private let root = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    private var oldStore: URL { root.appending(path: "Application Support/default.store") }
    private var newStore: URL { root.appending(path: "Group/Library/Application Support/default.store") }

    @Test func movesTheStoreWithItsWALAndSHMFilesIntoTheAppGroup() throws {
        defer { try? FileManager.default.removeItem(at: root) }
        try write("store", to: oldStore)
        try write("wal", to: sidecar(oldStore, "-wal"))
        try write("shm", to: sidecar(oldStore, "-shm"))

        try PillsStoreLocation.moveStore(from: oldStore, to: newStore)

        #expect(try read(newStore) == "store")
        #expect(try read(sidecar(newStore, "-wal")) == "wal")
        #expect(try read(sidecar(newStore, "-shm")) == "shm")
        #expect(!exists(oldStore))
        #expect(!exists(sidecar(oldStore, "-wal")))
        #expect(!exists(sidecar(oldStore, "-shm")))
    }

    @Test func movesAStoreThatHasNoWALOrSHMFile() throws {
        defer { try? FileManager.default.removeItem(at: root) }
        try write("store", to: oldStore)

        try PillsStoreLocation.moveStore(from: oldStore, to: newStore)

        #expect(try read(newStore) == "store")
        #expect(!exists(oldStore))
    }

    @Test func doesNothingWhenThereIsNoOldStore() throws {
        defer { try? FileManager.default.removeItem(at: root) }

        try PillsStoreLocation.moveStore(from: oldStore, to: newStore)

        #expect(!exists(newStore))
    }

    @Test func leavesBothStoresAloneWhenTheAppGroupAlreadyHasOne() throws {
        defer { try? FileManager.default.removeItem(at: root) }
        try write("old store", to: oldStore)
        try write("old wal", to: sidecar(oldStore, "-wal"))
        try write("new store", to: newStore)

        try PillsStoreLocation.moveStore(from: oldStore, to: newStore)

        #expect(try read(newStore) == "new store")
        #expect(!exists(sidecar(newStore, "-wal")))
        #expect(try read(oldStore) == "old store")
        #expect(try read(sidecar(oldStore, "-wal")) == "old wal")
    }

    private func sidecar(_ store: URL, _ suffix: String) -> URL {
        store.deletingLastPathComponent().appending(path: store.lastPathComponent + suffix)
    }

    private func write(_ contents: String, to url: URL) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(contents.utf8).write(to: url)
    }

    private func read(_ url: URL) throws -> String {
        String(decoding: try Data(contentsOf: url), as: UTF8.self)
    }

    private func exists(_ url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path(percentEncoded: false))
    }
}
