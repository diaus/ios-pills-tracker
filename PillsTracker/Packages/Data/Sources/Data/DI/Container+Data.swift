import Domain
import FactoryKit
import SwiftData
import Utils

public extension Container {
    /// The single on-disk `ModelContainer`.
    var modelContainer: Factory<ModelContainer> {
        self {
            do {
                return try PillsModelContainer.make()
            } catch {
                fatalError("Could not create the ModelContainer: \(error)")
            }
        }
        .singleton
    }

    /// Change broadcaster the repository notifies after every write; screens observe it to reload.
    var dataChangeNotifier: Factory<ChangeNotifier> {
        self { ChangeNotifier() }.singleton
    }

    var pillTypeRepository: Factory<any PillTypeRepository> {
        self { PillTypeRepositoryLive(modelContainer: self.modelContainer(), notifier: self.dataChangeNotifier()) }
            .singleton
    }
}
