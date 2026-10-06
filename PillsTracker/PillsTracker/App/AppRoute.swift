import Foundation

/// Typed destinations pushed onto the app's `NavigationStack`.
enum AppRoute: Hashable {
    case pillTypes
    case blister(pillTypeID: UUID)
}
