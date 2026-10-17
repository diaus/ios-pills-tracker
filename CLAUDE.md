## Agent skills

### Issue tracker

Issues live as local markdown files under `.scratch/<feature>/`. See `docs/agents/issue-tracker.md`.

### Triage labels

Default canonical labels (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`), recorded as a `Status:` line in each issue file. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `GLOSSARY.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.

## Building

Build, test and run through the MobileBuildMCP tools (`build_sim`, `test_sim`, `build_run_sim`). Empty session defaults: see `docs/agents/build-setup.md`.

`test_sim` runs only the app target's tests. Before reporting done, run `scripts/check.sh`: it lints the packages, checks the String Catalog format, and runs every local package's tests on the Mac.

SourceKit's "No such module 'Domain'/'Data'" diagnostics are index noise; `build_sim` is the source of truth.

For any UI change, before reporting done, drive the running app with MobileBuildMCP's UI tools (`snapshot_ui`, `tap`, `type_text`) on the deployment target, iOS 18: switch the simulator to iPhone 16 (iOS 18.5) for the session only, without `persist`. Confirm each action from the snapshot it returns, since a tool's success status can't tell a dropped tap from a landed one. A check that couldn't run is reported as skipped, its acceptance box left unticked.

## Editing

Add or change String Catalog keys with `scripts/xcstrings.py`, which writes the file in Xcode's own format.

Commit a fix once it's verified, so a later session doesn't mistake it for the user's work in progress.
