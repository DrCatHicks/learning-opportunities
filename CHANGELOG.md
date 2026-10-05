# Changelog

## learning-opportunities-auto 1.0.3

**Fixed:**
- Read commit commands only from the top-level hook input, avoiding false positives from command text in tool output
- Use Codex's plugin root environment variable instead of a version-specific cache path, while still failing silently if the resolved script is missing
- Stop parsing once the required fields are found so large tool responses do not delay every shell command
- Recognize Git commits that use documented global options
- Recognize Git commits behind shell assignments and execution wrappers
- Preserve the automatic two-offer session cap, including for an empty or newline-containing session id
- Recognize commits inside `bash -c`/`sh -c`, `env -S`/`--split-string`, and `$(...)`/backtick bodies that contain an escaped quote
- Ignore `git commit` text inside heredoc bodies, such as a script written with `cat <<'EOF'`
- Recognize commits whose multi-line quoted message contains help or dry-run text
- Recognize commits behind `timeout` and `gtimeout`
- Keep JSON parsing linear for payloads with many strings or escapes

## learning-opportunities-auto 1.0.2

**Fixed:**
- Fixed Codex hook execution from repository working directories by resolving the hook script from Codex's plugin cache instead of using a repo-relative path

## orient 1.0.0

Added orient plugin to the learning-opportunities marketplace.

**New:**
- `orient` skill for generating repo-specific orientation files using program comprehension research
- Showboat mode for detailed linear code walkthroughs

## learning-opportunities-auto 1.0.1

**Fixed:**
- Moved hook declaration from inline `plugin.json` format to `hooks/hooks.json`, which is the format Claude Code actually reads at runtime
- Moved `scripts/post-tool-use.sh` to `hooks/post-tool-use.sh` to colocate with hook configuration

## learning-opportunities-auto 1.0.0

Initial release of the automatic hook companion plugin.

**New:**
- `PostToolUse` hook that triggers after `git commit` and nudges Claude to offer a learning exercise when appropriate
- Bash implementation — works on Linux and macOS out of the box; Windows users need to configure `CLAUDE_CODE_GIT_BASH_PATH` (see README)
- Session state tracking: respects the learning-opportunities skill's two-exercise-per-session limit and declined-offer flag

## learning-opportunities 1.0.0

Initial release as a Claude Code plugin.

**New:**
- `learning-opportunities` skill for science-based deliberate practice during AI-assisted coding
- Exercise types: Prediction/Observation/Reflection, Generation/Comparison, Trace the Path, Debug This, Teach It Back, Retrieval Check-in
- Supporting resources: PRINCIPLES.md (learning science foundations), MEASURE-THIS.md (team experiment playbook)
