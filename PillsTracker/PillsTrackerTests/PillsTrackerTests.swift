import Foundation
import Testing
@testable import PillsTracker

struct StringCatalogTests {
    @Test func homeEmptyStateTextComesFromTheStringCatalog() {
        #expect(String(localized: .homeEmptyTitle) == "No pill types yet")
    }

    @Test func symbolArgumentsFillTheirPlaceholders() {
        #expect(String(localized: .blisterPillsLeft(count: 3)) == "3 pills left")
        #expect(String(localized: .homeAllPillTypes(count: 2)) == "All Pill Types (2)")
        #expect(String(localized: .pillTypesShape(rows: 2, columns: 5)) == "2 × 5 blister")
    }
}

struct ErrorMessageCatalogTests {
    @Test func unknownErrorFallbackComesFromTheStringCatalog() {
        #expect(String(localized: .commonErrorUnknown) == "Something went wrong. Please try again.")
    }

    @Test(arguments: [LocalizedStringResource.errorNotFound, .errorCorruptRecord, .errorPositionOutOfBounds])
    func newErrorKeysAreTranslated(resource: LocalizedStringResource) {
        #expect(String(localized: resource) != resource.key)
    }
}
