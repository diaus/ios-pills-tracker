import Domain
import SwiftUI

/// Name and grid shape sections shared by the Add Pill Type and Pill Type sheets.
/// Validation errors show inline under the field they belong to.
struct PillTypeFormFields: View {
    @Binding var name: String
    @Binding var rows: Int
    @Binding var columns: Int
    var nameError: LocalizedStringKey?
    var rowsError: LocalizedStringKey?
    var columnsError: LocalizedStringKey?
    /// An error about the shape as a whole (for example a locked shape), shown under both steppers.
    var shapeError: LocalizedStringKey?
    var shapeFooter: LocalizedStringKey
    var isShapeLocked = false

    var body: some View {
        Section {
            TextField("addPillType.name", text: $name)
                .textInputAutocapitalization(.words)
            fieldError(nameError)
        }

        Section {
            Stepper(value: $rows, in: GridShape.allowedRange) {
                LabeledContent("addPillType.rows", value: rows, format: .number)
            }
            fieldError(rowsError)
            Stepper(value: $columns, in: GridShape.allowedRange) {
                LabeledContent("addPillType.columns", value: columns, format: .number)
            }
            fieldError(columnsError)
            fieldError(shapeError)
        } header: {
            Text("addPillType.shape")
        } footer: {
            Text(shapeFooter)
        }
        .disabled(isShapeLocked)
    }

    @ViewBuilder
    private func fieldError(_ message: LocalizedStringKey?) -> some View {
        if let message {
            Text(message)
                .font(.footnote)
                .foregroundStyle(.red)
        }
    }
}
