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
# Check if this was a git commit. The hook matcher already filters to Bash
# tool calls, so we only need to detect git commit in the command field.
# The payload is single-line JSON from Claude Code, so grepping the raw
# input for the pattern in the "command" field is reliable. False positives
# (e.g., output that mentions "git commit") are harmless — we just offer
# a learning exercise unnecessarily.
# ---------------------------------------------------------------------------

if ! echo "$INPUT" | grep -q '"command".*git.*commit'; then
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
# Extract cwd so we can query git in the repo the commit was made in,
# and identify the commit by its short SHA for de-duplication below.
# ---------------------------------------------------------------------------

CWD=$(echo "$INPUT" | grep -o '"cwd":"[^"]*"' | head -1 | sed 's/"cwd":"//;s/"$//')
if [[ -z "$CWD" ]]; then
  CWD="$PWD"
fi

SHA=$(git -C "$CWD" rev-parse --short HEAD 2>/dev/null) || exit 0
if [[ -z "$SHA" ]]; then
  exit 0
fi

# ---------------------------------------------------------------------------
# Verify the commit actually landed. If HEAD's commit timestamp isn't
# very recent, the `git commit` call likely failed (e.g. pre-commit hook
# rejected it) and HEAD is still the *previous* commit — in which case
# we'd nudge about stale work. Skip silently in that case.
# ---------------------------------------------------------------------------

COMMIT_TS=$(git -C "$CWD" log -1 --format=%ct 2>/dev/null) || exit 0
NOW=$(date +%s)
if (( NOW - COMMIT_TS > 30 )); then
  exit 0
fi

# ---------------------------------------------------------------------------
# Session state:
#   * .state  — count of emitted offers this session (cap at 2)
#   * .seen   — commit SHAs we've already nudged about (de-dupe)
# Both live in $TMPDIR keyed on session id; reset when the session ends.
# The counter increments only when a nudge is actually emitted, and the
# per-SHA de-dupe ensures a single commit can't consume multiple offers
# from the session cap if this hook is invoked more than once for it.
# ---------------------------------------------------------------------------

SAFE_ID="${SESSION_ID//[^a-zA-Z0-9_-]/_}"
STATE_FILE="${TMPDIR:-/tmp}/lo_auto_${SAFE_ID}.state"
SEEN_FILE="${TMPDIR:-/tmp}/lo_auto_${SAFE_ID}.seen"

if [[ -f "$SEEN_FILE" ]] && grep -q "^${SHA}$" "$SEEN_FILE" 2>/dev/null; then
  exit 0
fi

offers=0
if [[ -f "$STATE_FILE" ]]; then
  offers=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
fi

# Stop after 2 offers per session.
if [[ "$offers" -ge 2 ]]; then
  exit 0
fi

# ---------------------------------------------------------------------------
# Grab the commit subject so the nudge can mention a concrete topic.
# Sanitize to stay safely embeddable in the JSON string below: strip
# newlines, tabs, carriage returns, double-quotes, and backslashes, and
# cap length.
# ---------------------------------------------------------------------------

SUBJECT=$(git -C "$CWD" log -1 --pretty=%s 2>/dev/null | head -c 160 | tr -d '"\r\n\t\\')

# Record that we're emitting a nudge for this commit, then emit.
echo "$SHA" >> "$SEEN_FILE"
echo $(( offers + 1 )) > "$STATE_FILE"

# ---------------------------------------------------------------------------
# Emit suggestion for Claude via structured JSON. PostToolUse hooks must
# output JSON with hookSpecificOutput on exit 0 to inject context.
# ---------------------------------------------------------------------------

cat <<HOOK_JSON
{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"[learning-opportunities-auto] The user just committed code (${SHA}: ${SUBJECT}). Per the learning-opportunities skill, consider whether this is a good moment to offer a learning exercise. If the committed work involved new files, schema changes, architectural decisions, refactors, or unfamiliar patterns, ask the user (one short sentence) if they'd like a 10-15 minute exercise. Do not start the exercise until they confirm. If they decline, note it — no more offers this session."}}
HOOK_JSON

exit 0
