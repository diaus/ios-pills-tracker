import Domain
import Foundation

/// Today's progress of the sample Pill Types for SwiftUI previews.
extension PillTypeProgress {
    /// Today's progress of `aggregate`, with an Intake recorded for each of `done`.
    static func preview(_ aggregate: PillTypeAggregate, done: Set<Slot> = []) -> PillTypeProgress {
        let day = Day.current
        let intakes = done.map { slot in
            Intake(
                pillTypeID: aggregate.id,
                blisterID: aggregate.currentBlister?.id ?? UUID(),
                position: Position(row: 0, column: 0),
                slot: slot,
                day: day,
                instant: .now
            )
        }
        return PillTypeProgress(aggregate: aggregate, day: day, intakes: intakes)
    }

    /// Active, Morning Done, Evening Open.
    static let previewVitaminD = preview(.previewVitaminD, done: [.morning])
    /// Active, every Slot Open and one pill left: low stock.
    static let previewMagnesium = preview(.previewMagnesium)
    /// Paused Prescription.
    static let previewOmega3 = preview(.previewOmega3)
    /// No Prescription.
    static let previewIbuprofen = preview(.previewIbuprofen)

    static let previewAll = [previewVitaminD, previewMagnesium, previewOmega3, previewIbuprofen]
}
