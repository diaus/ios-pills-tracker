---
status: accepted
---

# Today rolls over at 03:00, not at midnight

An evening pill is often taken after midnight, and it should count for the evening it belongs to, not for the next Day. We decided that Today rolls over at 03:00 local time: before 03:00, Today is the previous calendar Day. A Day stays a plain calendar day. The only thing that changes is how Today is computed, through `Day.current` in Domain, which the app and the widget both call. The 3-hour offset is a fixed constant.

`Day.current` reads the clock, which amends ADR 0001's consequence that "one app-level model, not the Domain, decides what 'today' is". The widget extension needs the same answer as the app, and Domain is the code they share. Use cases still take `Day` as a parameter and never call `Day.current`.

## Considered Options

- **Keep midnight and let the widget lag until 03:00.** Rejected: between 00:00 and 03:00 the widget and the app would disagree, and a Consume at 01:00 would still go to the new Day.
- **A Day boundary built into the Domain** (Day carries its own start time, or Intakes judged by instant). Rejected: more model for a rule that only decides which Day "now" belongs to.

## Consequences

- Intakes stored before this change between 00:00 and 03:00 keep the calendar Day they were recorded on. They aren't migrated (ADR 0001: the Day the user experienced is the truth).
- `significantTimeChangeNotification` fires at midnight, not 03:00, so the app also schedules a refresh of Today at the next 03:00. The widget's timeline has an entry there as well.
- On daylight-saving nights the rollover can be up to an hour off. That's accepted, so `Day.current` has no test.
