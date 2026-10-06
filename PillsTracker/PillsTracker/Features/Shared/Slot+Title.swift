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
}
