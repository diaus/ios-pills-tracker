import SwiftUI

/// Start New Blister with its confirmation. The caller shows it only when every Position is Empty.
struct StartNewBlisterButton: View {
    let onConfirm: () -> Void
    @State private var isConfirming = false

    var body: some View {
        Button("blister.startNew", systemImage: "arrow.clockwise") {
            isConfirming = true
        }
        .buttonStyle(.borderedProminent)
        .confirmationDialog("blister.startNew.title", isPresented: $isConfirming, titleVisibility: .visible) {
            Button("blister.startNew.confirm", role: .destructive, action: onConfirm)
            Button("common.cancel", role: .cancel) {}
        } message: {
            Text("blister.startNew.message")
        }
    }
}

#Preview {
    StartNewBlisterButton {}
}
