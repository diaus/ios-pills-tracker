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

    /// Action label for consuming a pill for this Slot, from the String Catalog.
    var consumeTitle: LocalizedStringResource {
        switch self {
        case .morning: .blisterPositionConsumeMorning
        case .day: .blisterPositionConsumeDay
        case .evening: .blisterPositionConsumeEvening
        }
    }
}
