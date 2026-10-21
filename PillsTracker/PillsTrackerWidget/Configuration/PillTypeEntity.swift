import AppIntents
import Domain
import Foundation

/// A Pill Type as the value of the widget's configuration parameter.
nonisolated struct PillTypeEntity: AppEntity {
    // App Intents metadata takes only a string literal here, not a catalog symbol.
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Pill Type")
    static let defaultQuery = PillTypeQuery()

    let id: UUID
    let name: String

    init(_ pillType: PillType) {
        id = pillType.id
        name = pillType.name
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}
