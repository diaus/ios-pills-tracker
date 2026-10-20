import SwiftUI

/// The form section that picks a Prescription's Start Day and optional End Day, shared by the
/// Add Pill Type and Prescription sheets. The End Day can't be picked before the Start Day.
struct PrescriptionDaysSection: View {
    @Binding var selection: PrescriptionDaysSelection

    var body: some View {
        Section {
            DatePicker(selection: $selection.startDayDate, displayedComponents: .date) {
                Text(.prescriptionStartDay)
            }
            Toggle(isOn: $selection.hasEndDay.animation()) {
                Text(.prescriptionHasEndDay)
            }
            if selection.hasEndDay {
                DatePicker(selection: $selection.endDayDate, in: selection.startDayDate..., displayedComponents: .date) {
                    Text(.prescriptionEndDay)
                }
            }
        } header: {
            Text(.prescriptionDays)
        } footer: {
            Text(.prescriptionDaysFooter)
        }
    }
}
