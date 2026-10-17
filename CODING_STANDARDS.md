# Coding Standards

Judgement calls for reviewing a diff. Tooling already enforces the mechanical rules, so a review skips them: SwiftLint (`PillsTracker/.swiftlint.yml`: catalog symbols instead of string literals, no `localizedDescription`, GLOSSARY "Avoid" words in identifiers) and the String Catalog format (`scripts/xcstrings.py check`). Domain vocabulary lives in `GLOSSARY.md`, decisions in `docs/adr/`.

## Architecture

- **Layers.** Domain imports only Foundation: no SwiftData, no SwiftUI, no Factory. Only Data imports SwiftData. Factory wiring lives in Data's `DI/` and the app's `Composition/`.
- **Utils is project-independent.** It holds helpers other projects could reuse (concurrency primitives, Foundation extensions) and imports only the standard library and Apple's system frameworks: no Domain, no Data, no third-party package. The glossary lint rule skips it, since its generic words aren't the domain's language.
- **Folders by role.** A new file goes in the folder for its role:
  - Domain: `Models/`, `Repositories/` (protocols), `UseCases/`, `Errors/`.
  - Data: `Repositories/` (the concrete repositories only), `Infrastructure/` (generic SwiftData helpers the repositories share), `Mapping/` (model ↔ domain), `Schema/V<n>/`, `DI/`, `Errors/`.
  - Utils: one folder per topic, e.g. `Concurrency/`.
  - App: `App/`, `Composition/`, `Features/<Feature>/` (a view and its view model), `Shared/{Components,Extensions,Modifiers}/`.
  Mixed folders get split. Repositories and helper infrastructure don't share a folder.
- **No speculative abstraction.** Add a protocol, wrapper or injection point only for a need the current spec has. Use cases take `Day` as a parameter; there is no clock or `DateProvider` (ADR 0001). A two-case enum that only means yes/no is a `Bool`.

## Naming

- **One concept, one name across features.** If two view models hold the same thing (the chosen Slots, the Pill Type being edited), they name it the same way.
- **An extension file's name covers all its members.** `Slot+Presentation.swift` holds a title, an icon and a Consume title. `Slot+Title.swift` would mislead.
- Use glossary terms in names, keys and test names, even where the linter can't see the word (test display strings, comments, catalog values).

## SwiftUI

- **View models** are `@MainActor @Observable` and own the async work. Views call into them from `.task`, `.onChange` and actions.
- **Conditional containers render something on every path.** When `.task`, `.onAppear` or `.onChange` hang off a `Group` or `if` chain, every branch, including the loading state, produces a view (`ProgressView()`, never nothing). An empty first render never fires `.task`, and the screen stays blank.
- Errors reach the user through `error.userMessage` and `.errorAlert(message:)`.

## Tests

- **Each test can fail for a real regression.** Reject tests that:
  - compare against UI copy (`String(localized: .homeTitle) == "…"`); they break on every wording change;
  - restate a declaration: an enum's `allCases`, a schema version, a constant;
  - re-check what the compiler already guarantees (generated catalog symbols, exhaustive switches);
  - use a fake the code under test can never reach, so the assertion passes whatever the code does.
- **SwiftData to-many relationships are unordered.** Tests over them compare as sets or sort first. Code that needs an order sorts explicitly.
- Test names describe behaviour in glossary terms (`refusesASlotAlreadyDoneToday`).

## Blast radius

Run `graft build . --no-ignore && graft blast --base <fixed-point> --no-owners` once per review (the build takes under a second and makes a fresh clone work). It lists the code that depends on the changed lines, and marks each changed area `✗` when no test reaches it. Without the `graft` CLI, report this step as skipped.

- **Every listed dependent still fits the change.** Read each one against the new behaviour: a caller that passes old arguments, a screen that shows a changed view, a use case that relies on an old rule.
- **A `✗` area that holds logic gets a test,** in the package's tests where the logic lives. A view with no logic of its own needs none.
- The list undercounts. graft misses calls through a protocol (`repository.create(...)`) and callers of a name two symbols share, so grep the changed protocol methods and shared names before calling a change contained.
