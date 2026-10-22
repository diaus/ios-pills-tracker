# Build Setup

One-time MobileBuildMCP setup, for when `session_show_defaults` comes back empty (fresh clone or new machine).

Call `session_set_defaults` with `persist: true`, which writes the gitignored, machine-local `.mobilebuildmcp/config.yaml` so later sessions load these defaults on their own:

- `projectPath: ./PillsTracker/PillsTracker.xcodeproj`, `scheme: PillsTracker`, `configuration: Debug`, `simulatorName: iPhone 18 Pro`
- `extraArgs: ["-skipPackagePluginValidation"]`: the SwiftLint build plugin otherwise stops command-line builds at Xcode's plugin trust check.

Then add the UI tools (`tap`, `type_text`, `swipe`, `batch`, `wait_for_ui`) by editing that file by hand, since `session_set_defaults` doesn't write this key:

```yaml
enabledWorkflows:
  - simulator
  - ui-automation
```

The AXe binary these tools drive ships inside the `mobilebuildmcp` package, so there is nothing to install. The server reads its tool list at startup: restart the session (or reconnect it with `/mcp`) before the tools appear.

`AXE_HID_STABILIZATION_MS` in `.mcp.json` works around [AXe #71](https://github.com/cameroncooke/AXe/issues/71): on Xcode 27, a default-style `tap` reports success while the simulator drops it. Remove it once `mobilebuildmcp` bundles an AXe release with the fix ([AXe #73](https://github.com/cameroncooke/AXe/pull/73)).

Setup is complete when `session_show_defaults` lists all five values and `tap` and `type_text` are among the MobileBuildMCP tools.

## Gotchas

- **Previews.** `RenderPreview` needs the `windowtab-…` id that `XcodeListWorkspaces` returns. Without it the error claims no workspace is open even when Xcode has the project open, and the project path is not accepted as the id.
- **Release build.** Set it with `session_set_defaults` (`configuration: Release`, no `persist`) and set Debug back afterwards. Passing `-configuration` through `extraArgs` fails, since the defaults already pass one.
- **Worktrees.** Session defaults are one set per server, shared by every agent in the session, and they point at the main checkout. To build a worktree, point `projectPath` at its `.xcodeproj` without `persist`, build, and set it back; only one agent builds at a time.
- **Screenshots.** `screenshot` straight after an action often returns the previous frame. Read the state from the action's own snapshot, and retake the screenshot after a `postDelay` of a second or more.
- **Swipes.** Pass `duration: 0.5`; a default-speed swipe lands as a tap.
