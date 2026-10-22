import Domain
import Testing
@testable import PillsTracker

/// Which Pill Types the widget offers. `PillTypeChoices` is compiled in from the widget's sources.
@MainActor
struct PillTypeChoicesTests {
    /// In Home order, as the repository returns them: Active, Active, Paused, no Prescription.
    private let homeOrder: [PillTypeAggregate] = [.previewVitaminD, .previewMagnesium, .previewOmega3, .previewIbuprofen]

    @Test func offersOnlyPillTypesWithAnActivePrescriptionInHomeOrder() {
        #expect(PillTypeChoices.active(in: homeOrder).map(\.name) == ["Vitamin D", "Magnesium"])
    }
}
