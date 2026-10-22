import Domain
import SwiftUI

/// Name, Abbreviation and grid shape sections shared by the Add Pill Type and Pill Type sheets.
/// Places a validation error inline under the field `PillTypeForm` assigns it to.
struct PillTypeFormFields: View {
    @Binding var form: PillTypeForm
    var error: DomainError?
    var shapeFooter: LocalizedStringResource
    var isShapeLocked = false

    var body: some View {
        Section {
            // TextField, like LabeledContent below, takes a LocalizedStringResource title only from iOS 26.
            TextField(String(localized: .addPillTypeName), text: $form.name)
                .textInputAutocapitalization(.words)
            fieldError(.name)
        }

        Section {
            TextField(String(localized: .addPillTypeAbbreviation), text: $form.abbreviation)
                .autocorrectionDisabled()
        } footer: {
            Text(.addPillTypeAbbreviationFooter)
        }

        Section {
            Stepper(value: $form.rows, in: GridShape.allowedRange) {
                LabeledContent {
                    Text(form.rows, format: .number)
                } label: {
                    Text(.addPillTypeRows)
                }
            }
            fieldError(.rows)
            Stepper(value: $form.columns, in: GridShape.allowedRange) {
                LabeledContent {
                    Text(form.columns, format: .number)
                } label: {
                    Text(.addPillTypeColumns)
                }
            }
            fieldError(.columns)
            fieldError(.shape)
        } header: {
            Text(.addPillTypeShape)
        } footer: {
            Text(shapeFooter)
        }
        .disabled(isShapeLocked)
    }

    /// The error's text, shown only under the field it belongs to.
    @ViewBuilder
    private func fieldError(_ field: PillTypeForm.Field) -> some View {
        if let error, PillTypeForm.field(for: error) == field {
            Text(error.message)
                .font(.footnote)
                .foregroundStyle(.red)
        }
    }
}

#Preview {
    @Previewable @State var form = PillTypeForm(.previewVitaminD)
    Form {
        PillTypeFormFields(form: $form, shapeFooter: .pillTypeShapeFooter)
    }
}

#Preview("Error, shape locked") {
    @Previewable @State var form = PillTypeForm()
    Form {
        PillTypeFormFields(form: $form, error: .emptyName, shapeFooter: .pillTypeShapeLocked, isShapeLocked: true)
    }
}
