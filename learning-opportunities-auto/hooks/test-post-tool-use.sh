#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
HOOK="$SCRIPT_DIR/post-tool-use.sh"
TEST_TMP=$(mktemp -d)
readonly LARGE_RESPONSE_BYTES=500000
readonly MAX_HOOK_SECONDS=3
readonly MANY_JSON_STRINGS=40000
trap 'rm -rf "$TEST_TMP"' EXIT

run_hook() {
  local payload="$1"

  TMPDIR="$TEST_TMP" bash "$HOOK" <<<"$payload"
}

assert_triggers() {
  local name="$1"
  local payload="$2"
  local output
  local status

  set +e
  output=$(run_hook "$payload")
  status=$?
  set -e

  if (( status != 0 )); then
    printf 'FAIL: %s hook exited with status %s\n' "$name" "$status" >&2
    exit 1
  fi
  if [[ "$output" != *hookSpecificOutput* ]]; then
    printf 'FAIL: %s should trigger\n' "$name" >&2
    exit 1
  fi
}

assert_ignores() {
  local name="$1"
  local payload="$2"
  local max_seconds="${3:-0}"
  local output
  local status
  local started_at=$SECONDS

  set +e
  output=$(run_hook "$payload")
  status=$?
  set -e

  if (( max_seconds && SECONDS - started_at > max_seconds )); then
    printf 'FAIL: %s took longer than %s seconds\n' "$name" "$max_seconds" >&2
    exit 1
  fi
  if (( status != 0 )); then
    printf 'FAIL: %s hook exited with status %s\n' "$name" "$status" >&2
    exit 1
  fi
  if [[ -n "$output" ]]; then
    printf 'FAIL: %s should be ignored, got: %s\n' "$name" "$output" >&2
    exit 1
  fi
}

