#!/usr/bin/env bash
set -uo pipefail

# learning-opportunities-auto: PostToolUse hook (matches Bash tool)
#
# Fires after every Bash tool use. Checks whether the command was a
# `git commit` and, if so, suggests that Claude offer a learning exercise.
# The skill itself decides whether the commit's content is worth an
# exercise — this hook just provides the nudge at the right moment.
#
# No external dependencies beyond bash and standard Unix tools.

INPUT=$(cat)

# ---------------------------------------------------------------------------
# Check if this was a git commit. Claude Code sends shell text in a "command"
# field; Codex can send it in a "cmd" field. We extract just that field's
# value so we don't match against tool_response output that mentions
# "git commit" (e.g. the user running `git log` or `grep "git commit" file`).
# ---------------------------------------------------------------------------

CMD=$(echo "$INPUT" | grep -oE '"(command|cmd)":"([^"\\]|\\.)*"' | head -1 | sed -E 's/^"(command|cmd)":"//; s/"$//')

if [[ -z "$CMD" ]]; then
  exit 0
fi

# The regex below is gnarly, so here's the breakdown:
#
#   (^|[;&|`(][[:space:]]*|\$\([[:space:]]*)
#     Anchor — match at the start of the command, or right after a shell
#     separator (`;`, `&`, `|`, backtick, `(`) with optional whitespace, or
#     after a `$(` command substitution. Prevents matching `foogit commit`.
#
#   git
#     The literal `git`.
#
#   ([[:space:]]+-[^[:space:]"]+([[:space:]]+[^-[:space:]"][^[:space:]"]*)?)*
#     Zero or more global-flag blocks. Each block is `<space>-<flag>`,
#     optionally followed by `<space><value>` where the value doesn't start
#     with `-`. This lets `git -C /repo commit` match, while keeping
#     `git log -r commit` from matching (because `log` doesn't start with
#     `-` so it isn't a flag).
#
#   [[:space:]]+commit
#     The literal `commit` subcommand.
#
#   ([[:space:]";|&)]|$|\\)
#     Terminator — whitespace, quote, shell separator, end of string, or
#     backslash. Prevents matching things like `git commit-tree`.

if ! echo "$CMD" | grep -Eq '(^|[;&|`(][[:space:]]*|\$\([[:space:]]*)git([[:space:]]+-[^[:space:]"]+([[:space:]]+[^-[:space:]"][^[:space:]"]*)?)*[[:space:]]+commit([[:space:]";|&)]|$|\\)'; then
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
