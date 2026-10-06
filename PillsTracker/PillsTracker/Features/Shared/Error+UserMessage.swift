import Data
import Domain
import SwiftUI

// The one place an error becomes alert text. Typed Domain, use case and Data errors carry codes
// only; each maps to a String Catalog key here, and anything else is reported as unknown.

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

extension UseCaseError {
    /// User-facing text for a use case error code (String Catalog key).
    var message: LocalizedStringKey {
        switch self {
        case .pillTypeNotFound: "error.pillTypeNotFound"
        case .noCurrentBlister: "error.noCurrentBlister"
        case .blisterNotEmpty: "error.blisterNotEmpty"
        case .positionOutOfBounds: "error.positionOutOfBounds"
        case .positionEmpty: "error.positionEmpty"
        case .slotNotOpen: "error.slotNotOpen"
        case .noActivePrescription: "error.noActivePrescription"
        case .undoNotAllowed: "error.undoNotAllowed"
        }
    }
}

extension DataError {
    /// User-facing text for a persistence error code (String Catalog key).
    var message: LocalizedStringKey {
        switch self {
        case .notFound: "error.notFound"
        case .corruptRecord: "error.corruptRecord"
        }
    }
}

extension Error {
    /// Catalog text for any error a view model catches; never a raw runtime description.
    var userMessage: LocalizedStringKey {
        switch self {
        case let error as DomainError: error.message
        case let error as UseCaseError: error.message
        case let error as DataError: error.message
        default: "common.error.unknown"
        }
    }
}
