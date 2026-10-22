import Data
import Domain
import FactoryKit
import Foundation
import Observation
import SwiftUI

/// Renames a Pill Type, sets or clears its Abbreviation, changes its grid shape (only while the Current
/// Blister is empty) or deletes it. Rules live in Domain (`PillTypeAggregate`); this only drives the form
/// and persists.
@MainActor @Observable
final class EditPillTypeViewModel {
    @ObservationIgnored @Injected(\.updatePillType) private var updatePillType
    @ObservationIgnored @Injected(\.pillTypeRepository) private var repository

    /// The Pill Type as the sheet opened on; the form starts from it.
    let aggregate: PillTypeAggregate
    var form: PillTypeForm
    let submission = FormSubmission()

    init(aggregate: PillTypeAggregate) {
        self.aggregate = aggregate
        form = PillTypeForm(aggregate)
    }

    var isShapeLocked: Bool { !aggregate.canChangeShape }

    /// Applies the rename, the Abbreviation and, when it changed, the new shape. Returns true on success so
    /// the sheet can dismiss.
    func save() async -> Bool {
        let form = form
        return await submission.run {
            _ = try await updatePillType(pillTypeID: aggregate.id) { aggregate throws(DomainError) in
                try form.apply(to: &aggregate)
            }
        }
    }

    /// Deletes the Pill Type; the Data layer cascades its Prescription, Blisters and Intakes.
    func delete() async -> Bool {
        await submission.run { try await repository.delete(id: aggregate.id) }
    }
}
