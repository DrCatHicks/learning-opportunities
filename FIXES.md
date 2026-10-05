# Fixes

- **False learning prompts:** The hook searched the entire post-tool payload, so
  command text echoed in `tool_response` could look like a commit. The parser now
  reads only direct `session_id` and `tool_input.command` fields.
- **Nested-field confusion:** Greedy string matching could select a nested
  `command` instead of the command Codex or Claude actually ran. A depth-aware
  parser now ignores nested response and metadata fields.
- **Slow hook execution:** The previous parser split large JSON payloads into one
  byte per line and processed the input several times. The replacement uses one
  streaming `awk` process, stops after the required fields, and skips shell
  analysis immediately when the command does not contain `commit`. The full
  regression script, including two 500 KB payloads, fell from 1.66 seconds to
  about 1.5 seconds after the expanded regressions in the local macOS benchmark.
- **Brittle Codex path:** The hook configuration embedded the plugin version in a
  cache path. It now uses Codex's `PLUGIN_ROOT`, so upgrades do not invalidate
  the command.
- **Missing session cap:** delegating limits entirely
  to the skill allowed more than two automatic offers. The hook again caps
  automatic nudges at two per session, while the skill handles declines and
  completed exercises.
- **Rejected Git global options:** valid commits
  using `--git-dir`, `--work-tree`, `--namespace`, or `--config-env` were
  ignored. The detector now consumes every global option documented by the
  installed Git CLI, including attached and separate values.
- **Lost quoted option values:** collapsing `git -C
  "$repo"` removed the repository argument, so `commit` was consumed as its
  value. Quoted arguments now retain their command-line position.
- **Option-shaped commit messages:** a message such as
  `git commit -m --dry-run` was mistaken for a dry-run flag. Non-mutating
  options are now interpreted only when they are not values.
- **Attached short-option values:** `git commit -mtest
  --dry-run` treated the dry-run flag as part of the message. Short option
  clusters now distinguish attached values from the following argument.
- **Rejected shell prefixes:** environment
  assignments and wrappers such as `env` hid valid commits. The detector now
  consumes assignments, execution wrappers, control-flow keywords, absolute Git
  paths, quoted executables, and continued command lines before checking Git.
- **Missed conditional branches:** `else git
  commit` stopped at the unrecognized `else` keyword. The detector now treats
  `else` like the other shell control-flow prefixes.
- **Missed absolute `env` paths:** `/usr/bin/env git commit` was ignored. Path-qualified `env` wrappers are now
  handled like the bare command.
- **Missed quoted Git paths:** a quoted executable
  such as `'/usr/bin/git'` was collapsed as an ordinary quoted argument. Quoted
  paths ending in `/git` are now normalized before other quoted text.
- **Suppressed branch-format commits:** `--branch`
  and `--ahead-behind` were incorrectly treated as non-mutating. Those
  formatting flags now retain real commits and trigger the hook.
- **Split shell substitutions:** grouping-character
  splitting broke `${REPO}` and `$(pwd)` arguments. The segment scanner now
  collapses expansions to one positional argument before splitting shell
  groups.
- **Misread `exec -c`:** Bash's environment-clearing
  `-c` flag was treated as value-taking and consumed the Git executable. `exec`
  flags and value options are now handled separately.
- **Missed attached `env` values:** forms such as
  `env -uHOME git commit` were ignored. Attached and separate short option
  values, plus combined short flags, are now consumed before the executable.
- **Hidden substitution commits:** `result=$(git commit ...)` executed a commit that the outer placeholder hid.
  Command substitutions are now scanned as their own command segments.
- **Missed standard wrappers:** `sudo`, `nice`, and
  `nohup` stopped executable detection. The detector now scans their options for
  the wrapped Git command.
- **Missed quoted subcommands:** `git "commit"` was
  collapsed as an arbitrary quoted value. Quoted single-word structural tokens
  are now normalized before ordinary quoted arguments.
- **Hidden shell command bodies:** `bash -c` and
  `sh -lc` command strings were collapsed as ordinary arguments. Standard shell
  command bodies are now extracted for normal segment scanning.
- **Lost empty arguments:** `''` and `""` vanished,
  shifting later Git options into value positions. Empty quoted arguments now
  retain a positional placeholder.
