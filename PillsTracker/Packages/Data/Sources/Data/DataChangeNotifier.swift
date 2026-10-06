import Synchronization

/// Broadcasts "something was written" to every subscriber. Shared by all repositories
/// so view models can reload after any write.
public final class DataChangeNotifier: Sendable {
    private struct Subscriber {
        var id: Int
        var continuation: AsyncStream<Void>.Continuation
    }

    private let state = Mutex<(nextID: Int, subscribers: [Subscriber])>((nextID: 0, subscribers: []))

    public init() {}

    /// A new stream that yields once per write until the consumer stops iterating.
    public var changes: AsyncStream<Void> {
        let (stream, continuation) = AsyncStream.makeStream(of: Void.self, bufferingPolicy: .bufferingNewest(1))
        let id = state.withLock { state in
            let id = state.nextID
            state.nextID += 1
            state.subscribers.append(Subscriber(id: id, continuation: continuation))
            return id
        }
        continuation.onTermination = { [weak self] _ in
            self?.state.withLock { state in
                state.subscribers.removeAll { $0.id == id }
            }
        }
        return stream
    }

    public func notify() {
        let subscribers = state.withLock { $0.subscribers }
        for subscriber in subscribers {
            subscriber.continuation.yield(())
        }
    }
}
