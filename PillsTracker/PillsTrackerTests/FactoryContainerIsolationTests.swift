import Data
import FactoryKit
import FactoryTesting
import Foundation
import Testing
@testable import PillsTracker

/// What the view-model tests rely on: after `registerInMemoryStore`, a test's repository and change notifier are
/// its own, so a write in one test never reloads another test's model. The `.container` trait alone doesn't give
/// that: Factory's `.singleton` cache is global, and only a registration resets it.
@Suite(.container, .serialized)
struct FactoryContainerIsolationTests {
    /// The singletons every test of this suite has resolved so far; the second test to run checks its own are new.
    private static let resolved = ResolvedSingletons()

    @Test func aRegisteredStoreAndNotifierAreThisTestsOwnAndResolveOnce() async throws {
        try await Container.shared.registerInMemoryStore()

        let notifier = Container.shared.dataChangeNotifier()
        let repository = Container.shared.pillTypeRepository()

        #expect(Container.shared.dataChangeNotifier() === notifier)
        #expect(Container.shared.pillTypeRepository() as AnyObject === repository as AnyObject)
        #expect(Self.resolved.insert(ObjectIdentifier(notifier)), "the notifier was already resolved by another test")
        #expect(Self.resolved.insert(ObjectIdentifier(repository as AnyObject)), "the repository was already resolved by another test")
    }

    @Test func theSameHoldsForTheNextTest() async throws {
        try await aRegisteredStoreAndNotifierAreThisTestsOwnAndResolveOnce()
    }
}

private final class ResolvedSingletons: @unchecked Sendable {
    private let lock = NSLock()
    private var identifiers: Set<ObjectIdentifier> = []

    /// True when `identifier` wasn't recorded before.
    func insert(_ identifier: ObjectIdentifier) -> Bool {
        lock.withLock { identifiers.insert(identifier).inserted }
    }
}
