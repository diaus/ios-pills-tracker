#!/usr/bin/env bash
# Checks the app build doesn't cover: SwiftLint over the local packages (the build plugin lints only the app target),
# the String Catalog's Xcode formatting, and every local package's tests on the Mac.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"

(cd "$root/PillsTracker" && swiftlint lint --quiet --strict)
"$root/scripts/xcstrings.py" check
for p in "$root"/PillsTracker/Packages/*/; do
    swift test --package-path "$p"
done
