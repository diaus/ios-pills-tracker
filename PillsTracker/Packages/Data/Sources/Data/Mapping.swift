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
        prescription = aggregate.prescription.map(PrescriptionModel.init)
    }

    /// Fails only if the stored row violates Domain invariants, which the repository never writes.
    func toDomain() throws -> PillTypeAggregate {
        let shape = try GridShape(rows: rows, columns: columns)
        let pillType = try PillType(id: id, name: name, shape: shape, createdAt: createdAt)
        return PillTypeAggregate(
            pillType: pillType,
            blisters: try blisters.map { try $0.toDomain(pillTypeID: id, pillTypeShape: shape) },
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

extension PrescriptionModel {
    convenience init(_ prescription: Prescription) {
        self.init(id: prescription.id, slots: prescription.slots, state: prescription.state.rawValue)
    }

    func toDomain(pillTypeID: UUID) throws -> Prescription {
        try Prescription(
            id: id,
            pillTypeID: pillTypeID,
            slots: slots,
            state: PrescriptionState(rawValue: state) ?? .paused
        )
    }

    func apply(_ prescription: Prescription) {
        slots = prescription.slots
        state = prescription.state.rawValue
    }
}

extension BlisterModel {
    convenience init(_ blister: Blister) {
        self.init(
            id: blister.id,
            rows: blister.shape.rows,
            columns: blister.shape.columns,
            state: blister.state.rawValue,
            presentPositions: blister.presentPositions
        )
    }

    /// `pillTypeShape` stands in for rows written before Blisters carried their own shape (rows == 0).
    func toDomain(pillTypeID: UUID, pillTypeShape: GridShape) throws -> Blister {
        Blister(
            id: id,
            pillTypeID: pillTypeID,
            shape: rows == 0 ? pillTypeShape : try GridShape(rows: rows, columns: columns),
            state: BlisterState(rawValue: state) ?? .retired,
            presentPositions: presentPositions
        )
    }

    /// The shape is fixed at creation; only state and Present Positions change.
    func apply(_ blister: Blister) {
        state = blister.state.rawValue
        presentPositions = blister.presentPositions
    }
}

extension IntakeModel {
    convenience init(_ intake: Intake) {
        self.init(
            id: intake.id,
            pillTypeID: intake.pillTypeID,
            blisterID: intake.blisterID,
            position: intake.position,
            slot: intake.slot.rawValue,
            dayYear: intake.day.year,
            dayMonth: intake.day.month,
            dayDay: intake.day.day,
            instant: intake.instant
        )
    }

    func toDomain() -> Intake {
        Intake(
            id: id,
            pillTypeID: pillTypeID,
            blisterID: blisterID,
            position: position,
            slot: Slot(rawValue: slot) ?? .day,
            day: Day(year: dayYear, month: dayMonth, day: dayDay),
            instant: instant
        )
    }
}
