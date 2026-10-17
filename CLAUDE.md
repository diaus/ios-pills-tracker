## Agent skills

### Issue tracker

Issues live as local markdown files under `.scratch/<feature>/`. See `docs/agents/issue-tracker.md`.

### Triage labels

Default canonical labels (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`), recorded as a `Status:` line in each issue file. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `GLOSSARY.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.

## Building

Build, test and run through the MobileBuildMCP tools (`build_sim`, `test_sim`, `build_run_sim`). Empty session defaults: see `docs/agents/build-setup.md`.

The deployment target is iOS 18: check runtime behaviour there by switching the simulator to iPhone 16 (iOS 18.5) for the session only, without `persist`.
