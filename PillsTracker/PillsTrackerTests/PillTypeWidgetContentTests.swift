import Domain
import Testing
@testable import PillsTracker

/// The widget's face for a Pill Type's progress. `PillTypeWidgetContent` is compiled in from the widget's sources.
@MainActor
struct PillTypeWidgetContentTests {
    @Test func showsTheAbbreviationAndEachPrescribedSlotDoneOrOpen() {
        #expect(PillTypeWidgetContent(progress: .previewVitaminD) == .active(abbreviation: "Vi", slotsDone: [true, false], isCompleted: false))
    }

    @Test func isCompletedOnceEverySlotIsDone() {
        let progress = PillTypeProgress.preview(.previewVitaminD, done: [.morning, .evening])

        #expect(PillTypeWidgetContent(progress: progress) == .active(abbreviation: "Vi", slotsDone: [true, true], isCompleted: true))
    }

    @Test func aPausedPrescriptionIsDimmedEvenWithEverySlotDone() {
        let progress = PillTypeProgress.preview(.previewOmega3, done: [.evening])

        #expect(PillTypeWidgetContent(progress: progress) == .inactive(abbreviation: "Om"))
    }

    @Test func aPillTypeWithoutAPrescriptionIsDimmedRatherThanCompleted() {
        #expect(PillTypeWidgetContent(progress: .previewIbuprofen) == .inactive(abbreviation: "Ib"))
    }

    @Test func aDeletedPillTypeShowsTheEmptyState() {
        #expect(PillTypeWidgetContent(progress: nil) == .empty)
    }
}
