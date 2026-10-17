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

    nonisolated var consume: Factory<Consume> {
        self { Consume(repository: self.pillTypeRepository()) }
    }

    nonisolated var undo: Factory<Undo> {
        self { Undo(repository: self.pillTypeRepository()) }
    }

    nonisolated var updatePillType: Factory<UpdatePillType> {
        self { UpdatePillType(repository: self.pillTypeRepository()) }
    }

    nonisolated var dailyProgress: Factory<DailyProgress> {
        self { DailyProgress(repository: self.pillTypeRepository()) }
    }
}
