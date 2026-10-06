import Data
import Domain
import FactoryKit

/// Domain use cases wired to the Data repositories.
extension Container {
    nonisolated var syncPosition: Factory<SyncPosition> {
        self { SyncPosition(repository: self.pillTypeRepository()) }
    }

    nonisolated var startNewBlister: Factory<StartNewBlister> {
        self { StartNewBlister(repository: self.pillTypeRepository()) }
    }
}
