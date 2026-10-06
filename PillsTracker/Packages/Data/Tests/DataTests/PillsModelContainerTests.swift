import Testing
import SwiftData
@testable import Data

struct PillsModelContainerTests {
    @Test func inMemoryContainerUsesSchemaV1() throws {
        let container = try PillsModelContainer.make(inMemory: true)
        #expect(container.schema.version == PillsSchemaV1.versionIdentifier)
    }
}
