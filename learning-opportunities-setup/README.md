# learning-opportunities-setup

A companion plugin for [learning-opportunities](../learning-opportunities/) that interviews you about how you learn, when to offer exercises, and where to store session notes — then writes personal overrides into your local agent instructions.

**Requires:** The `learning-opportunities` plugin is recommended (this setup skill writes overrides *for* it). You can run setup before or after installing the core skill.

## Why this exists

The core skill ships sensible defaults. Many people get more value after telling the agent:

- what's newer vs stronger for them
- which exercise styles help (and which feel like a bad quiz) — multi-select; no forced single style
- whether to auto-offer or wait to be asked
- where to put short notes after completed — or skipped — sessions (including **nowhere**)

This plugin turns that into a short guided interview instead of a DIY edit to `CLAUDE.md`.

## Installation

1. Add the marketplace (if you have not already):
   ```
   /plugin marketplace add https://github.com/DrCatHicks/learning-opportunities.git
   ```

2. Install this plugin:
   ```
   /plugin install learning-opportunities-setup@learning-opportunities
   ```

3. Reload / restart as required by your client, then run:
   ```
   /learning-opportunities-setup
   ```

Choose **quick path** (~3 minutes) or **full path** (~10–15 minutes) when prompted. Say "just make it work" to take quick path with sensible defaults.

## Refine after you have hits and misses

Once you have used exercises for a while, retune without re-running the full questionnaire:

```
/learning-opportunities-setup refine
```

Refine reads your existing `## Learning Opportunities` block, asks episode-based hit/miss questions, proposes a diff, and patches in place.

## What it writes

- A `## Learning Opportunities` override section in the **primary** instruction file you choose (`CLAUDE.local.md`, Cursor rules, MEMORY, etc.)
- Optional stub files for a weekly learning log / history, if you want spaced retrieval later
- Optional copy into a second tool's instruction file only if you ask at the end

Prefer a **local or gitignored** file for personal preferences unless your team wants shared norms committed to the repo. Choosing **no session notes** is a valid, successful outcome.

## Related

- Core exercises: `learning-opportunities`
- Post-commit nudges: `learning-opportunities-auto`
- Repo orientation lessons: `orient`
- Goal-setting (separate repo): [learning-goal](https://github.com/DrCatHicks/learning-goal)

## License

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC_BY_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)
