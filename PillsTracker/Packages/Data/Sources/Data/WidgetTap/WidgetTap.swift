import Foundation

/// Where tapping the Lock Screen widget opens the app, carried by the widget's URL. The widget builds the URL
/// and the app parses it back, so both agree on it here, in a package they both link: neither can import the other.
public enum WidgetTap: Hashable, Sendable {
    /// The widget shows this Pill Type: open its Blister screen on Today.
    case blister(pillTypeID: UUID)
    /// The widget has no Pill Type to show: open Home and explain how to choose one.
    case configure

    /// The app's URL scheme, registered under `CFBundleURLTypes` in the app's `Info.plist`.
    private static let scheme = "pillstracker"
    private static let blisterHost = "blister"
    private static let configureHost = "configure"

    /// `pillstracker://blister/<Pill Type id>` or `pillstracker://configure`.
    public var url: URL {
        var components = URLComponents()
        components.scheme = Self.scheme
        switch self {
        case .blister(let pillTypeID):
            components.host = Self.blisterHost
            components.path = "/" + pillTypeID.uuidString
        case .configure:
            components.host = Self.configureHost
        }
        guard let url = components.url else { preconditionFailure("A Widget Tap's URL is always valid: \(components)") }
        return url
    }

    /// The Widget Tap `url` carries, or nil for any other URL.
    public init?(url: URL) {
        guard url.scheme == Self.scheme else { return nil }
        let path = url.pathComponents.filter { $0 != "/" }
        switch url.host() {
        case Self.blisterHost:
            guard path.count == 1, let pillTypeID = UUID(uuidString: path[0]) else { return nil }
            self = .blister(pillTypeID: pillTypeID)
        case Self.configureHost where path.isEmpty:
            self = .configure
        default:
            return nil
        }
    }
}
