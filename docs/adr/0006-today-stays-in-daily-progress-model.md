---
status: accepted
---

# Today stays inside DailyProgressModel, not in a module of its own

`DailyProgressModel` is the one holder of Today (ADR 0001, 0004). It reads `Day.current`, re-evaluates Today when `RecomputesToday` reports scene activation or a significant time change, and waits for each next 03:00. We decided to keep this in that model rather than split it out from "progress for a Day". The Today code is about 25 lines, and every Today change ends in a reload of that same model's progress. A separate module would have an interface about as large as its body, and it would add a "Today changed" link between the two halves. The parts that read the clock or wait for 03:00 stay untested, like `Day.current` (ADR 0004).

## Considered Options

- **A Today module that gets its `now` and calendar at construction** and feeds Daily Progress and Blister. Rejected (architecture review, 22 Oct 2026). It fails the deletion test: removing it would put the code back where it is now. It also wouldn't have caught the bug it was proposed for, the 03:00 wait that a clock change left stale (commit ab471e9), unless a controllable clock were injected for `Task.sleep` too. "Selected Day follows Today" is already tested through `BlisterViewModel.todayChanged(from:to:)`.
- **`refreshToday(to: Day)` so the guard-and-reload runs with a fixed Day.** Rejected: it would test a three-line guard, and only once `DailyProgressModel` can be built in a test.