- **Split escaped whitespace:** `repo\ path` was
  split again by the downstream token scan. Escaped whitespace now becomes a
  single in-token placeholder.
- **Ignored option negations:** an earlier
  `--dry-run` or status format overrode a later `--no-*` flag in the detector,
  unlike Git. Non-mutating option state now follows command-line order.
- **Hidden backtick commits:** legacy backtick
  substitutions could execute an unseen commit. Backtick bodies are now scanned
  as executed command segments.
- **Hidden `env` split strings:** `env -S` and
  `env --split-string` stored the executed command in an option value. Those
  command strings are now scanned as executable shell input.
- **Rejected `env` option clusters:** a
  value-taking option after a flag, as in `env -iuHOME`, stopped detection.
  Short clusters are now parsed in order and consume attached or separate
  values correctly.
- **Rejected Windows executables:** explicit
  `git.exe` names were ignored in the documented Git for Windows setup. Bare
  and path-qualified Windows executable names now match Git.
- **Hidden configured shell bodies:** shell options
  before `-c` and POSIX shells such as `dash` hid executed command strings.
  Common shell executables now expose their command bodies after normal options.
- **Rejected leading redirections:** a redirection
  before Git was mistaken for the executable. Leading redirection operators and
  their separate or attached targets are now consumed first.
- **Hidden nested substitutions:** `${...}`
  expansions could contain an executed `$(...)` body that was never scanned.
  Nested command substitutions are now emitted recursively.
- **Collapsed quoted Windows paths:** quoted paths
  ending in `git.exe`, including paths with spaces, became placeholders. Those
  executables are now normalized before generic quoted arguments.
- **Rejected shell option terminators:** `--`
  between a shell's `-c` option and command string hid the executed body.
  Standard option terminators are now consumed before quoted command strings.
- **Rejected intermediate redirections:** shell
  redirections after the Git executable interrupted subcommand detection.
  Redirections and their targets are now removed before command parsing,
  regardless of their position.
- **Collapsed quoted shell paths:** quoted shell
  executables were normalized only after command-body extraction. Common quoted
  shell paths are now normalized first; combined flags containing `c` are also
  accepted.
- **Rejected append assignments:** a `+=`
  environment prefix stopped executable detection. Ordinary and append
  assignments now share one explicit prefix pattern.
- **Rejected GNU `time` options:** value-taking
  GNU `time` options were mistaken for the wrapped executable. GNU and macOS
  flags, attached values, and separate values are now consumed before Git.
- **Misread execution wrappers:** scanning ahead
  for any Git token after `sudo`, `nice`, or `nohup` both prompted on wrapped
  non-Git commands and mistook a `sudo` option value for the executable. Each
  wrapper now consumes its own options before selecting its actual command.
- **Non-commit Git commands:** Search, log, help, and dry-run commands could
  produce false prompts. Command-position and option-aware checks now ignore
  those cases, including commit status-format modes, while retaining real
  commits, amended commits, and chained commands.

## Pre-merge review

- **Truncated `bash -c` bodies:** The double-quoted `-c` body extraction used a
  quote class that stopped at the first escaped inner quote, silently dropping
  the rest of the command (and any `git commit` after it). It now matches the
  same escape-aware quote pattern already used elsewhere in the detector.
- **Lost empty-session-id guard:** The JSON rewrite dropped the check that
  exited when `session_id` was an empty string. An empty id no longer shares
  one state file across every caller that sends it; the hook exits before
  touching session state.
- **Silent Codex path became a hard failure:** Switching to `PLUGIN_ROOT`
  dropped the existence check around the hook script. A missing or unresolved
  `PLUGIN_ROOT` now exits quietly again instead of erroring.
- **Duplicated shell-name list:** The quoted shell-name stripping rules
  hardcoded the same alternation as `SHELL_EXECUTABLE_PATTERN`. Both now read
  from one `SHELL_NAMES` constant.
- **Duplicated short-option-cluster parsing:** The `env`, `sudo`, and `time`
  wrappers each inlined the same bundled short-option walk. One
  `short_cluster_consumes_next` function now backs all three, removing the
  class of bug where a fix to one copy was not mirrored in the others.
- **Duplicated option-set construction:** The option-lookup tables were each
  built with a hand-written `split` + loop. One `to_set` helper now builds all
  of them.
