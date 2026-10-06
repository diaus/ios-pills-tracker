import Observation

/// Drives the Home screen. Later tickets add Daily Progress loading here.
@MainActor @Observable
final class HomeViewModel {
    /// True while the user has no Pill Types yet.
    var isEmpty: Bool { true }
}
