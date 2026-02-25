# learning-opportunities-auto

A companion plugin for [learning-opportunities](../learning-opportunities/) that automatically detects good moments to offer learning exercises. Instead of relying on Claude to notice opportunities on its own, this plugin uses a `PostToolUse` hook to watch for significant code changes and nudge Claude to make the offer.

**Requires:** The `learning-opportunities` plugin must also be installed.

## How It Works

The hook fires after every `Bash` tool use and checks whether the command was a `git commit`. After a successful commit, it nudges Claude to consider whether the work that was just committed is a good fit for a learning exercise — the `learning-opportunities` skill handles deciding what kind of exercise to offer based on the nature of the changes.

It respects the same session limits as the skill: no more than 2 offers per session, and it stops if the user declines.

## Installation

1. Make sure you've already installed `learning-opportunities` from this marketplace.

2. Install this plugin:
   ```
   /plugin install learning-opportunities-auto@learning-opportunities
   ```

3. Reload:
   ```
   /plugin reload
   ```

## Windows Setup

On Linux, macOS, and WSL2, this plugin works out of the box. On native Windows, Claude Code runs hooks using `cmd.exe` by default, which cannot execute bash scripts. You need to tell Claude Code where to find bash.

Set the `CLAUDE_CODE_GIT_BASH_PATH` environment variable to point at your Git for Windows bash installation. The typical location is:

```
CLAUDE_CODE_GIT_BASH_PATH=C:\Program Files\Git\bin\bash.exe
```

You can set this as a system environment variable, or add it to your shell profile before launching Claude Code.

If you run into issues, check that `Git\bin` (not just `Git\cmd`) is on your PATH, or that the environment variable above is set correctly. This is a [known friction point](https://github.com/anthropics/claude-code/issues/16602) in Claude Code's Windows hook support. If you're not sure how to set an environment variable or update your PATH on Windows, ask Claude — it can walk you through it.

## How Hooks Work

This plugin uses Claude Code's [hooks system](https://docs.anthropic.com/en/docs/claude-code/hooks) to run a script after each tool use. The hook is declared in `hooks/hooks.json`, which Claude Code reads at plugin load time. The hook script itself lives at `hooks/post-tool-use.sh`. For more on writing and configuring hooks, see the official documentation.

## License

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC_BY_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)
