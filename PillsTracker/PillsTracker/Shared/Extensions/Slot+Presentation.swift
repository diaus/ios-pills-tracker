import Domain
import SwiftUI

extension Slot {
    /// User-facing label from the String Catalog.
    var title: LocalizedStringResource {
        switch self {
        case .morning: .slotMorning
        case .day: .slotDay
        case .evening: .slotEvening
        }
    }

    /// SF Symbol shown on chips and next to the title.
    var systemImage: String {
        switch self {
        case .morning: "sunrise.fill"
        case .day: "sun.max.fill"
        case .evening: "moon.fill"
        }
    }

    /// Title of the Undo confirmation for an Intake of this Slot, from the String Catalog.
    var undoTitle: LocalizedStringResource {
        switch self {
        case .morning: .blisterUndoTitleMorning
        case .day: .blisterUndoTitleDay
        case .evening: .blisterUndoTitleEvening
        }
    }

    /// Action label for consuming a pill for this Slot, from the String Catalog.
    var consumeTitle: LocalizedStringResource {
        switch self {
        case .morning: .blisterPositionConsumeMorning
        case .day: .blisterPositionConsumeDay
        case .evening: .blisterPositionConsumeEvening
        }
    }
}
