import SwiftUI

/// Calls `onChange` when the scene becomes active and on the system significant-time-change
/// notification (local midnight, time zone change, clock set), so a screen left open is not stale.
private struct RecomputesToday: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    let onChange: @MainActor () -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { onChange() }
            }
            .task {
                for await _ in NotificationCenter.default.notifications(named: UIApplication.significantTimeChangeNotification) {
                    onChange()
                }
            }
    }
}

extension View {
    func recomputesToday(_ onChange: @escaping @MainActor () -> Void) -> some View {
        modifier(RecomputesToday(onChange: onChange))
    }
}
