import Foundation
import Testing
import Domain
@testable import Data

/// The widget extension reads the store the app writes, and never creates one of its own.
struct StoreReaderTests {
    private let root = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    private var store: URL { root.appending(path: "Group/Library/Application Support/default.store") }

    @Test func readsThePillTypesTheAppStored() async throws {
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: store.deletingLastPathComponent(), withIntermediateDirectories: true)
        let aggregate = try PillTypeAggregate.new(name: "Aspirin", rows: 1, columns: 2, createdAt: Date(timeIntervalSince1970: 1_000))
        try await PillTypeRepositoryLive(modelContainer: try PillsModelContainer.make(url: store)).create(aggregate)

        let container = try #require(try PillsModelContainer.makeReader(existingStoreAt: store))

        #expect(try await PillTypeRepositoryLive(modelContainer: container).fetchAll() == [aggregate])
    }

    @Test func opensNothingAndCreatesNoStoreWhileThereIsNone() throws {
        defer { try? FileManager.default.removeItem(at: root) }

        #expect(try PillsModelContainer.makeReader(existingStoreAt: store) == nil)
        #expect(!FileManager.default.fileExists(atPath: store.path(percentEncoded: false)))
    }
}
