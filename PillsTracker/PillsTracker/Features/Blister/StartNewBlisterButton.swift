import SwiftUI

/// Start New Blister with its confirmation. The caller shows it only when every Position is Empty.
struct StartNewBlisterButton: View {
    let onConfirm: () -> Void
    @State private var isConfirming = false

    var body: some View {
        Button(.blisterStartNew, systemImage: "arrow.clockwise") {
            isConfirming = true
        }
        .buttonStyle(.borderedProminent)
        .confirmationDialog(.blisterStartNewTitle, isPresented: $isConfirming, titleVisibility: .visible) {
            Button(.blisterStartNewConfirm, role: .destructive, action: onConfirm)
            Button(.commonCancel, role: .cancel) {}
        } message: {
            Text(.blisterStartNewMessage)
        }
    }
}

#Preview {
    StartNewBlisterButton {}
}
