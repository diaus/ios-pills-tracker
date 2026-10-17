import Domain
import Foundation

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
