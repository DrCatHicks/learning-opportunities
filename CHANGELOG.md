# Changelog

## learning-opportunities-setup 1.0.0

Added learning-opportunities-setup plugin to the learning-opportunities marketplace.

**New:**
- Guided interview skill for personalizing learning-opportunities (learning style, offer timing, session note storage including skipped exercises)
- Quick path (~3 min) and full path; adaptive jump to quick when the user wants defaults
- Multi-select learning styles (no forced single style); optional interaction prefs (never probe)
- Numbered C6/C7 for auto-hook hard stop and questions-only-when-stopped
- Storage choices: none / daily note / rolling log / both; tool-agnostic logging
- `/learning-opportunities-setup refine` mode: episode-based hit/miss interview that patches overrides in place
- Minimal and richer anonymized override examples; writes local override blocks and optional weekly learning-log stubs

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
