import Domain
import Foundation

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
        prescription = aggregate.prescription.map(PrescriptionModel.init)
    }

    func toDomain() throws(DataError) -> PillTypeAggregate {
        let shape = try DataError.record { () throws(DomainError) in try GridShape(rows: rows, columns: columns) }
        let pillType = try DataError.record { () throws(DomainError) in
            try PillType(id: id, name: name, shape: shape, createdAt: createdAt)
        }
        return PillTypeAggregate(
            pillType: pillType,
            blisters: try blisters.map { (model) throws(DataError) in try model.toDomain(pillTypeID: id, pillTypeShape: shape) },
            prescription: try prescription?.toDomain(pillTypeID: id)
        )
    }

    /// Overwrites the stored Pill Type, its Blisters and its Prescription with `aggregate`.
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

        switch (prescription, aggregate.prescription) {
        case (let model?, let value?):
            model.apply(value)
        case (nil, let value?):
            prescription = PrescriptionModel(value)
        case (let model?, nil):
            prescription = nil
            model.modelContext?.delete(model)
        case (nil, nil):
            break
        }
    }
}
