#!/usr/bin/env python3
"""Edit or check the app's String Catalog, writing it byte-for-byte the way Xcode does.

  scripts/xcstrings.py set KEY VALUE   add a manually managed key, or change its English value
  scripts/xcstrings.py remove KEY      delete a key
  scripts/xcstrings.py check           exit 1 if the file isn't in Xcode's format

Xcode generates the Swift symbol from the key after the next build (e.g. "home.title" -> .homeTitle).
Name placeholders for the symbol's arguments: "%(count)lld pills left" -> .blisterPillsLeft(count:).
"""
import json
import pathlib
import sys

CATALOG = pathlib.Path(__file__).resolve().parent.parent / "PillsTracker/PillsTracker/Resources/Localizable.xcstrings"


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


def main(args):
    raw = CATALOG.read_text(encoding="utf-8")
    catalog = json.loads(raw)
    strings = catalog["strings"]
    match args:
        case ["check"]:
            if dumps(catalog) != raw:
                sys.exit(f"{CATALOG} is not in Xcode's format; run `scripts/xcstrings.py set` on any key to rewrite it.")
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


if __name__ == "__main__":
    main(sys.argv[1:])
