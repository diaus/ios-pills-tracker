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
        case .morning: "blister.position.consume.morning"
        case .day: "blister.position.consume.day"
        case .evening: "blister.position.consume.evening"
        }
    }
}
