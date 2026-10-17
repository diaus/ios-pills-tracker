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
