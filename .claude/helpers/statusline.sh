#!/bin/sh
# Combined status line: user's global status line on line 1, graft status on line 2.
input=$(cat)
dir="${CLAUDE_PROJECT_DIR:-.}"
mine=$(printf '%s' "$input" | bash "$HOME/.claude/statusline-command.sh" 2>/dev/null)
graft=$(node "$dir/.claude/helpers/graft-statusline.cjs" 2>/dev/null </dev/null)
[ -n "$mine" ] && printf '%s\n' "$mine"
[ -n "$graft" ] && printf '%s' "$graft"