- **Wasted work on large payloads:** The JSON scanner and command tokenizer
  recomputed `length()` on every character instead of once per invocation; the
  coarse `commit`-substring precheck let obviously non-Git commands (like `npm
  run precommit`) into the parsing pipeline. Both are now cheaper.
- **Inaccurate session-limit docs:** The README credited the skill with
  enforcing the two-offer cap the hook actually enforces, risking its removal
  as "redundant" in the future.
- **Truncated `env -S` bodies:** The same escaped-quote truncation class fixed
  for `bash -c` also affected `env -S "..."`/`--split-string "..."` bodies;
  it now uses the same escape-aware quote pattern.
- **Colliding session ids:** A `session_id` containing an embedded newline
  was captured correctly but then split on the wrong newline downstream,
  truncating it and risking two different session ids sharing one state
  file. Newlines are now stripped from `session_id` as soon as it is parsed.
- **Loose hook-config regression tests:** The config-path tests added in the
  first pass only grepped for text fragments, so a broken `&&` guard or a
  wrong subdirectory would still pass. They now execute each config's
  command end-to-end against the real script and against a missing one.
- **Magic sentinel values:** `short_cluster_consumes_next`'s `-1`/`0`/`1`
  return values are now named constants (`CLUSTER_INVALID`,
  `CLUSTER_STOPS_HERE`, `CLUSTER_CONSUMES_NEXT`).
- Minor cleanup: derived `GLOBAL_ATTACHED_VALUE_OPTIONS` from
  `GLOBAL_SEPARATE_VALUE_OPTIONS` instead of retyping the shared options,
  used whole-array `delete` instead of a per-key loop, and added a comment
  to `to_set()` plus notes on the two short-option loops that intentionally
  do not use `short_cluster_consumes_next` (git's own global and commit
  options are not bundled the same way wrapper flags are).
- **Truncated command substitutions:** The `$(...)`/backtick extraction rule
  that rescues a substitution from being collapsed by the generic
  quote-collapse rule also used a non-escape-aware quote body, the same
  truncation class fixed twice already, for a command like
  `result="$(git commit -m \"nested message\")"`. It now uses the same
  escape-aware pattern.
- **Untested `matcher` field:** The hook-config regression tests checked the
  configured command but never the `matcher` field, so a config that
  stopped matching the `Bash` tool would still pass. Both configs' matchers
  are now asserted to cover `Bash`.
- **Fragile config-command extraction:** The test helper that pulls the
  `command` field out of each hook config only matched one exact
  formatting (single space after the colon, LF line endings). It now
  tolerates whitespace variation and strips `\r`.
- **Heredoc bodies read as commands:** Writing a script with
  `cat > file <<'EOF'` whose body contained `git commit` triggered a nudge and
  spent one of the session's two offers. Heredoc bodies are now dropped before
  detection, including `<<-` bodies and heredocs inside `sh -c` code, while
  `$(...)` and backticks in unquoted-delimiter bodies are still checked because
  the shell runs them. Here-strings and `$((1<<2))` are not mistaken for
  heredocs.
- **Multi-line quoted messages:** The quote-collapsing rules worked line by
  line, so `-h`, `--help`, or `--dry-run` on the first line of a multi-line
  `-m` message hid the commit. Quoted text spanning lines is now collapsed to
  one argument first, except when it holds a substitution or `sh -c`/`eval`
  code that may itself run a commit.
- **Missed `timeout` wrapper:** `timeout 30 git commit` was ignored. `timeout`
  and `gtimeout` options and the duration are now consumed before the command.
- **Quadratic JSON parsing:** Each string copied the rest of the payload, and
  decoding appended once per escape, so a late `session_id` or a heredoc with
  tens of thousands of escapes took seconds to a minute. Input is now split
  into records at quotes and decoded with whole-string substitutions, with
  `\u` escapes decoded last so a decoded backslash never starts an escape.

The hook detection and performance fixes have regression coverage in
`learning-opportunities-auto/hooks/test-post-tool-use.sh`, including checks
that the Claude Code and Codex hook configs still reference the hook script,
the correct plugin-root variable and matcher, and (for Codex) the
missing-script guard — verified by actually running each configured
command, not just grepping it.
