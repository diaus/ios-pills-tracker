import Domain
import FactoryKit
import SwiftData

public extension Container {
    /// The single on-disk `ModelContainer` shared by every repository.
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

    /// Shared change broadcaster every repository notifies after a write.
    var dataChangeNotifier: Factory<DataChangeNotifier> {
        self { DataChangeNotifier() }.singleton
    }

    var pillTypeRepository: Factory<any PillTypeRepository> {
        self { PillTypeRepositoryLive(modelContainer: self.modelContainer(), notifier: self.dataChangeNotifier()) }
            .singleton
    }
}
