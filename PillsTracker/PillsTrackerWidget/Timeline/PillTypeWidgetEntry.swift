import Data
import Foundation
import WidgetKit

/// What the widget shows from one moment on.
nonisolated struct PillTypeWidgetEntry: TimelineEntry {
    let date: Date
    /// The configured Pill Type, nil while the widget is unconfigured.
    let pillTypeID: UUID?
    let content: PillTypeWidgetContent

    /// Where tapping the widget opens the app: the shown Pill Type's Blister screen, dimmed or not, or Home
    /// with how to choose a Pill Type in the empty state, which a deleted Pill Type shows too.
    var tap: WidgetTap {
        guard let pillTypeID, content != .empty else { return .configure }
        return .blister(pillTypeID: pillTypeID)
    }
}
