import Foundation
import Testing
import Data

/// The URLs the widget opens the app with: the widget builds them, the app parses them back.
struct WidgetTapTests {
    @Test func aBlisterURLParsesBackToItsPillType() {
        let pillTypeID = UUID()

        #expect(WidgetTap(url: WidgetTap.blister(pillTypeID: pillTypeID).url) == .blister(pillTypeID: pillTypeID))
    }

    @Test func theConfigureURLParsesBack() {
        #expect(WidgetTap(url: WidgetTap.configure.url) == .configure)
    }

    /// The scheme is the one the app's `Info.plist` registers; a round-trip alone would pass with any scheme.
    @Test func parsesABlisterURLInTheAppsRegisteredScheme() throws {
        let url = try #require(URL(string: "pillstracker://blister/5F1E0A57-7A43-4C4B-9C3E-1A2B3C4D5E6F"))

        #expect(WidgetTap(url: url) == .blister(pillTypeID: try #require(UUID(uuidString: "5F1E0A57-7A43-4C4B-9C3E-1A2B3C4D5E6F"))))
    }

    @Test(arguments: [
        "https://blister/5F1E0A57-7A43-4C4B-9C3E-1A2B3C4D5E6F",
        "https://configure",
        "pillstracker://history/5F1E0A57-7A43-4C4B-9C3E-1A2B3C4D5E6F",
        "pillstracker://blister/not-a-pill-type",
        "pillstracker://blister",
    ])
    func ignoresAURLThatIsNotAWidgetTap(_ string: String) throws {
        #expect(WidgetTap(url: try #require(URL(string: string))) == nil)
    }
}
