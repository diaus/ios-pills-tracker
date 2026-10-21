import Domain
import Testing
@testable import PillsTracker

/// The widget's face for a Pill Type's progress. `PillTypeWidgetContent` is compiled in from the widget's sources.
@MainActor
struct PillTypeWidgetContentTests {
    @Test func showsTheAbbreviationAndEachPrescribedSlotDoneOrOpen() {
        let content = PillTypeWidgetContent(progress: .previewVitaminD)

        #expect(content == .withActivePrescription(abbreviation: "Vi", slotsDone: [true, false]))
        #expect(!content.isCompleted)
    }

    @Test func isCompletedOnceEverySlotIsDone() {
        let content = PillTypeWidgetContent(progress: .preview(.previewVitaminD, done: [.morning, .evening]))

        #expect(content == .withActivePrescription(abbreviation: "Vi", slotsDone: [true, true]))
        #expect(content.isCompleted)
    }

    @Test func aPausedPrescriptionIsDimmedEvenWithEverySlotDone() {
        let progress = PillTypeProgress.preview(.previewOmega3, done: [.evening])

        #expect(PillTypeWidgetContent(progress: progress) == .withoutActivePrescription(abbreviation: "Om"))
    }

    @Test func aPillTypeWithoutAPrescriptionIsDimmedRatherThanCompleted() {
        let content = PillTypeWidgetContent(progress: .previewIbuprofen)

        #expect(content == .withoutActivePrescription(abbreviation: "Ib"))
        #expect(!content.isCompleted)
    }

    @Test func aDeletedPillTypeShowsTheEmptyState() {
        #expect(PillTypeWidgetContent(progress: nil) == .noPillType)
    }
}
