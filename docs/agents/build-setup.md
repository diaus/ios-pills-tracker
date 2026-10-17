# Build Setup

One-time MobileBuildMCP setup, for when `session_show_defaults` comes back empty (fresh clone or new machine).

Call `session_set_defaults` with `persist: true`, which writes the gitignored, machine-local `.mobilebuildmcp/config.yaml` so later sessions load these defaults on their own:

- `projectPath: ./PillsTracker/PillsTracker.xcodeproj`, `scheme: PillsTracker`, `configuration: Debug`, `simulatorName: iPhone 18 Pro`
- `extraArgs: ["-skipPackagePluginValidation"]`: the SwiftLint build plugin otherwise stops command-line builds at Xcode's plugin trust check.

Setup is complete when `session_show_defaults` lists all five values.
