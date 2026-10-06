# 01: Project scaffold

**What to build:** The app opens to an empty Home screen with an empty state message, built on the final module structure so every later ticket only adds behaviour. Parent spec: `.scratch/pills-tracker-v1/spec.md`.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] Two local Swift packages, Domain and Data, exist and are linked into the app target; Data depends on Domain; the app depends on both
- [ ] Only Data imports SwiftData; Domain has no framework dependencies
- [ ] hmlongco/Factory is a dependency of Data and the app target, not of Domain
- [ ] Swift 6 language mode with strict concurrency is enabled in both packages and the app target, and the project builds with no concurrency warnings
- [ ] Minimum deployment target is iOS 18 for the app and both packages
- [ ] The template UITest target is deleted; the template unit-test target is replaced or kept as a Swift Testing target
- [ ] Each package has a Swift Testing test target with one passing smoke test
- [ ] A String Catalog exists and the empty-state text comes from it
- [ ] Home shows an empty state ("no pill types yet") with a "+" button that is not yet functional
- [ ] GLOSSARY.md vocabulary is used for all new type names
