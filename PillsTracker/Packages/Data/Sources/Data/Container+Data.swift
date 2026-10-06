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
}
