import Foundation
@testable import Domain

/// In-memory `IntakeRepository` for Domain use case tests.
actor FakeIntakeRepository: IntakeRepository {
    private var storage: [Intake]
    private let (stream, continuation) = AsyncStream<Void>.makeStream()

    init(_ intakes: [Intake] = []) {
        storage = intakes
    }

    var changes: AsyncStream<Void> { stream }

    /// Every stored Intake, for assertions.
    var all: [Intake] { storage }

    func fetch(day: Day, pillTypeID: UUID?) -> [Intake] {
        storage.filter { $0.day == day && (pillTypeID == nil || $0.pillTypeID == pillTypeID) }
    }

    func fetch(id: UUID) -> Intake? {
        storage.first { $0.id == id }
    }

    func create(_ intake: Intake) {
        storage.append(intake)
        continuation.yield()
    }

    func delete(id: UUID) {
        storage.removeAll { $0.id == id }
        continuation.yield()
    }
}
