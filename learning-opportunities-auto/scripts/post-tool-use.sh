#!/usr/bin/env bash
set -euo pipefail

# learning-opportunities-auto: PostToolUse hook (matches Bash tool)
#
# Fires after every Bash tool use. Checks whether the command was a
# `git commit` and, if so, suggests that Claude offer a learning exercise.
# The skill itself decides whether the commit's content is worth an
# exercise — this hook just provides the nudge at the right moment.

INPUT=$(cat)

# ---------------------------------------------------------------------------
# Minimal JSON field extraction using grep/sed. Avoids requiring jq, which
# may not be available (especially in git-bash on Windows).
# ---------------------------------------------------------------------------

json_field() {
  echo "$INPUT" | grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 | sed 's/.*:[[:space:]]*"//;s/"$//'
}

json_bool_field() {
  echo "$INPUT" | grep -o "\"$1\"[[:space:]]*:[[:space:]]*[a-z]*" | head -1 | sed 's/.*:[[:space:]]*//'
}

TOOL_NAME=$(json_field "tool_name")
SESSION_ID=$(json_field "session_id")
IS_ERROR=$(json_bool_field "is_error")

# Belt-and-suspenders: matcher already filters to Bash.
if [[ "$TOOL_NAME" != "Bash" ]]; then
  exit 0
fi

# Skip failed commands.
if [[ "$IS_ERROR" == "true" ]]; then
  exit 0
fi

# Check whether the command was a git commit. The tool_input contains a
# "command" field with the shell command that was run. We look for `git`
# followed by `commit` anywhere in the line (to handle chained commands
# like `git add . && git commit -m "..."`).
COMMAND=$(json_field "command")
if ! echo "$COMMAND" | grep -qE '\bgit\b.*\bcommit\b'; then
  exit 0
fi

# ---------------------------------------------------------------------------
# Session state: track how many exercises have been offered this session.
# Uses a temp file keyed on session ID; resets when the session ends.
# ---------------------------------------------------------------------------

STATE_FILE="${TMPDIR:-/tmp}/lo_auto_${SESSION_ID//[^a-zA-Z0-9_-]/_}.state"

offers=0
if [[ -f "$STATE_FILE" ]]; then
  offers=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
fi

# Stop after 2 offers per session.
if [[ "$offers" -ge 2 ]]; then
  exit 0
fi

# Record the offer.
echo $(( offers + 1 )) > "$STATE_FILE"

# Emit suggestion for Claude. Claude reads hook stdout and incorporates
# it as context. We keep this brief — Claude + the learning-opportunities
# skill handle the actual offer and exercise.
echo "[learning-opportunities-auto] The user just committed code. Per the learning-opportunities skill, consider whether this is a good moment to offer a learning exercise. If the committed work involved new files, schema changes, architectural decisions, refactors, or unfamiliar patterns, ask the user (one short sentence) if they'd like a 10-15 minute exercise. Do not start the exercise until they confirm. If they decline, note it — no more offers this session."

exit 0
