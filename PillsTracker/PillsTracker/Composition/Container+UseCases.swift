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
        self { Consume(pillTypes: self.pillTypeRepository(), intakes: self.intakeRepository()) }
    }

    nonisolated var undo: Factory<Undo> {
        self { Undo(pillTypes: self.pillTypeRepository(), intakes: self.intakeRepository()) }
    }

    nonisolated var dailyProgress: Factory<DailyProgress> {
        self { DailyProgress(pillTypes: self.pillTypeRepository(), intakes: self.intakeRepository()) }
    }
}
