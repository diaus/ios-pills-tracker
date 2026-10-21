import Domain
import Foundation

/// What the widget shows for its Pill Type on a Day.
nonisolated enum PillTypeWidgetContent: Hashable {
    /// Unconfigured, the Pill Type deleted, or the store not there yet: the large `pills` symbol.
    case noPillType
    /// The Prescription is Paused or removed: "-/-/-" in place of the Slots, the whole widget dimmed.
    case withoutActivePrescription(abbreviation: String)
    /// An Active Prescription: one entry per prescribed Slot, in Morning/Day/Evening order, true when Done.
    case withActivePrescription(abbreviation: String, slotsDone: [Bool], isCompleted: Bool)

    /// nil progress is a Pill Type that's gone. The Prescription's state is checked before `isCompleted`,
    /// which is also true without a Prescription.
    init(progress: PillTypeProgress?) {
        guard let progress else {
            self = .noPillType
            return
        }
        let abbreviation = progress.pillType.displayAbbreviation
        guard progress.prescriptionState == .active else {
            self = .withoutActivePrescription(abbreviation: abbreviation)
            return
        }
        self = .withActivePrescription(abbreviation: abbreviation, slotsDone: progress.slots.map(\.isDone), isCompleted: progress.isCompleted)
    }
}

extension PillTypeWidgetContent {
    /// Stands in for a real Pill Type in the widget gallery and while the widget loads.
    nonisolated static let sample = PillTypeWidgetContent.withActivePrescription(abbreviation: "D3", slotsDone: [true, false], isCompleted: false)
}
