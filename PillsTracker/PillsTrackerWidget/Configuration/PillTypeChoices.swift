import Domain
import Foundation

/// Which Pill Types the widget offers: those with an Active Prescription, in Home order.
nonisolated enum PillTypeChoices {
    /// The Pill Types of `aggregates`, already in Home order (oldest first), that have an Active Prescription.
    static func active(in aggregates: [PillTypeAggregate]) -> [PillType] {
        aggregates.filter { $0.prescription?.state == .active }.map(\.pillType)
    }
}
