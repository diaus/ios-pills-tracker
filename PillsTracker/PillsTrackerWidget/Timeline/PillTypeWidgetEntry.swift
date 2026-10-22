import Data
import Foundation
import WidgetKit

/// What the widget shows from one moment on.
nonisolated struct PillTypeWidgetEntry: TimelineEntry {
    let date: Date
    /// The configured Pill Type, nil while the widget is unconfigured.
    let pillTypeID: UUID?
    let content: PillTypeWidgetContent

    /// Where tapping the widget opens the app: the configured Pill Type's Blister screen, dimmed or not, and
    /// even when the store couldn't be read (the app opens Home if it's gone); or Home with how to choose a
    /// Pill Type when there is none, unconfigured or deleted.
    var tap: WidgetTap {
        guard let pillTypeID, content != .noPillType else { return .configure }
        return .blister(pillTypeID: pillTypeID)
    }
}
