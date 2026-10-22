# Architecture review, 22 Oct 2026

Three deepening candidates picked from the review report (`~/Downloads/architecture-review-20261022-0320.html`), decided in a grilling round and worked on `refactor/deepen-widget-and-seams` off `feat/lock-screen-widget`, one verified commit per ticket.

Decisions that bind every ticket:

- Factory stays. Candidate 3's goal is the repository seam reachable from the app's tests, which Factory 2.5's `FactoryTesting` `.container` trait gives: each test gets its own `Container.shared`, so tests register an in-memory `PillTypeRepositoryLive` there and build view models as the app does.
- No new abstraction beyond what a test needs: a store-opening closure for the widget, no calendar parameter, no root dependency object, no `CreatePillType`/`DeletePillType` use cases.
- Tests go where the logic lives: widget timeline logic in `PillsTrackerTests` over an in-memory live repository; Start New Blister's rules on the aggregate in `DomainTests`.
