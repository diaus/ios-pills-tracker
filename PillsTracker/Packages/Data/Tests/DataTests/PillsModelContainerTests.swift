import Testing
import SwiftData
@testable import Data

struct PillsModelContainerTests {
    @Test func inMemoryContainerUsesSchemaV1() throws {
        let container = try PillsModelContainer.make(inMemory: true)
        #expect(container.schema.version == PillsSchemaV1.versionIdentifier)
    }

    @Test func schemaV1ContainsPillTypeAndBlister() {
        let names = PillsSchemaV1.models.map { String(describing: $0) }
        #expect(names.contains("PillTypeModel"))
        #expect(names.contains("BlisterModel"))
    }
}
