import Data
import Domain
import FactoryKit
import Foundation
import Observation
import SwiftUI

/// Form state for creating a Pill Type. Validation comes from Domain; this only maps errors to fields.
@MainActor @Observable
final class AddPillTypeViewModel {
    @ObservationIgnored @Injected(\.pillTypeRepository) private var repository

    var name = ""
    var rows = 2
    var columns = 5

    private(set) var nameError: LocalizedStringResource?
    private(set) var rowsError: LocalizedStringResource?
    private(set) var columnsError: LocalizedStringResource?
    var errorMessage: LocalizedStringResource?
    private(set) var isSaving = false

    /// Validates, persists and returns true on success so the sheet can dismiss.
    func save() async -> Bool {
        clearErrors()
        let aggregate: PillTypeAggregate
        do {
            aggregate = try PillTypeAggregate.new(name: name, rows: rows, columns: columns, createdAt: Date())
        } catch {
            show(error)
            return false
        }

        isSaving = true
        defer { isSaving = false }
        do {
            try await repository.create(aggregate)
            return true
        } catch {
            errorMessage = error.userMessage
            return false
        }
    }

    private func clearErrors() {
        nameError = nil
        rowsError = nil
        columnsError = nil
    }

    private func show(_ error: DomainError) {
        switch error {
        case .emptyName: nameError = error.message
        case .invalidRows: rowsError = error.message
        case .invalidColumns: columnsError = error.message
        default: errorMessage = error.userMessage
        }
    }
}
