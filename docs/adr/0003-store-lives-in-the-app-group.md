---
status: accepted
---

# The store lives in the App Group so the widget computes progress itself

The Lock Screen widget shows a Pill Type's progress for Today, and runs in its own process, which cannot read the app's sandbox. We moved the SwiftData store into an App Group container that the app and the widget extension share. The widget opens that store and computes progress from the Prescription and Intakes itself, with the same Domain code the app uses. On first launch after the change, the app moves an existing store (with its `-wal` and `-shm` files) from Application Support into the App Group before it opens the container.

## Considered Options

- **The app writes a snapshot for the widget** (today's Slots per Pill Type) into the App Group after every save, and the store stays where it was. Rejected: a snapshot is valid for a single Day. When Today rolls over while the app isn't running, the widget would show stale progress, unless the snapshot also carried the Prescription, which makes it a second copy of the model.

## Consequences

- Both processes read the same store. The app reloads the widget's timelines after every save, because the widget has no other way to learn about a change.
- Moving the store back out, or moving it to a different container, needs another file migration.
