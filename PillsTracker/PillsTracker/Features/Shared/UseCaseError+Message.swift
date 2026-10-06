import Domain
import SwiftUI

extension UseCaseError {
    /// User-facing text for a use case error code (String Catalog key).
    var message: LocalizedStringKey {
        switch self {
        case .pillTypeNotFound: "error.pillTypeNotFound"
        case .noCurrentBlister: "error.noCurrentBlister"
        case .blisterNotEmpty: "error.blisterNotEmpty"
        }
    }
}

extension Error {
    /// Maps typed Domain and use case errors to catalog text; anything else falls back to its description.
    var userMessage: LocalizedStringKey {
        switch self {
        case let error as DomainError: error.message
        case let error as UseCaseError: error.message
        default: LocalizedStringKey(localizedDescription)
        }
    }
}
