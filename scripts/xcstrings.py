#!/usr/bin/env python3
"""Edit or check the app's String Catalog, writing it byte-for-byte the way Xcode does.

  scripts/xcstrings.py set KEY VALUE   add a manually managed key, or change its English value
  scripts/xcstrings.py remove KEY      delete a key
  scripts/xcstrings.py sync            rewrite SwiftLint's catalog_key_literal prefixes from the catalog
  scripts/xcstrings.py check           exit 1 if the file isn't in Xcode's format or those prefixes are stale

Xcode generates the Swift symbol from the key after the next build (e.g. "home.title" -> .homeTitle).
Name placeholders for the symbol's arguments: "%(count)lld pills left" -> .blisterPillsLeft(count:).

SwiftLint's catalog_key_literal rule (PillsTracker/.swiftlint.yml) lists the catalog's top-level key
groups, so a typed "group.key" literal fails the build. `set` and `remove` keep that list in step.
"""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
CATALOG = ROOT / "PillsTracker/PillsTracker/Resources/Localizable.xcstrings"
SWIFTLINT = ROOT / "PillsTracker/.swiftlint.yml"
# The `(?:group|group|...)\.[A-Za-z.]*"` part of the catalog_key_literal regex.
PREFIXES = re.compile(r'(\(\?:)([A-Za-z|]+)(\)\\\.\[A-Za-z\.\]\*")')


def ordered(value):
    # Xcode sorts object keys case-insensitively.
    if isinstance(value, dict):
        return {k: ordered(value[k]) for k in sorted(value, key=lambda k: (k.lower(), k))}
    if isinstance(value, list):
        return [ordered(v) for v in value]
    return value


def dumps(catalog):
    # Xcode's spacing (" : ") and no trailing newline.
    return json.dumps(ordered(catalog), indent=2, separators=(",", " : "), ensure_ascii=False)


def groups(strings):
    return sorted({key.split(".")[0] for key in strings}, key=lambda g: (g.lower(), g))


def lint_prefixes(yml):
    found = PREFIXES.findall(yml)
    if len(found) != 1:
        sys.exit(f"{SWIFTLINT}: expected one catalog_key_literal prefix list, found {len(found)}")
    return found[0][1].split("|")


def sync_lint(strings):
    yml = SWIFTLINT.read_text(encoding="utf-8")
    lint_prefixes(yml)
    wanted = "|".join(groups(strings))
    SWIFTLINT.write_text(PREFIXES.sub(lambda m: m[1] + wanted + m[3], yml, count=1), encoding="utf-8")


def main(args):
    raw = CATALOG.read_text(encoding="utf-8")
    catalog = json.loads(raw)
    strings = catalog["strings"]
    match args:
        case ["check"]:
            if dumps(catalog) != raw:
                sys.exit(f"{CATALOG} is not in Xcode's format; run `scripts/xcstrings.py set` on any key to rewrite it.")
            if lint_prefixes(SWIFTLINT.read_text(encoding="utf-8")) != groups(strings):
                sys.exit(f"{SWIFTLINT}: catalog_key_literal's prefixes don't match the catalog's key groups; run `scripts/xcstrings.py sync`.")
            return
        case ["sync"]:
            sync_lint(strings)
            return
        case ["set", key, value]:
            entry = strings.setdefault(key, {"extractionState": "manual"})
            entry.setdefault("localizations", {})["en"] = {"stringUnit": {"state": "translated", "value": value}}
        case ["remove", key]:
            if strings.pop(key, None) is None:
                sys.exit(f"No key {key!r}")
        case _:
            sys.exit(__doc__)
    CATALOG.write_text(dumps(catalog), encoding="utf-8")
    sync_lint(strings)


if __name__ == "__main__":
    main(sys.argv[1:])
