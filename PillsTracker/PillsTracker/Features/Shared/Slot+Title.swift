import Domain
import SwiftUI

extension Slot {
    /// User-facing label (String Catalog key).
    var title: LocalizedStringKey {
        switch self {
        case .morning: "slot.morning"
        case .day: "slot.day"
        case .evening: "slot.evening"
        }
    }

    /// Action label for consuming a pill for this Slot (String Catalog key).
    var consumeTitle: LocalizedStringKey {
        switch self {
        case .morning: "blister.position.take.morning"
        case .day: "blister.position.take.day"
        case .evening: "blister.position.take.evening"
        }
    }
}
