import Data
import Domain
import FactoryKit
import Foundation
import Observation
import SwiftUI

/// Renames a Pill Type, changes its grid shape (only while the Current Blister is empty) or deletes it.
/// Rules live in Domain (`PillTypeAggregate`); this only drives the form and persists.
@MainActor @Observable
final class EditPillTypeViewModel {
    @ObservationIgnored @Injected(\.updatePillType) private var updatePillType
    @ObservationIgnored @Injected(\.pillTypeRepository) private var repository

    /// The Pill Type as the sheet opened on; the form starts from it.
    let aggregate: PillTypeAggregate
    var name: String
    var rows: Int
    var columns: Int
    /// The rule the form broke; `PillTypeFormFields` shows it under its field.
    private(set) var validationError: DomainError?
    var errorMessage: LocalizedStringResource?
    private(set) var isSaving = false

    init(aggregate: PillTypeAggregate) {
        self.aggregate = aggregate
        name = aggregate.pillType.name
        rows = aggregate.pillType.shape.rows
        columns = aggregate.pillType.shape.columns
    }

    var isShapeLocked: Bool { !aggregate.canChangeShape }

    /// Applies the rename and, when it changed, the new shape. Returns true on success so the sheet can dismiss.
    func save() async -> Bool {
        validationError = nil
        let name = name, rows = rows, columns = columns
        return await persist {
            try await updatePillType(pillTypeID: aggregate.id) { aggregate throws(DomainError) in
                try aggregate.rename(name)
                let shape = try GridShape(rows: rows, columns: columns)
                if shape != aggregate.pillType.shape {
                    try aggregate.changeShape(shape)
                }
            }
        }
    }

    /// Deletes the Pill Type; the Data layer cascades its Prescription, Blisters and Intakes.
    func delete() async -> Bool {
        await persist { try await repository.delete(id: aggregate.id) }
    }

    private func persist(_ write: () async throws -> Void) async -> Bool {
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
