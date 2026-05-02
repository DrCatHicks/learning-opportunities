# Learning Opportunities

Last verified: 2026-03-03

## What This Is

A Claude Code plugin packaging science-based learning exercises for deliberate skill development during AI-assisted coding. Author: Dr. Cat Hicks. License: CC-BY-4.0.

## Project Structure

- `.claude-plugin/marketplace.json` - Marketplace catalog (repo root is the marketplace)
- `.agents/plugins/marketplace.json` - Codex marketplace catalog
- `learning-opportunities/` - The skill plugin
  - `.claude-plugin/plugin.json` - Plugin manifest
  - `.codex-plugin/plugin.json` - Codex plugin manifest
  - `skills/learning-opportunities/` - The skill (SKILL.md + resources)
- `learning-opportunities-auto/` - The auto-prompting hook plugin (requires `learning-opportunities`)
  - `.claude-plugin/plugin.json` - Plugin manifest
  - `.codex-plugin/plugin.json` - Codex plugin manifest
  - `hooks/post-tool-use.sh` - PostToolUse hook (bash)
- `orient/` - The orientation generator plugin
  - `.claude-plugin/plugin.json` - Plugin manifest
  - `.codex-plugin/plugin.json` - Codex plugin manifest
  - `skills/orient/` - The skill (SKILL.md)
- `CHANGELOG.md` - Release history

## Releasing a New Version

Each plugin has its own version. When releasing, update the version in four places atomically:

1. `<plugin>/.claude-plugin/plugin.json` — bump `version`
2. `<plugin>/.codex-plugin/plugin.json` — bump `version`
3. `.claude-plugin/marketplace.json` — bump the matching plugin entry's `version`
4. `CHANGELOG.md` — add entry at top, under the `# Changelog` heading

Use semver. All versioned files must show the same version string for the plugin being released. Commit them together.

### Changelog format

```markdown
## <plugin-name> X.Y.Z

Brief description.

**New:**
- Additions

**Changed:**
- Modifications

**Fixed:**
- Bug fixes
```

Only include sections that apply.
