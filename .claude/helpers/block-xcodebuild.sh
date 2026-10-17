#!/usr/bin/env bash
# PreToolUse(Bash): send builds and tests through MobileBuildMCP instead of raw xcodebuild.
# Read-only queries (-list, -showBuildSettings, -version, ...) still run.
command=$(jq -r '.tool_input.command // empty')

# xcodebuild in command position: line start, after ; & | (, optionally behind xcrun/time/env.
grep -Eq '(^|[;&|(])[[:space:]]*((xcrun|time|env|command)[[:space:]]+)*xcodebuild([[:space:]]|$)' <<<"$command" || exit 0
grep -Eq -- '-(list|showBuildSettings|showdestinations|showsdks|showTestPlans|showBuildTimingSummary|version|help|resolvePackageDependencies)([^[:alnum:]]|$)' <<<"$command" && exit 0

cat >&2 <<'EOF'
Raw xcodebuild builds and tests are blocked in this repo. Use the MobileBuildMCP tools instead:
- app target: build_sim, test_sim, build_run_sim (defaults: docs/agents/build-setup.md)
- local packages: scripts/check.sh
EOF
exit 2
