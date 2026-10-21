import Data
import Domain

/// The widget's read access to the App Group store the app writes (ADR 0003).
enum WidgetStore {
    /// A fresh read-only repository, opened once per timeline, snapshot or query, so a long-lived widget process
    /// sees the app's latest save rather than objects an earlier read left in its context. nil until the app
    /// has created the store.
    nonisolated static func repository() throws -> (any PillTypeRepository)? {
        try PillsModelContainer.makeReaderInAppGroup().map { PillTypeRepositoryLive(modelContainer: $0) }
    }
}
