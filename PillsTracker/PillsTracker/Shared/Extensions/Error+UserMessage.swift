import Data
import Domain
import SwiftUI

// The one place an error becomes user-facing text. Typed Domain and Data errors carry codes only;
// each maps to a String Catalog symbol here, and anything else is reported as unknown.

extension DomainError {
    /// User-facing text for a Domain error code, from the String Catalog.
    var message: LocalizedStringResource {
        switch self {
        case .emptyName: .errorEmptyName
        case .invalidRows: .errorInvalidRows
        case .invalidColumns: .errorInvalidColumns
        case .emptySlots: .errorEmptySlots
        case .noPrescription: .errorNoPrescription
        case .currentBlisterNotEmpty: .errorCurrentBlisterNotEmpty
        case .pillTypeNotFound: .errorPillTypeNotFound
        case .noCurrentBlister: .errorNoCurrentBlister
        case .positionOutOfBounds: .errorPositionOutOfBounds
        case .positionEmpty: .errorPositionEmpty
        case .slotNotOpen: .errorSlotNotOpen
        case .noActivePrescription: .errorNoActivePrescription
        case .undoNotAllowed: .errorUndoNotAllowed
        }
    }
}

extension DataError {
    /// User-facing text for a persistence error code, from the String Catalog.
    var message: LocalizedStringResource {
        switch self {
        case .notFound: .errorNotFound
        case .corruptRecord: .errorCorruptRecord
        }
    }
}

extension Error {
    /// Catalog text for any error a view model catches; never a raw runtime description.
    var userMessage: LocalizedStringResource {
        switch self {
        case let error as DomainError: error.message
        case let error as DataError: error.message
        default: .commonErrorUnknown
        }
    }
}
