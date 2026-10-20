---
status: accepted
---

# Prescription Start/End Day are presentation-only

Intake History marks each Day Completed or not, which needs to know which Days a Prescription was meant to cover. We added a persisted Start Day (defaulting to the Day the Prescription is created; the Pill Type's creation Day for Prescriptions that existed before) and an optional End Day to the Prescription. Both are editable, and the Domain enforces nothing with them: Consume, Undo, Active/Paused and the Home screen ignore them, and the Domain doesn't even check that End Day is not before Start Day (the editor's picker prevents it). They exist only so Intake History knows which Days to judge.

Intake History judges every Day in that range against the Prescription's *current* Slots, Paused or not, because no Prescription history is kept (ADR 0001). A Day before a Slot change can therefore read as not Completed even though the user followed the regimen of that time; the user can move Start Day to exclude it.

## Considered Options

- **Versioned Prescriptions** (a new record per Slot or state change, each with its own date range). Rejected: accurate past verdicts, but a much larger model and migration for a single read-only screen.
- **Making End Day end the Prescription** (stop it appearing on Home, refuse Consume after it). Rejected for now: Active/Paused already covers stopping, and two overlapping lifecycles would conflict.
- **Deriving the range from Intakes** (first to last Intake Day). Rejected: a Day with no Intakes at the start or end of a course could never be judged as missed.
