import Domain
import Foundation
import SwiftData
import Utils

/// SwiftData-backed `PillTypeRepository`. All model access happens on this actor, in one `ModelContext`,
/// and every write is one save followed by one change notification.
///
/// The `ModelActor` conformance is written out rather than taken from `@ModelActor`, whose synthesised
/// `init(modelContainer:)` would leave the notifier without a value.
public actor PillTypeRepositoryLive: PillTypeRepository, ModelActor {
    public nonisolated let modelContainer: ModelContainer
    public nonisolated let modelExecutor: any ModelExecutor
    private let notifier: ChangeNotifier

    public init(modelContainer: ModelContainer, notifier: ChangeNotifier) {
        self.modelContainer = modelContainer
        modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))
        self.notifier = notifier
    }

    public func fetchAll() throws -> [PillTypeAggregate] {
        let descriptor = FetchDescriptor<PillTypeModel>(sortBy: [SortDescriptor(\.createdAt, order: .forward)])
        return try modelContext.fetch(descriptor).map { try $0.toDomain() }
    }

    public func fetch(id: UUID) throws -> PillTypeAggregate? {
        try pillTypeModel(for: id)?.toDomain()
    }

    public func intakes(on day: Day, pillTypeID: UUID?) throws -> [Intake] {
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
        return try modelContext.fetch(descriptor).map { try $0.toDomain() }
    }

    public func intakes(blisterIDs: [UUID]) throws -> [Intake] {
        let descriptor = FetchDescriptor<IntakeModel>(
            predicate: #Predicate { blisterIDs.contains($0.blisterID) },
            sortBy: [SortDescriptor(\.instant, order: .forward)]
        )
        return try modelContext.fetch(descriptor).map { try $0.toDomain() }
    }

    public func intake(id: UUID) throws -> Intake? {
        try intakeModel(for: id)?.toDomain()
    }

    public func create(_ aggregate: PillTypeAggregate) throws {
        modelContext.insert(PillTypeModel(aggregate))
        try saveAndNotify()
    }

    public func update(_ aggregate: PillTypeAggregate) throws {
        try apply(aggregate)
        try saveAndNotify()
    }

    public func update(_ aggregate: PillTypeAggregate, recording intake: Intake) throws {
        let pillType = try apply(aggregate)
        let model = IntakeModel(intake)
        modelContext.insert(model)
        model.pillType = pillType
        try saveAndNotify()
    }

    public func update(_ aggregate: PillTypeAggregate, removing intake: Intake) throws {
        try apply(aggregate)
        if let model = try intakeModel(for: intake.id) {
            modelContext.delete(model)
        }
        try saveAndNotify()
    }

    public func delete(id: UUID) throws {
        guard let model = try pillTypeModel(for: id) else { return }
        modelContext.delete(model)
        try saveAndNotify()
    }

    /// Writes `aggregate` onto its stored row without saving, so a caller can add more to the same save.
    @discardableResult
    private func apply(_ aggregate: PillTypeAggregate) throws -> PillTypeModel {
        guard let model = try pillTypeModel(for: aggregate.id) else { throw DataError.notFound }
        model.apply(aggregate)
        return model
    }

    /// Saves, or discards every unsaved change when the save fails so the next write starts clean.
    private func saveAndNotify() throws {
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
        notifier.notify()
    }

    private func pillTypeModel(for id: UUID) throws -> PillTypeModel? {
        try first(matching: #Predicate<PillTypeModel> { $0.id == id })
    }

    private func intakeModel(for id: UUID) throws -> IntakeModel? {
        try first(matching: #Predicate<IntakeModel> { $0.id == id })
    }

    private func first<T: PersistentModel>(matching predicate: Predicate<T>) throws -> T? {
        var descriptor = FetchDescriptor<T>(predicate: predicate)
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
}
