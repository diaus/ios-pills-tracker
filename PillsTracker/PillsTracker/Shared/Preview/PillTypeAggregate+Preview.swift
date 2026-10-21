import Domain
import Foundation

/// Sample Pill Types for SwiftUI previews.
extension PillTypeAggregate {
    /// A Pill Type whose Current Blister has its first `present` Positions Present (all when nil),
    /// with a Prescription for `slots` unless `slots` is empty.
    static func preview(
        name: String,
        rows: Int = 3,
        columns: Int = 4,
        present: Int? = nil,
        slots: Set<Slot> = [],
        prescriptionState: PrescriptionState = .active
    ) -> PillTypeAggregate {
        let shape = try! GridShape(rows: rows, columns: columns)
        let pillType = try! PillType(name: name, shape: shape, createdAt: .now)
        let positions = (0..<rows).flatMap { row in (0..<columns).map { Position(row: row, column: $0) } }
        let blister = Blister(
            pillTypeID: pillType.id,
            shape: shape,
            state: .current,
            presentPositions: Set(positions.prefix(present ?? positions.count))
        )
        let prescription = slots.isEmpty
            ? nil
            : try! Prescription(pillTypeID: pillType.id, slots: slots, state: prescriptionState, startDay: Day.current.adding(days: -30))
        return PillTypeAggregate(pillType: pillType, blisters: [blister], prescription: prescription)
    }

    static let previewVitaminD = preview(name: "Vitamin D", present: 10, slots: [.morning, .evening])
    static let previewMagnesium = preview(name: "Magnesium", rows: 2, columns: 5, present: 1, slots: [.morning, .day, .evening])
    static let previewOmega3 = preview(name: "Omega-3", rows: 4, columns: 5, slots: [.evening], prescriptionState: .paused)
    static let previewIbuprofen = preview(name: "Ibuprofen", rows: 2, columns: 6, present: 7)
}
