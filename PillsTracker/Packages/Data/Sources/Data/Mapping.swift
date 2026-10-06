import Domain
import Foundation

// Mapping between SwiftData models and Domain values. Models never leave the Data actor.

extension PillTypeModel {
    convenience init(_ aggregate: PillTypeAggregate) {
        self.init(
            id: aggregate.pillType.id,
            name: aggregate.pillType.name,
            rows: aggregate.pillType.shape.rows,
            columns: aggregate.pillType.shape.columns,
            createdAt: aggregate.pillType.createdAt
        )
        blisters = aggregate.blisters.map(BlisterModel.init)
    }

    /// Fails only if the stored row violates Domain invariants, which the repository never writes.
    func toDomain() throws -> PillTypeAggregate {
        let pillType = try PillType(
            id: id,
            name: name,
            shape: GridShape(rows: rows, columns: columns),
            createdAt: createdAt
        )
        return PillTypeAggregate(pillType: pillType, blisters: blisters.map { $0.toDomain(pillTypeID: id) })
    }

    /// Overwrites the stored Pill Type and its Blisters with `aggregate`.
    func apply(_ aggregate: PillTypeAggregate) {
        name = aggregate.pillType.name
        rows = aggregate.pillType.shape.rows
        columns = aggregate.pillType.shape.columns
        createdAt = aggregate.pillType.createdAt

        var existing = Dictionary(uniqueKeysWithValues: blisters.map { ($0.id, $0) })
        var updated: [BlisterModel] = []
        for blister in aggregate.blisters {
            if let model = existing.removeValue(forKey: blister.id) {
                model.apply(blister)
                updated.append(model)
            } else {
                updated.append(BlisterModel(blister))
            }
        }
        for orphan in existing.values {
            orphan.modelContext?.delete(orphan)
        }
        blisters = updated
    }
}

extension BlisterModel {
    convenience init(_ blister: Blister) {
        self.init(id: blister.id, state: blister.state.rawValue, presentPositions: blister.presentPositions)
    }

    func toDomain(pillTypeID: UUID) -> Blister {
        Blister(
            id: id,
            pillTypeID: pillTypeID,
            state: BlisterState(rawValue: state) ?? .retired,
            presentPositions: presentPositions
        )
    }

    func apply(_ blister: Blister) {
        state = blister.state.rawValue
        presentPositions = blister.presentPositions
    }
}