assert_triggers \
  "official Codex payload" \
  '{"session_id":"trigger-basic","tool_name":"Bash","tool_input":{"command":"git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit after cd" \
  '{"session_id":"trigger-after-cd","tool_input":{"cmd":"cd repo && git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit after escaped newline" \
  '{"session_id":"trigger-after-escaped-newline","tool_input":{"cmd":"git add .\ngit commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit with global option" \
  '{"session_id":"trigger-global-option","tool_input":{"cmd":"git -C repo commit --amend"},"tool_response":{}}'

assert_triggers \
  "git commit with quoted global option value" \
  '{"session_id":"trigger-quoted-global-option","tool_input":{"cmd":"git -C \"$repo\" commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit with empty global option value" \
  '{"session_id":"trigger-empty-global-option","tool_input":{"cmd":"git -C \"\" commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit with escaped option whitespace" \
  '{"session_id":"trigger-escaped-option-space","tool_input":{"cmd":"git -C repo\\ path commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit with parameter expansion" \
  '{"session_id":"trigger-parameter-expansion","tool_input":{"cmd":"git -C ${REPO} commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit inside parameter expansion" \
  '{"session_id":"trigger-inside-parameter-expansion","tool_input":{"cmd":"result=${value:-$(git commit -m test)}"},"tool_response":{}}'

assert_triggers \
  "git commit with command substitution" \
  '{"session_id":"trigger-command-substitution","tool_input":{"cmd":"GIT_DIR=$(pwd)/.git git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit inside command substitution" \
  '{"session_id":"trigger-inside-command-substitution","tool_input":{"cmd":"result=$(git commit -m test)"},"tool_response":{}}'

assert_triggers \
  "git commit inside quoted command substitution" \
  '{"session_id":"trigger-inside-quoted-substitution","tool_input":{"cmd":"result=\"$(git commit -m test)\""},"tool_response":{}}'

assert_triggers \
  "git commit inside backtick substitution" \
  '{"session_id":"trigger-inside-backticks","tool_input":{"cmd":"result=`git commit -m test`"},"tool_response":{}}'

assert_triggers \
  "git commit with long global paths" \
  '{"session_id":"trigger-long-global-paths","tool_input":{"command":"git --git-dir=.git --work-tree=. commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit with separate global paths" \
  '{"session_id":"trigger-separate-global-paths","tool_input":{"command":"git --git-dir .git --work-tree . commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit with namespace" \
  '{"session_id":"trigger-namespace","tool_input":{"command":"git --namespace=testing commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit with config environment" \
  '{"session_id":"trigger-config-environment","tool_input":{"command":"git --config-env=user.email=EMAIL commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit with custom exec path" \
  '{"session_id":"trigger-exec-path","tool_input":{"command":"git --exec-path=/usr/lib/git-core commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit with environment assignment" \
  '{"session_id":"trigger-environment-assignment","tool_input":{"command":"GIT_EDITOR=true git commit --amend --no-edit"},"tool_response":{}}'

assert_triggers \
  "git commit with append assignment" \
  '{"session_id":"trigger-append-assignment","tool_input":{"command":"PATH+=:/custom/bin git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit through env" \
  '{"session_id":"trigger-env-wrapper","tool_input":{"command":"env GIT_AUTHOR_DATE=now git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit through absolute env path" \
  '{"session_id":"trigger-absolute-env-wrapper","tool_input":{"command":"/usr/bin/env git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit through attached env option" \
  '{"session_id":"trigger-attached-env-option","tool_input":{"command":"env -uHOME git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit through env split string" \
  '{"session_id":"trigger-env-split-string","tool_input":{"command":"env -S '\''git commit -m test'\''"},"tool_response":{}}'

assert_triggers \
  "git commit through attached env split string" \
  '{"session_id":"trigger-attached-env-split-string","tool_input":{"command":"env -S'\''git commit -m test'\''"},"tool_response":{}}'

assert_triggers \
  "git commit through long env split string" \
  '{"session_id":"trigger-long-env-split-string","tool_input":{"command":"env --split-string=\"git commit -m test\""},"tool_response":{}}'

assert_triggers \
  "git commit through attached env option cluster" \
  '{"session_id":"trigger-attached-env-cluster","tool_input":{"command":"env -iuHOME git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit through separate env option cluster" \
  '{"session_id":"trigger-separate-env-cluster","tool_input":{"command":"env -iu HOME git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit through command" \
  '{"session_id":"trigger-command-wrapper","tool_input":{"command":"command git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit through command options" \
  '{"session_id":"trigger-command-options","tool_input":{"command":"command -p -- git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit through exec clear environment" \
  '{"session_id":"trigger-exec-clear-environment","tool_input":{"command":"exec -c git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit through sudo" \
  '{"session_id":"trigger-sudo-wrapper","tool_input":{"command":"sudo -u user git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit through sudo with git user" \
  '{"session_id":"trigger-sudo-git-user","tool_input":{"command":"sudo -u git git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit through long sudo option" \
  '{"session_id":"trigger-sudo-long-user","tool_input":{"command":"sudo --user=git git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit through nice" \
  '{"session_id":"trigger-nice-wrapper","tool_input":{"command":"nice -n 5 git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit through attached nice option" \
  '{"session_id":"trigger-nice-attached","tool_input":{"command":"nice -n5 git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit through nohup" \
  '{"session_id":"trigger-nohup-wrapper","tool_input":{"command":"nohup git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit through shell wrapper" \
  '{"session_id":"trigger-shell-wrapper","tool_input":{"command":"bash -lc '\''git commit -m test'\''"},"tool_response":{}}'

assert_triggers \
  "git commit through configured shell wrapper" \
  '{"session_id":"trigger-configured-shell-wrapper","tool_input":{"command":"bash --noprofile -c '\''git commit -m test'\''"},"tool_response":{}}'

assert_triggers \
  "git commit through POSIX shell wrapper" \
  '{"session_id":"trigger-posix-shell-wrapper","tool_input":{"command":"dash -c '\''git commit -m test'\''"},"tool_response":{}}'

assert_triggers \
  "git commit through terminated shell options" \
  '{"session_id":"trigger-terminated-shell-options","tool_input":{"command":"bash -c -- '\''git commit -m test'\''"},"tool_response":{}}'

assert_triggers \
  "git commit through quoted shell executable" \
  '{"session_id":"trigger-quoted-shell-executable","tool_input":{"command":"\"/bin/bash\" -lc '\''git commit -m test'\''"},"tool_response":{}}'

assert_triggers \
  "git commit through combined shell options" \
  '{"session_id":"trigger-combined-shell-options","tool_input":{"command":"bash -cl '\''git commit -m test'\''"},"tool_response":{}}'

assert_triggers \
  "git commit through absolute path" \
  '{"session_id":"trigger-absolute-path","tool_input":{"command":"/usr/bin/git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit through Windows executable" \
  '{"session_id":"trigger-windows-executable","tool_input":{"command":"git.exe commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit through Windows executable path" \
  '{"session_id":"trigger-windows-executable-path","tool_input":{"command":"/mingw64/bin/git.exe commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit through quoted Windows executable path" \
  '{"session_id":"trigger-quoted-windows-path","tool_input":{"command":"\"C:/Program Files/Git/bin/git.exe\" commit -m test"},"tool_response":{}}'

assert_triggers \
  "escaped git executable" \
  '{"session_id":"trigger-escaped-git","tool_input":{"command":"\\git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit through time" \
  '{"session_id":"trigger-time-wrapper","tool_input":{"command":"time git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit through GNU time format" \
  '{"session_id":"trigger-gnu-time-format","tool_input":{"command":"/usr/bin/time -f '\''%e'\'' git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit through long GNU time format" \
  '{"session_id":"trigger-long-gnu-time-format","tool_input":{"command":"time --format=%e git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit in shell condition" \
  '{"session_id":"trigger-shell-condition","tool_input":{"command":"if git commit -m test; then echo yes; fi"},"tool_response":{}}'

assert_triggers \
  "git commit in else branch" \
  '{"session_id":"trigger-else-branch","tool_input":{"command":"if false; then :; else git commit -m test; fi"},"tool_response":{}}'

assert_triggers \
  "git commit after leading redirection" \
  '{"session_id":"trigger-leading-redirection","tool_input":{"command":"2>/tmp/commit.err git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit after separate leading redirection" \
  '{"session_id":"trigger-separate-redirection","tool_input":{"command":"> /tmp/commit.out git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit after descriptor redirection" \
  '{"session_id":"trigger-descriptor-redirection","tool_input":{"command":"2>&1 git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit with intermediate redirection" \
  '{"session_id":"trigger-intermediate-redirection","tool_input":{"command":"git 2>/tmp/commit.err commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit with redirection between global arguments" \
  '{"session_id":"trigger-global-argument-redirection","tool_input":{"command":"git -C 2>/tmp/commit.err repo commit -m test"},"tool_response":{}}'

assert_triggers \
  "quoted git executable" \
  '{"session_id":"trigger-quoted-git","tool_input":{"command":"\"git\" commit -m test"},"tool_response":{}}'

assert_triggers \
  "quoted commit subcommand" \
  '{"session_id":"trigger-quoted-commit","tool_input":{"command":"git \"commit\" -m test"},"tool_response":{}}'

assert_triggers \
  "quoted absolute git executable" \
  '{"session_id":"trigger-quoted-absolute-git","tool_input":{"command":"'\''/usr/bin/git'\'' commit -m test"},"tool_response":{}}'

assert_triggers \
  "continued git commit" \
  '{"session_id":"trigger-continued-command","tool_input":{"command":"git \\\ncommit -m test"},"tool_response":{}}'

assert_triggers \
  "dry-run as commit message" \
  '{"session_id":"trigger-dry-run-message","tool_input":{"cmd":"git commit -m --dry-run"},"tool_response":{}}'

assert_triggers \
  "help as combined short option value" \
  '{"session_id":"trigger-help-message","tool_input":{"cmd":"git commit -am --help"},"tool_response":{}}'

assert_triggers \
  "branch status in real commit" \
  '{"session_id":"trigger-branch-status","tool_input":{"cmd":"git commit -m test --branch"},"tool_response":{}}'

assert_triggers \
  "ahead status in real commit" \
  '{"session_id":"trigger-ahead-status","tool_input":{"cmd":"git commit -m test --ahead-behind"},"tool_response":{}}'

assert_triggers \
  "negated dry run in real commit" \
  '{"session_id":"trigger-negated-dry-run","tool_input":{"cmd":"git commit --dry-run --no-dry-run -m test"},"tool_response":{}}'

assert_triggers \
  "negated status format in real commit" \
  '{"session_id":"trigger-negated-status-format","tool_input":{"cmd":"git commit --porcelain --no-porcelain -m test"},"tool_response":{}}'

assert_triggers \
  "legacy cmd field" \
  '{"session_id":"trigger-cmd-field","tool_input":{"cmd":"git commit -m test"},"tool_response":{}}'

assert_triggers \
  "pretty JSON session id" \
  $'{\n  "session_id" : "trigger-pretty-json",\n  "tool_input" : { "cmd" : "git commit -m test" },\n  "tool_response" : {}\n}'

assert_triggers \
  "escaped JSON field and command" \
  '{"session_id":"trigger-escaped-json","tool_in\u0070ut":{"comm\u0061nd":"git\u0020commit -m test"},"tool_response":{}}'

assert_ignores \
  "output mentions git commit" \
  '{"session_id":"ignore-output","tool_input":{"cmd":"rg -n commit ."},"tool_response":{"stdout":"docs mention git commit here"}}'

assert_ignores \
  "nested response tool input after top-level tool input" \
  '{"session_id":"ignore-nested-tool-input-after","tool_input":{"command":"git status --short"},"tool_response":{"tool_input":{"command":"git commit -m bogus"}}}'

assert_ignores \
  "nested command inside tool input" \
  '{"session_id":"ignore-nested-command","tool_input":{"command":"git status --short","metadata":{"command":"git commit -m bogus"}},"tool_response":{}}'

assert_ignores \
  "incomplete tool input" \
  '{"session_id":"ignore-incomplete","tool_input":{"command":"git commit -m bogus"'

assert_ignores \
  "searching for git commit" \
  '{"session_id":"ignore-search","tool_input":{"cmd":"rg -n \"git commit\" ."},"tool_response":{}}'

assert_ignores \
  "echoing git commit" \
  '{"session_id":"ignore-echo","tool_input":{"cmd":"echo git commit"},"tool_response":{}}'

assert_ignores \
  "env runs echo with git arguments" \
  '{"session_id":"ignore-env-echo","tool_input":{"command":"env echo git commit"},"tool_response":{}}'

assert_ignores \
  "sudo runs search with git arguments" \
  '{"session_id":"ignore-sudo-search","tool_input":{"command":"sudo rg git commit ."},"tool_response":{}}'

assert_ignores \
  "nice runs echo with git arguments" \
  '{"session_id":"ignore-nice-echo","tool_input":{"command":"nice echo git commit"},"tool_response":{}}'

assert_ignores \
  "nohup runs echo with git arguments" \
  '{"session_id":"ignore-nohup-echo","tool_input":{"command":"nohup echo git commit"},"tool_response":{}}'

assert_ignores \
  "command queries git" \
  '{"session_id":"ignore-command-query","tool_input":{"command":"command -v git commit"},"tool_response":{}}'

assert_ignores \
  "quoted separator and git commit" \
  '{"session_id":"ignore-quoted-separator","tool_input":{"cmd":"echo \"; git commit\""},"tool_response":{}}'

assert_ignores \
  "escaped separator and git commit" \
  '{"session_id":"ignore-escaped-separator","tool_input":{"cmd":"echo foo\\; git commit"},"tool_response":{}}'

assert_ignores \
  "commented git commit" \
  '{"session_id":"ignore-commented-commit","tool_input":{"cmd":"echo hi # later; git commit -m test"},"tool_response":{}}'

assert_ignores \
  "git status with commit in output" \
  '{"session_id":"ignore-status","tool_input":{"cmd":"git status --short"},"tool_response":{"stdout":"nothing to commit, working tree clean"}}'

assert_ignores \
  "git log grep commit" \
  '{"session_id":"ignore-log-grep","tool_input":{"cmd":"git log --grep commit"},"tool_response":{}}'

assert_ignores \
  "git exec path query" \
  '{"session_id":"ignore-exec-path-query","tool_input":{"command":"git --exec-path commit"},"tool_response":{}}'

assert_ignores \
  "git commit help" \
  '{"session_id":"ignore-commit-help","tool_input":{"cmd":"git commit --help"},"tool_response":{}}'

assert_ignores \
  "git commit dry run" \
  '{"session_id":"ignore-commit-dry-run","tool_input":{"cmd":"git commit --dry-run"},"tool_response":{}}'

assert_ignores \
  "git commit dry run after message" \
  '{"session_id":"ignore-commit-dry-run-after-message","tool_input":{"cmd":"git commit -m test --dry-run"},"tool_response":{}}'

assert_ignores \
  "git commit dry run after attached message" \
  '{"session_id":"ignore-commit-dry-run-after-attached-message","tool_input":{"cmd":"git commit -mtest --dry-run"},"tool_response":{}}'

assert_ignores \
  "git commit dry run after empty message" \
  '{"session_id":"ignore-dry-run-empty-message","tool_input":{"cmd":"git commit -m \"\" --dry-run"},"tool_response":{}}'

assert_ignores \
  "git commit status format" \
  '{"session_id":"ignore-commit-status-format","tool_input":{"cmd":"git commit -m test --porcelain"},"tool_response":{}}'

assert_ignores \
  "response command before tool input" \
  '{"session_id":"ignore-response-command-first","tool_response":{"command":"git commit -m bogus"},"tool_input":{"command":"git status --short"}}'

assert_ignores \
  "nested command without tool input" \
  '{"session_id":"ignore-nested-command-without-tool-input","tool_response":{"command":"git commit -m bogus"}}'

assert_ignores \
  "nested tool input before top-level tool input" \
  '{"session_id":"ignore-nested-tool-input-first","tool_response":{"tool_input":{"command":"git commit -m bogus"}},"tool_input":{"command":"git status --short"}}'

large_response=$(awk -v size="$LARGE_RESPONSE_BYTES" 'BEGIN { printf "%*s", size, "" }')
assert_ignores \
  "large response before tool input" \
  '{"session_id":"ignore-large-response","tool_response":{"stdout":"'"$large_response"'"},"tool_input":{"command":"git status --short"}}' \
  "$MAX_HOOK_SECONDS"

assert_ignores \
  "large shell command" \
  '{"session_id":"ignore-large-command","tool_input":{"command":"git status '"$large_response"'"},"tool_response":{}}' \
  "$MAX_HOOK_SECONDS"

many_strings=$(awk -v count="$MANY_JSON_STRINGS" 'BEGIN { for (i = 1; i < count; i++) printf "\"ab\","; printf "\"ab\"" }')
assert_triggers \
  "session id after many response strings" \
  '{"tool_input":{"command":"git commit -m test"},"tool_response":{"items":['"$many_strings"']},"session_id":"trigger-late-session-id"}'
assert_ignores \
  "session id after many response strings, timed" \
  '{"tool_input":{"command":"git status"},"tool_response":{"items":['"$many_strings"']},"session_id":"ignore-late-session-id"}' \
  "$MAX_HOOK_SECONDS"

many_escapes=$(awk -v count="$MANY_JSON_STRINGS" 'BEGIN { for (i = 0; i < count; i++) printf "say \\\"hi\\\" -h\\n" }')
assert_triggers \
  "commit after large heredoc with many escapes" \
  '{"session_id":"trigger-large-heredoc","tool_input":{"command":"cat > notes <<EOF\n'"$many_escapes"'EOF\ngit commit -m test"},"tool_response":{}}'
assert_ignores \
  "large heredoc with many escapes, timed" \
  '{"session_id":"ignore-large-heredoc","tool_input":{"command":"cat > notes <<EOF\n'"$many_escapes"'EOF\ngit status"},"tool_response":{}}' \
  "$MAX_HOOK_SECONDS"

assert_ignores \
  "commit text inside heredoc body" \
  '{"session_id":"ignore-heredoc-body","tool_input":{"command":"cat > release.sh <<'\''EOF'\''\ngit add -A\ngit commit -m \"release\"\nEOF"},"tool_response":{}}'

assert_ignores \
  "commit text inside tab-stripped heredoc body" \
  '{"session_id":"ignore-heredoc-strip-body","tool_input":{"command":"cat <<-EOF > release.sh\n\tgit commit -m release\n\tEOF"},"tool_response":{}}'

assert_triggers \
  "commit after heredoc" \
  '{"session_id":"trigger-after-heredoc","tool_input":{"command":"cat > notes <<EOF\ndon'\''t\nEOF\ngit commit -m test"},"tool_response":{}}'

assert_triggers \
  "commit message from heredoc substitution" \
  '{"session_id":"trigger-heredoc-message","tool_input":{"command":"git commit -m \"$(cat <<'\''EOF'\''\nFix -h handling\n\nCo-Authored-By: x\nEOF\n)\""},"tool_response":{}}'

assert_triggers \
  "commit after here-string" \
  '{"session_id":"trigger-after-here-string","tool_input":{"command":"cat <<<\"hi\"\ngit commit -m test"},"tool_response":{}}'

assert_triggers \
  "commit after arithmetic shift" \
  '{"session_id":"trigger-after-arithmetic-shift","tool_input":{"command":"x=$((1<<2))\ngit commit -m test"},"tool_response":{}}'

assert_triggers \
  "multi-line message with help-shaped first line" \
  '{"session_id":"trigger-multiline-help-message","tool_input":{"command":"git commit -m \"Fix -h\nhandling\""},"tool_response":{}}'

assert_triggers \
  "multi-line single-quoted message with dry-run-shaped text" \
  '{"session_id":"trigger-multiline-dry-run-message","tool_input":{"command":"git commit -m '\''Fix --dry-run\nhandling'\''"},"tool_response":{}}'

assert_ignores \
  "dry run after multi-line message" \
  '{"session_id":"ignore-dry-run-after-multiline","tool_input":{"command":"git commit -m \"Fix\nhandling\" --dry-run"},"tool_response":{}}'

assert_ignores \
  "commit text inside multi-line quoted argument" \
  '{"session_id":"ignore-multiline-quoted-commit","tool_input":{"command":"echo \"notes\ngit commit -m test\n\""},"tool_response":{}}'

assert_triggers \
  "commit inside multi-line substitution" \
  '{"session_id":"trigger-multiline-substitution","tool_input":{"command":"echo \"$(\ngit commit -m test\n)\""},"tool_response":{}}'

assert_triggers \
  "commit inside multi-line bash -c" \
  '{"session_id":"trigger-multiline-bash-c","tool_input":{"command":"bash -c '\''\ngit commit -m test\n'\''"},"tool_response":{}}'

assert_triggers \
  "commit substitution in unquoted heredoc body" \
  '{"session_id":"trigger-heredoc-body-substitution","tool_input":{"command":"cat <<EOF\n$(git commit -m test)\nEOF"},"tool_response":{}}'

assert_ignores \
  "commit substitution in quoted heredoc body" \
  '{"session_id":"ignore-quoted-heredoc-body-substitution","tool_input":{"command":"cat <<'\''EOF'\''\n$(git commit -m test)\nEOF"},"tool_response":{}}'

assert_ignores \
  "commit text in heredoc inside multi-line bash -c" \
  '{"session_id":"ignore-bash-c-heredoc-body","tool_input":{"command":"bash -c '\''cat <<EOF\ngit commit -m test\nEOF'\''"},"tool_response":{}}'

assert_triggers \
  "commit after heredoc inside multi-line bash -c" \
  '{"session_id":"trigger-bash-c-after-heredoc","tool_input":{"command":"bash -c '\''cat <<EOF\nhi\nEOF\ngit commit -m test'\''"},"tool_response":{}}'

assert_triggers \
  "unicode-escaped backslash stays literal" \
  '{"session_id":"trigger-unicode-backslash","tool_input":{"command":"git commit -m x\u005ct--dry-run"},"tool_response":{}}'

assert_ignores \
  "unicode-escaped dry-run flag" \
  '{"session_id":"ignore-unicode-dry-run","tool_input":{"command":"git commit -m x \u002d-dry-run"},"tool_response":{}}'

assert_triggers \
  "git commit behind timeout" \
  '{"session_id":"trigger-timeout","tool_input":{"command":"timeout 30 git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit behind timeout with options" \
  '{"session_id":"trigger-timeout-options","tool_input":{"command":"timeout -k 5 --signal=TERM -v 30s git commit -m test"},"tool_response":{}}'

assert_triggers \
  "git commit behind gtimeout" \
  '{"session_id":"trigger-gtimeout","tool_input":{"command":"gtimeout -- 30 git commit -m test"},"tool_response":{}}'

assert_ignores \
  "timeout help" \
  '{"session_id":"ignore-timeout-help","tool_input":{"command":"timeout --help git commit"},"tool_response":{}}'

session_payload='{"session_id":"session-cap","tool_input":{"command":"git commit -m test"},"tool_response":{}}'
assert_triggers "first session offer" "$session_payload"
assert_triggers "second session offer" "$session_payload"
assert_ignores "third session offer" "$session_payload"

assert_ignores \
  "empty session id" \
  '{"session_id":"","tool_input":{"command":"git commit -m test"},"tool_response":{}}'

assert_triggers \
  "bash -c body with escaped inner quote" \
  '{"session_id":"escaped-quote-in-c-body","tool_input":{"command":"bash -c \"echo \\\"start\\\"; git commit -m done\""},"tool_response":{}}'

assert_triggers \
  "env -S body with escaped inner quote" \
  '{"session_id":"escaped-quote-in-env-s-body","tool_input":{"command":"env -S \"echo \\\"start\\\"; git commit -m done\""},"tool_response":{}}'

assert_triggers \
  "command substitution with escaped inner quote" \
  '{"session_id":"escaped-quote-in-command-subst","tool_input":{"command":"result=\"$(git commit -m \\\"nested message\\\")\""},"tool_response":{}}'

# Each hook config resolves the script via a plugin-root variable and a
# matcher. Rather than pattern-match the JSON, actually run the configured
# command so a wrong variable name, wrong subpath, or a broken
# missing-script guard fails here instead of only at runtime.
config_command() {
  tr -d '\r' <"$1" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p' | sed 's/\\"/"/g'
}

config_matcher() {
  tr -d '\r' <"$1" | sed -n 's/.*"matcher"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'
}

# Runs $1 as a shell command with $2 on stdin, printing its output and
# returning its exit status. Callers export any needed env vars by
# prefixing the call, e.g. `PLUGIN_ROOT=x run_command "$cmd" "$payload"`.
run_command() {
  local cmd="$1"
  local payload="$2"
  local status

  set +e
  bash -c "$cmd" <<<"$payload" 2>&1
  status=$?
  set -e
  return "$status"
}

plugin_root="$(cd -- "$SCRIPT_DIR/.." && pwd)"
trigger_payload='{"session_id":"config-check","tool_input":{"command":"git commit -m test"},"tool_response":{}}'

claude_matcher=$(config_matcher "$SCRIPT_DIR/hooks.json")
if [[ "$claude_matcher" != *Bash* ]]; then
  printf 'FAIL: hooks.json matcher %s does not cover the Bash tool\n' "$claude_matcher" >&2
  exit 1
fi

claude_command=$(config_command "$SCRIPT_DIR/hooks.json")
set +e
output=$(TMPDIR="$TEST_TMP" CLAUDE_PLUGIN_ROOT="$plugin_root" run_command "$claude_command" "$trigger_payload")
set -e
if [[ "$output" != *hookSpecificOutput* ]]; then
  printf 'FAIL: hooks.json command did not resolve to a working hook, got: %s\n' "$output" >&2
  exit 1
fi

codex_matcher=$(config_matcher "$SCRIPT_DIR/../hooks.codex.json")
if [[ "$codex_matcher" != *Bash* ]]; then
  printf 'FAIL: hooks.codex.json matcher %s does not cover the Bash tool\n' "$codex_matcher" >&2
  exit 1
fi

codex_command=$(config_command "$SCRIPT_DIR/../hooks.codex.json")
set +e
output=$(TMPDIR="$TEST_TMP" PLUGIN_ROOT="$plugin_root" run_command "$codex_command" "$trigger_payload")
set -e
if [[ "$output" != *hookSpecificOutput* ]]; then
  printf 'FAIL: hooks.codex.json command did not resolve to a working hook, got: %s\n' "$output" >&2
  exit 1
fi

missing_root="$TEST_TMP/no-such-plugin-root"
set +e
output=$(PLUGIN_ROOT="$missing_root" run_command "$codex_command" "$trigger_payload")
status=$?
set -e
if (( status != 0 )) || [[ -n "$output" ]]; then
  printf 'FAIL: hooks.codex.json command should no-op silently when PLUGIN_ROOT is missing, got status %s output: %s\n' "$status" "$output" >&2
  exit 1
fi

printf 'post-tool-use hook tests passed\n'
