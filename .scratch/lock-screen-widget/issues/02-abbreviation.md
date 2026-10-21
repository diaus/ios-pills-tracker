# 02: Abbreviation on Pill Type

**What to build:** A Pill Type gets an optional Abbreviation, a short form of its name used where the full name doesn't fit (first used by the Lock Screen widget). It's edited on the Add and Edit Pill Type screens. When it isn't set, the first two characters of the name stand in for it. See GLOSSARY "Abbreviation".

**Blocked by:** none

**Status:** ready-for-agent

- [x] Domain: `PillType` has an optional `abbreviation`. Blank after trimming whitespace is stored as not set. No length limit.
- [x] Domain: one place that answers "the text to show in short form": the Abbreviation when set, otherwise the first two characters of the name
- [x] Domain tests: blank or whitespace-only Abbreviation is not set; the fallback uses the first two characters of the name (and the whole name when it's shorter)
- [x] Data: schema V3 adds the optional field, with a lightweight migration from V2; existing Pill Types have no Abbreviation
- [x] Data tests: the Abbreviation round-trips; a V2 store migrates with every Abbreviation not set
- [x] Add Pill Type and Edit Pill Type screens have an optional Abbreviation text field; new strings added with `scripts/xcstrings.py`
- [ ] UI checked on iPhone 16 (iOS 18.5): add a Pill Type with and without an Abbreviation, edit it, clear it
- [ ] `scripts/check.sh` passes and `build_sim` builds with zero warnings
