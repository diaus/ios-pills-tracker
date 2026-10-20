import SwiftUI

/// Stands in for a screen's content when Daily Progress could not be loaded, so a failure never
/// looks like an empty list or a missing Pill Type.
struct LoadFailedView: View {
    let message: LocalizedStringResource

    var body: some View {
        ContentUnavailableView(.commonError, systemImage: "exclamationmark.triangle", description: Text(message))
    }
}

#Preview {
    LoadFailedView(message: .commonErrorUnknown)
}
