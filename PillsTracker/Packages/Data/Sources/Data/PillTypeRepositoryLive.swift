import Domain
import FactoryKit
import Foundation
import SwiftData

/// SwiftData-backed `PillTypeRepository`. All model access happens on this actor.
@ModelActor
public actor PillTypeRepositoryLive: PillTypeRepository {
    /// Defaults to the shared notifier so the macro-synthesised `init(modelContainer:)` stays usable.
    private var notifier = Container.shared.dataChangeNotifier()

    public init(modelContainer: ModelContainer, notifier: DataChangeNotifier) {
        self.modelContainer = modelContainer
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))
        self.notifier = notifier
    }

    public var changes: AsyncStream<Void> { notifier.changes }

    public func fetchAll() throws -> [PillTypeAggregate] {
        let descriptor = FetchDescriptor<PillTypeModel>(sortBy: [SortDescriptor(\.createdAt, order: .forward)])
        return try modelContext.fetch(descriptor).map { try $0.toDomain() }
    }

    public func fetch(id: UUID) throws -> PillTypeAggregate? {
        try model(for: id)?.toDomain()
    }

    public func create(_ aggregate: PillTypeAggregate) throws {
        modelContext.insert(PillTypeModel(aggregate))
        try saveAndNotify()
    }

    public func update(_ aggregate: PillTypeAggregate) throws {
        guard let model = try model(for: aggregate.id) else { throw DataError.notFound }
        model.apply(aggregate)
        try saveAndNotify()
    }

    public func delete(id: UUID) throws {
        guard let model = try model(for: id) else { return }
        modelContext.delete(model)
        try saveAndNotify()
    }

    private func model(for id: UUID) throws -> PillTypeModel? {
        var descriptor = FetchDescriptor<PillTypeModel>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    private func saveAndNotify() throws {
        try modelContext.save()
        notifier.notify()
    }
}

/// Errors specific to the persistence layer.
public enum DataError: Error, Equatable, Sendable {
    case notFound
}
