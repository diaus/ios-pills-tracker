# 01: Today rolls over at 03:00

**What to build:** Today rolls over at 03:00 local time instead of midnight. Add `Day.current` in Domain and use it everywhere the app computes "today". The app also refreshes Today at 03:00 while it stays open. See ADR 0004 and GLOSSARY "Today".

**Blocked by:** none

**Status:** ready-for-agent

- [x] Domain: `Day.current` (static), the calendar Day of `.now` in `.current`, or the previous calendar Day when the local hour is before 3. The 3-hour offset is one named constant. No test (ADR 0004).
- [x] Domain: `Day`'s doc comment no longer says it rolls over at midnight
- [x] App: `DailyProgressModel` and every other place that builds today's Day (`Day(date: .now, calendar: .current)`, `Day(date:)` from `Day+Date.swift` used as "today") use `Day.current`
- [x] App: `DailyProgressModel` schedules a refresh of Today at the next 03:00 and reschedules it after each one. Scene-active and significant-time-change refreshes stay.
- [x] Selected Day still defaults to Today and can't move past Today
- [x] Existing Intakes aren't migrated
- [x] `scripts/check.sh` passes and `build_sim` builds with zero warnings
