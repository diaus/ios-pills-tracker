import Foundation
import WidgetKit

/// What the widget shows from one moment on.
nonisolated struct PillTypeWidgetEntry: TimelineEntry {
    let date: Date
    let content: PillTypeWidgetContent
}
