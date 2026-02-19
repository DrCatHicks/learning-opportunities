# Learning Opportunities

Last verified: 2026-02-18

## What This Is

A Claude Code plugin packaging science-based learning exercises for deliberate skill development during AI-assisted coding. Author: Dr. Cat Hicks. License: CC-BY-4.0.

## Project Structure

- `.claude-plugin/marketplace.json` - Marketplace catalog (repo root is the marketplace)
- `learning-opportunities/` - The skill plugin
  - `.claude-plugin/plugin.json` - Plugin manifest
  - `skills/learning-opportunities/` - The skill (SKILL.md + resources)
- `learning-opportunities-auto/` - The auto-prompting hook plugin (requires `learning-opportunities`)
  - `.claude-plugin/plugin.json` - Plugin manifest
  - `scripts/post-tool-use.sh` - PostToolUse hook (bash)
- `CHANGELOG.md` - Release history

## Releasing a New Version

Version must be updated in three places atomically:

1. `learning-opportunities/.claude-plugin/plugin.json` — bump `version`
2. `.claude-plugin/marketplace.json` — bump the plugin entry's `version` to match
3. `CHANGELOG.md` — add entry at top, under the `# Changelog` heading

Use semver. All three files must show the same version string. Commit all three together.

### Changelog format

```markdown
## learning-opportunities X.Y.Z

Brief description.

**New:**
- Additions

**Changed:**
- Modifications

**Fixed:**
- Bug fixes
```

Only include sections that apply.
