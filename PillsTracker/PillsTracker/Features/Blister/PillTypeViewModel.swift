import Data
import Domain
import FactoryKit
import Foundation
import Observation
import SwiftUI

/// Renames a Pill Type, changes its grid shape (only while the Current Blister is empty) or deletes it.
/// Rules live in Domain (`PillTypeAggregate`); this only drives the form and persists.
@MainActor @Observable
final class PillTypeViewModel {
    @ObservationIgnored @Injected(\.pillTypeRepository) private var repository

    let pillTypeID: UUID
    private(set) var aggregate: PillTypeAggregate?
    private(set) var hasLoaded = false
    var name = ""
    var rows = GridShape.allowedRange.lowerBound
    var columns = GridShape.allowedRange.lowerBound
    private(set) var nameError: LocalizedStringKey?
    private(set) var shapeError: LocalizedStringKey?
    var errorMessage: String?
    private(set) var isSaving = false

    init(pillTypeID: UUID) {
        self.pillTypeID = pillTypeID
    }

    /// The shape can change only while every Position of the Current Blister is Empty.
    var isShapeLocked: Bool {
        guard let current = aggregate?.currentBlister else { return false }
        return !current.isEmpty
    }

    func load() async {
        do {
            aggregate = try await repository.fetch(id: pillTypeID)
            if let pillType = aggregate?.pillType {
                name = pillType.name
                rows = pillType.shape.rows
                columns = pillType.shape.columns
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        hasLoaded = true
    }

    /// Applies the rename and, when it changed, the new shape. Returns true on success so the sheet can dismiss.
    func save() async -> Bool {
        nameError = nil
        shapeError = nil
        guard var updated = aggregate else { return false }
        do {
            try updated.rename(name)
            let shape = try GridShape(rows: rows, columns: columns)
            if shape != updated.pillType.shape {
                try updated.changeShape(shape)
            }
        } catch {
            show(error)
            return false
        }
        return await persist { try await repository.update(updated) }
    }

    /// Deletes the Pill Type; the Data layer cascades its Prescription, Blisters and Intakes.
    func delete() async -> Bool {
        await persist { try await repository.delete(id: pillTypeID) }
    }

    private func persist(_ write: () async throws -> Void) async -> Bool {
        isSaving = true
        defer { isSaving = false }
        do {
            try await write()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private func show(_ error: DomainError) {
        switch error {
        case .emptyName: nameError = error.message
        case .invalidRows, .invalidColumns, .currentBlisterNotEmpty: shapeError = error.message
        default: errorMessage = String(localized: "common.error")
        }
    }
}
