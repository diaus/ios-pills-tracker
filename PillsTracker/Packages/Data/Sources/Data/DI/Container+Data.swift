import Domain
import FactoryKit
import SwiftData
import Utils

public extension Container {
    /// The single on-disk `ModelContainer`, in the App Group the widget extension shares.
    var modelContainer: Factory<ModelContainer> {
        self {
            do {
                return try PillsModelContainer.makeInAppGroup()
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

    /// Runs after every successful repository save, in another process's interest: the app registers a reload
    /// of the widget's timelines here before anything resolves, so Data never imports WidgetKit (ADR 0003).
    var afterStoreSave: Factory<@Sendable () -> Void> {
        self { {} }
    }

    var pillTypeRepository: Factory<any PillTypeRepository> {
        self {
            PillTypeRepositoryLive(
                modelContainer: self.modelContainer(),
                notifier: self.dataChangeNotifier(),
                afterStoreSave: self.afterStoreSave()
            )
        }
        .singleton
    }
}
