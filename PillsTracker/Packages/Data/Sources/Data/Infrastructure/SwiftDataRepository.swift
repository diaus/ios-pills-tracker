import Foundation
import SwiftData

/// Plumbing shared by the SwiftData repositories: a one-row fetch and save-then-notify.
/// Members of this extension run on the conforming actor.
protocol SwiftDataRepository: ModelActor {
    /// Shared change broadcaster, notified after every write.
    var notifier: DataChangeNotifier { get }
}

extension SwiftDataRepository {
    /// The first model matching `predicate`, or nil.
    func first<T: PersistentModel>(matching predicate: Predicate<T>) throws -> T? {
        var descriptor = FetchDescriptor<T>(predicate: predicate)
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    func saveAndNotify() throws {
        try modelContext.save()
        notifier.notify()
    }
}
