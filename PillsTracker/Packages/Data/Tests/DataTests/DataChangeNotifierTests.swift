import Testing
@testable import Data

struct DataChangeNotifierTests {
    @Test func everySubscriberReceivesEachNotification() async {
        let notifier = DataChangeNotifier()
        var first = notifier.changes.makeAsyncIterator()
        var second = notifier.changes.makeAsyncIterator()

        notifier.notify()

        #expect(await first.next() != nil)
        #expect(await second.next() != nil)
    }
}
