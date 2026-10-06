import Foundation
import Testing
@testable import PillsTracker

struct StringCatalogTests {
    @Test func homeEmptyStateTextComesFromTheStringCatalog() {
        let title = String(localized: "home.empty.title", bundle: .main)
        #expect(title == "No pill types yet")
    }
}

struct ErrorMessageCatalogTests {
    @Test func unknownErrorFallbackComesFromTheStringCatalog() {
        #expect(String(localized: "common.error.unknown", bundle: .main) == "Something went wrong. Please try again.")
    }

    @Test(arguments: ["error.notFound", "error.corruptRecord", "error.positionOutOfBounds"])
    func newErrorKeysAreTranslated(key: String) {
        let text = String(localized: String.LocalizationValue(key), bundle: .main)
        #expect(text != key)
    }
}
