import SwiftUI

/// The shared "Something went wrong" alert: shown while `message` is set, cleared when dismissed.
private struct ErrorAlert: ViewModifier {
    @Binding var message: LocalizedStringKey?

    func body(content: Content) -> some View {
        content.alert(
            "common.error",
            isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })
        ) {
            Button("common.ok") {}
        } message: {
            if let message {
                Text(message)
            }
        }
    }
}

extension View {
    func errorAlert(message: Binding<LocalizedStringKey?>) -> some View {
        modifier(ErrorAlert(message: message))
    }
}
