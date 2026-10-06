import Domain
import Foundation

// Mapping between SwiftData models and Domain values. Models never leave the Data actor.
// Reading a row that no longer satisfies a Domain invariant throws `DataError.corruptRecord`
// instead of guessing a value.

extension DataError {
    /// Runs a Domain constructor over stored fields; a Domain error means the row is corrupt.
    static func record<T>(_ build: () throws(DomainError) -> T) throws(DataError) -> T {
        do {
            return try build()
        } catch {
            throw .corruptRecord
        }
    }

    /// Decodes a stored raw value; an unknown one means the row is corrupt.
    static func rawValue<T: RawRepresentable>(_ raw: T.RawValue) throws(DataError) -> T {
        guard let value = T(rawValue: raw) else { throw .corruptRecord }
        return value
    }
}

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

extension PrescriptionModel {
    convenience init(_ prescription: Prescription) {
        self.init(id: prescription.id, slots: prescription.slots, state: prescription.state.rawValue)
    }

    func toDomain(pillTypeID: UUID) throws(DataError) -> Prescription {
        let state: PrescriptionState = try DataError.rawValue(state)
        return try DataError.record { () throws(DomainError) in
            try Prescription(id: id, pillTypeID: pillTypeID, slots: slots, state: state)
        }
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
    func toDomain(pillTypeID: UUID, pillTypeShape: GridShape) throws(DataError) -> Blister {
        let shape = rows == 0
            ? pillTypeShape
            : try DataError.record { () throws(DomainError) in try GridShape(rows: rows, columns: columns) }
        return Blister(
            id: id,
            pillTypeID: pillTypeID,
            shape: shape,
            state: try DataError.rawValue(state),
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

    func toDomain() throws(DataError) -> Intake {
        Intake(
            id: id,
            pillTypeID: pillTypeID,
            blisterID: blisterID,
            position: position,
            slot: try DataError.rawValue(slot),
            day: Day(year: dayYear, month: dayMonth, day: dayDay),
            instant: instant
        )
    }
}
