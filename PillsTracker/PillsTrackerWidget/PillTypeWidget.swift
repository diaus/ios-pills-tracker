import Data
import SwiftUI
import WidgetKit

/// The Lock Screen widget: one Pill Type's Slots for Today, Done or Open.
struct PillTypeWidget: Widget {
    nonisolated static let kind = "PillTypeWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: Self.kind, intent: PillTypeWidgetIntent.self, provider: PillTypeTimelineProvider()) { entry in
            PillTypeWidgetView(content: entry.content)
                .containerBackground(for: .widget) { AccessoryWidgetBackground() }
                .widgetURL(entry.tap.url)
        }
        .configurationDisplayName(Text(.widgetTitle))
        .description(Text(.widgetDescription))
        .supportedFamilies([.accessoryCircular])
    }
}

#Preview("Open and Done Slots", as: .accessoryCircular) {
    PillTypeWidget()
} timeline: {
    PillTypeWidgetEntry(date: .now, pillTypeID: UUID(), content: .withActivePrescription(abbreviation: "VD", slotsDone: [true, false, false], isCompleted: false))
}

#Preview("Completed", as: .accessoryCircular) {
    PillTypeWidget()
} timeline: {
    PillTypeWidgetEntry(date: .now, pillTypeID: UUID(), content: .withActivePrescription(abbreviation: "Mg", slotsDone: [true, true], isCompleted: true))
}

#Preview("Long Abbreviation", as: .accessoryCircular) {
    PillTypeWidget()
} timeline: {
    PillTypeWidgetEntry(date: .now, pillTypeID: UUID(), content: .withActivePrescription(abbreviation: "Omega 3 Fish Oil", slotsDone: [false], isCompleted: false))
}

#Preview("Paused or removed Prescription", as: .accessoryCircular) {
    PillTypeWidget()
} timeline: {
    PillTypeWidgetEntry(date: .now, pillTypeID: UUID(), content: .withoutActivePrescription(abbreviation: "VD"))
}

#Preview("Empty", as: .accessoryCircular) {
    PillTypeWidget()
} timeline: {
    PillTypeWidgetEntry(date: .now, pillTypeID: nil, content: .noPillType)
}
