import Data
import Domain
import FactoryKit
import FactoryTesting
import Foundation
import Testing
@testable import PillsTracker

/// The Selected Day rules of the Blister screen, over an in-memory store.
@Suite(.container)
@MainActor
struct BlisterViewModelTests {
    private func makeModel() async throws -> BlisterViewModel {
        try await Container.shared.registerInMemoryStore([.previewVitaminD])
        return BlisterViewModel(pillTypeID: PillTypeAggregate.previewVitaminD.id, dailyProgress: DailyProgressModel())
    }

    @Test func theScreenOpensOnTodayAndNeverSelectsADayAfterIt() async throws {
        let model = try await makeModel()
        let today = model.dailyProgress.today

        #expect(model.selectedDay == today)
        #expect(model.isOnToday)
        #expect(!model.canMoveForward)

        model.selectDay(today.adding(days: 1))
        #expect(model.selectedDay == today)

        model.selectDay(today.adding(days: -3))
        #expect(model.selectedDay == today.adding(days: -3))
        #expect(!model.isOnToday)
    }

    @Test func movingForwardStopsAtToday() async throws {
        let model = try await makeModel()
        let today = model.dailyProgress.today

        model.moveBack()
        #expect(model.selectedDay == today.adding(days: -1))
        #expect(model.canMoveForward)

        model.moveForward()
        model.moveForward()
        #expect(model.selectedDay == today)
        #expect(!model.canMoveForward)
    }

    @Test func aRolloverMovesASelectedDayThatWasTodayAndLeavesAPastOne() async throws {
        let model = try await makeModel()
        let today = model.dailyProgress.today
        let tomorrow = today.adding(days: 1)

        model.todayChanged(from: today, to: tomorrow)
        #expect(model.selectedDay == tomorrow)

        model.selectDay(today.adding(days: -1))
        model.todayChanged(from: today, to: tomorrow)
        #expect(model.selectedDay == today.adding(days: -1))
    }
}
