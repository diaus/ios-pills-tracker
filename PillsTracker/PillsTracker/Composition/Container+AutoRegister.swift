import Data
import FactoryKit
import WidgetKit

/// Registrations Factory runs once, before the first resolve on the container. That is earlier than any
/// `App.init()`: `@Injected` properties and `@State` initial values resolve the repository before it runs.
///
/// The conformance is `nonisolated` so the cast Factory does on whatever thread resolves first always succeeds.
extension Container: @retroactive nonisolated AutoRegistering {
    public nonisolated func autoRegister() {
        // The widget can't observe the store, so every save reloads its timelines (ADR 0003).
        afterStoreSave.register { { WidgetCenter.shared.reloadAllTimelines() } }
    }
}
