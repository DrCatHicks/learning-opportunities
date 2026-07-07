#!/usr/bin/env bash
set -uo pipefail

# learning-opportunities-auto: PostToolUse hook (matches Bash tool)
#
# Fires after every Bash tool use. Checks whether the command was a
# `git commit` and, if so, suggests that Claude offer a learning exercise.
# The skill itself decides whether the commit's content is worth an
# exercise — this hook just provides the nudge at the right moment.
#
# Uses jq when available for correct JSON parsing; degrades to a scoped
# sed extraction otherwise, so there is no hard dependency.

INPUT=$(cat)

# ---------------------------------------------------------------------------
# Check if this was a `git commit`. The previous heuristic grepped the WHOLE
# payload for '"(command|cmd)".*git.*commit', which fired on any Bash call
# whose command OR output merely contained "git" then "commit" — e.g. `git log`
# / `git status` (output prints "commit ..." / "nothing to commit"), or
# grepping for a "github.com/.../commit" URL. Those are not commits.
#
# Fix: read ONLY the command field, then match an actual `git commit`
# invocation. Prefer jq for correct JSON parsing; fall back to a scoped sed
# extraction when jq is unavailable.
# ---------------------------------------------------------------------------

if command -v jq >/dev/null 2>&1; then
  CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // .tool_input.cmd // empty' 2>/dev/null)
else
  CMD=$(printf '%s' "$INPUT" | sed -nE 's/.*"(command|cmd)"[[:space:]]*:[[:space:]]*"([^"]*)".*/\2/p' | head -1)
fi

# Match `git` as a word, then the `commit` subcommand (whitespace immediately
# before it) within a single command segment (no ';', '&&', '|' bridging
# unrelated commands). Rejects "github.com/.../commit" (git is not a word here)
# and "git log --grep=commit" (no whitespace before "commit").
if ! printf '%s' "$CMD" | grep -Eq '\bgit\b[^;&|]*[[:space:]]commit\b'; then
  exit 0
fi

# ---------------------------------------------------------------------------
# Extract session_id for rate limiting. It's a top-level UUID — no escaped
# quotes or nesting to worry about, so basic grep/sed is safe.
# ---------------------------------------------------------------------------

SESSION_ID=$(echo "$INPUT" | grep -o '"session_id":"[^"]*"' | head -1 | sed 's/"session_id":"//;s/"$//')

if [[ -z "$SESSION_ID" ]]; then
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

# ---------------------------------------------------------------------------
# Emit suggestion for Claude via structured JSON. PostToolUse hooks must
# output JSON with hookSpecificOutput on exit 0 to inject context.
# The message contains no special characters that need escaping.
# ---------------------------------------------------------------------------

cat <<'HOOK_JSON'
{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"[learning-opportunities-auto] The user just committed code. Per the learning-opportunities skill, consider whether this is a good moment to offer a learning exercise. If the committed work involved new files, schema changes, architectural decisions, refactors, or unfamiliar patterns, ask the user (one short sentence) if they'd like a 10-15 minute exercise. Do not start the exercise until they confirm. If they decline, note it — no more offers this session."}}
HOOK_JSON

exit 0
