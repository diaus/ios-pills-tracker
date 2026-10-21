import AppIntents
import WidgetKit

/// The widget's configuration: the Pill Type it shows.
/// App Intents metadata takes only string literals, not catalog symbols, so its titles are spelled out here.
struct PillTypeWidgetIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Pill Type"

    @Parameter(title: "Pill Type")
    var pillType: PillTypeEntity?
}
