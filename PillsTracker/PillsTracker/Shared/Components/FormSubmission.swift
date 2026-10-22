import Domain
import Foundation
import Observation

/// A sheet's write in progress and what it left behind: a rule it broke, shown under its field, or any
/// other failure's message, shown as an alert. Shared by the Add Pill Type, Pill Type and Prescription sheets.
@MainActor @Observable
final class FormSubmission {
    private(set) var isSaving = false
    /// The rule the write broke.
    private(set) var validationError: DomainError?
    var errorMessage: LocalizedStringResource?

    /// Runs `write`, sending a `DomainError` to `validationError` and any other error to `errorMessage`.
    /// Returns true on success so the sheet can dismiss.
    func run(_ write: () async throws -> Void) async -> Bool {
        validationError = nil
        isSaving = true
        defer { isSaving = false }
        do {
            try await write()
            return true
        } catch let error as DomainError {
            validationError = error
            return false
        } catch {
            errorMessage = error.userMessage
            return false
        }
    }
}
