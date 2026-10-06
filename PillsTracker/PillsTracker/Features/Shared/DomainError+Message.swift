import Domain
import SwiftUI

extension DomainError {
    /// User-facing text for a Domain error code (String Catalog key).
    var message: LocalizedStringKey {
        switch self {
        case .emptyName: "error.emptyName"
        case .invalidRows: "error.invalidRows"
        case .invalidColumns: "error.invalidColumns"
        case .emptySlots: "error.emptySlots"
        case .noPrescription: "error.noPrescription"
        case .currentBlisterNotEmpty: "error.currentBlisterNotEmpty"
        }
    }
}
