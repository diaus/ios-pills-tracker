import Domain
import SwiftUI

/// Name, Abbreviation and grid shape sections shared by the Add Pill Type and Pill Type sheets.
/// Places a validation error inline under the field it belongs to; any other error (for example a
/// locked shape) shows under both steppers.
struct PillTypeFormFields: View {
    @Binding var name: String
    /// Empty means not set; Domain stores a blank Abbreviation as not set.
    @Binding var abbreviation: String
    @Binding var rows: Int
    @Binding var columns: Int
    var error: DomainError?
    var shapeFooter: LocalizedStringResource
    var isShapeLocked = false

    var body: some View {
        Section {
            // TextField, like LabeledContent below, takes a LocalizedStringResource title only from iOS 26.
            TextField(String(localized: .addPillTypeName), text: $name)
                .textInputAutocapitalization(.words)
            fieldError(error == .emptyName)
        }

        Section {
            TextField(String(localized: .addPillTypeAbbreviation), text: $abbreviation)
                .autocorrectionDisabled()
        } footer: {
            Text(.addPillTypeAbbreviationFooter)
        }

        Section {
            Stepper(value: $rows, in: GridShape.allowedRange) {
                LabeledContent {
                    Text(rows, format: .number)
                } label: {
                    Text(.addPillTypeRows)
                }
            }
            fieldError(error == .invalidRows)
            Stepper(value: $columns, in: GridShape.allowedRange) {
                LabeledContent {
                    Text(columns, format: .number)
                } label: {
                    Text(.addPillTypeColumns)
                }
            }
            fieldError(error == .invalidColumns)
            fieldError(isShapeError)
        } header: {
            Text(.addPillTypeShape)
        } footer: {
            Text(shapeFooter)
        }
        .disabled(isShapeLocked)
    }

    /// An error without a field of its own, such as a locked shape.
    private var isShapeError: Bool {
        guard let error else { return false }
        return ![.emptyName, .invalidRows, .invalidColumns].contains(error)
    }

    /// The error's text, shown only under the field `isHere` picks.
    @ViewBuilder
    private func fieldError(_ isHere: Bool) -> some View {
        if isHere, let error {
            Text(error.message)
                .font(.footnote)
                .foregroundStyle(.red)
        }
    }
}

#Preview {
    @Previewable @State var name = "Vitamin D"
    @Previewable @State var abbreviation = "D3"
    @Previewable @State var rows = 3
    @Previewable @State var columns = 4
    Form {
        PillTypeFormFields(
            name: $name,
            abbreviation: $abbreviation,
            rows: $rows,
            columns: $columns,
            shapeFooter: .pillTypeShapeFooter
        )
    }
}

#Preview("Error, shape locked") {
    @Previewable @State var name = ""
    @Previewable @State var abbreviation = ""
    @Previewable @State var rows = 3
    @Previewable @State var columns = 4
    Form {
        PillTypeFormFields(
            name: $name,
            abbreviation: $abbreviation,
            rows: $rows,
            columns: $columns,
            error: .emptyName,
            shapeFooter: .pillTypeShapeLocked,
            isShapeLocked: true
        )
    }
}
