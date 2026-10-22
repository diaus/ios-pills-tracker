import Foundation

struct TimedOut: Error {}

/// Polls `condition` on the main actor until it holds, giving the main actor time to run the model under test.
@MainActor
func waitUntil(timeout: Duration = .seconds(5), _ condition: @MainActor () -> Bool) async throws {
    let deadline = ContinuousClock.now + timeout
    while !condition() {
        guard ContinuousClock.now < deadline else { throw TimedOut() }
        try await Task.sleep(for: .milliseconds(10))
    }
}
