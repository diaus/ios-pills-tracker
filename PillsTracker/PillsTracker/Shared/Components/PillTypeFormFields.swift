import Domain
import SwiftUI

/// Name and grid shape sections shared by the Add Pill Type and Pill Type sheets.
/// Validation errors show inline under the field they belong to.
struct PillTypeFormFields: View {
    @Binding var name: String
    @Binding var rows: Int
    @Binding var columns: Int
    var nameError: LocalizedStringResource?
    var rowsError: LocalizedStringResource?
    var columnsError: LocalizedStringResource?
    /// An error about the shape as a whole (for example a locked shape), shown under both steppers.
    var shapeError: LocalizedStringResource?
    var shapeFooter: LocalizedStringResource
    var isShapeLocked = false

    var body: some View {
        Section {
            // TextField, like LabeledContent below, takes a LocalizedStringResource title only from iOS 26.
            TextField(String(localized: .addPillTypeName), text: $name)
                .textInputAutocapitalization(.words)
            fieldError(nameError)
        }

        Section {
            Stepper(value: $rows, in: GridShape.allowedRange) {
                LabeledContent {
                    Text(rows, format: .number)
                } label: {
                    Text(.addPillTypeRows)
                }
            }
            fieldError(rowsError)
            Stepper(value: $columns, in: GridShape.allowedRange) {
                LabeledContent {
                    Text(columns, format: .number)
                } label: {
                    Text(.addPillTypeColumns)
                }
            }
            fieldError(columnsError)
            fieldError(shapeError)
        } header: {
            Text(.addPillTypeShape)
        } footer: {
            Text(shapeFooter)
        }
        .disabled(isShapeLocked)
    }

    @ViewBuilder
    private func fieldError(_ message: LocalizedStringResource?) -> some View {
        if let message {
            Text(message)
                .font(.footnote)
                .foregroundStyle(.red)
        }
    }
}
