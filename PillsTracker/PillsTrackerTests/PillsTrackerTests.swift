import Foundation
import Testing
@testable import PillsTracker

struct StringCatalogTests {
    @Test func homeEmptyStateTextComesFromTheStringCatalog() {
        let title = String(localized: "home.empty.title", bundle: .main)
        #expect(title == "No pill types yet")
    }
}
