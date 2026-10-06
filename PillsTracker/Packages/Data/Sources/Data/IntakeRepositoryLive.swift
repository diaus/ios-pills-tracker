import Domain
import FactoryKit
import Foundation
import SwiftData

/// SwiftData-backed `IntakeRepository`. Shares the change notifier with the other repositories.
@ModelActor
public actor IntakeRepositoryLive: IntakeRepository {
    /// Defaults to the shared notifier so the macro-synthesised `init(modelContainer:)` stays usable.
    private var notifier = Container.shared.dataChangeNotifier()

    public init(modelContainer: ModelContainer, notifier: DataChangeNotifier) {
        self.modelContainer = modelContainer
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))
        self.notifier = notifier
    }

    public var changes: AsyncStream<Void> { notifier.changes }

    public func fetch(day: Day, pillTypeID: UUID?) throws -> [Intake] {
        let year = day.year, month = day.month, dayOfMonth = day.day
        let predicate: Predicate<IntakeModel>
        if let pillTypeID {
            predicate = #Predicate {
                $0.dayYear == year && $0.dayMonth == month && $0.dayDay == dayOfMonth && $0.pillTypeID == pillTypeID
            }
        } else {
            predicate = #Predicate { $0.dayYear == year && $0.dayMonth == month && $0.dayDay == dayOfMonth }
        }
        let descriptor = FetchDescriptor<IntakeModel>(predicate: predicate, sortBy: [SortDescriptor(\.instant, order: .forward)])
        return try modelContext.fetch(descriptor).map { $0.toDomain() }
    }

    public func fetch(id: UUID) throws -> Intake? {
        try model(for: id)?.toDomain()
    }

    public func create(_ intake: Intake) throws {
        let pillTypeID = intake.pillTypeID
        var owner = FetchDescriptor<PillTypeModel>(predicate: #Predicate { $0.id == pillTypeID })
        owner.fetchLimit = 1
        guard let pillType = try modelContext.fetch(owner).first else { throw DataError.notFound }
        let model = IntakeModel(intake)
        modelContext.insert(model)
        model.pillType = pillType
        try modelContext.save()
        notifier.notify()
    }

    public func delete(id: UUID) throws {
        guard let model = try model(for: id) else { return }
        modelContext.delete(model)
        try modelContext.save()
        notifier.notify()
    }

    private func model(for id: UUID) throws -> IntakeModel? {
        var descriptor = FetchDescriptor<IntakeModel>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
}
