import Data
import Domain
import FactoryKit
import FactoryTesting
import Foundation
import Testing
@testable import PillsTracker

/// How a tap on the Lock Screen widget lands in Home's navigation, over an in-memory store.
@Suite(.container)
@MainActor
struct WidgetTapRouterTests {
    private let vitaminD = PillTypeAggregate.previewVitaminD

    /// Today's progress, loading until `run` is awaited, as the app has it right after launch.
    private func makeModel() async throws -> DailyProgressModel {
        try await Container.shared.registerInMemoryStore([vitaminD])
        return DailyProgressModel()
    }

    /// Starts the model's loop and returns once Today's progress has loaded; the caller cancels the task.
    private func load(_ model: DailyProgressModel) async throws -> Task<Void, Never> {
        let running = Task { await model.run() }
        try await waitUntil { !model.state.isLoading }
        return running
    }

    @Test func aTapThatArrivesWhileTodayIsLoadingOpensTheBlisterScreenOnceLoaded() async throws {
        let model = try await makeModel()
        let router = WidgetTapRouter(dailyProgress: model)

        router.open(WidgetTap.blister(pillTypeID: vitaminD.id).url)
        #expect(router.path.isEmpty)

        let running = try await load(model)
        defer { running.cancel() }
        router.openRequestedBlister()

        #expect(router.path == [.blister(pillTypeID: vitaminD.id)])
        #expect(!router.isShowingWidgetHelp)
    }

    @Test func aTapForAPillTypeThatNoLongerExistsLandsOnHome() async throws {
        let model = try await makeModel()
        let running = try await load(model)
        defer { running.cancel() }
        let router = WidgetTapRouter(dailyProgress: model)
        router.path = [.pillTypes]

        router.open(WidgetTap.blister(pillTypeID: UUID()).url)

        #expect(router.path.isEmpty)
        #expect(!router.isShowingWidgetHelp)
    }

    @Test func everyTapOpensTheBlisterScreenAfresh() async throws {
        let model = try await makeModel()
        let running = try await load(model)
        defer { running.cancel() }
        let router = WidgetTapRouter(dailyProgress: model)

        router.open(WidgetTap.blister(pillTypeID: vitaminD.id).url)
        let first = AnyHashable(router.blisterIdentity(of: vitaminD.id))
        router.open(WidgetTap.blister(pillTypeID: vitaminD.id).url)
        let second = AnyHashable(router.blisterIdentity(of: vitaminD.id))

        #expect(router.path == [.blister(pillTypeID: vitaminD.id)])
        #expect(first != second)
    }

    @Test func aTapOnAnUnconfiguredWidgetShowsHomeWithHowToChooseAPillType() async throws {
        let model = try await makeModel()
        let router = WidgetTapRouter(dailyProgress: model)
        router.path = [.pillTypes]

        router.open(WidgetTap.configure.url)

        #expect(router.path.isEmpty)
        #expect(router.isShowingWidgetHelp)
    }

    @Test func anyOtherURLIsIgnored() async throws {
        let model = try await makeModel()
        let router = WidgetTapRouter(dailyProgress: model)
        router.path = [.pillTypes]

        router.open(URL(string: "https://example.com/blister")!)

        #expect(router.path == [.pillTypes])
        #expect(!router.isShowingWidgetHelp)
    }
}
