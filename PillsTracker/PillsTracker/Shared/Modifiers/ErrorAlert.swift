import SwiftUI

/// The shared "Something went wrong" alert: shown while `message` is set, cleared when dismissed.
private struct ErrorAlert: ViewModifier {
    @Binding var message: LocalizedStringResource?

    func body(content: Content) -> some View {
        content.alert(
            .commonError,
            isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })
        ) {
            Button(.commonOk) {}
        } message: {
            if let message {
                Text(message)
            }
        }
    }
}

extension View {
    func errorAlert(message: Binding<LocalizedStringResource?>) -> some View {
        modifier(ErrorAlert(message: message))
    }
}
