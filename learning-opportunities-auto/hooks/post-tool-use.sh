#!/usr/bin/env bash
set -uo pipefail

# learning-opportunities-auto: PostToolUse hook (matches Bash tool)
#
# Fires after every Bash tool use. Checks whether the command was a
# `git commit` and, if so, suggests that Claude offer a learning exercise.
# The skill itself decides whether the commit's content is worth an
# exercise; this hook just provides the nudge at the right moment.
#
# No external dependencies beyond bash and standard Unix tools.

readonly ROOT_OBJECT_DEPTH=1
readonly TOOL_INPUT_KEY='tool_input'
readonly SESSION_ID_KEY='session_id'
readonly COMMAND_KEY='command'
readonly LEGACY_COMMAND_KEY='cmd'
readonly UNICODE_ESCAPE_HEX_LENGTH=4
readonly ASCII_CODE_POINT_LIMIT=128
readonly MAX_SESSION_OFFERS=2

# Parse only the direct command in tool_input. A single awk process avoids
# scanning large tool responses once the tool input is complete.
parse_hook_input() {
  LC_ALL=C awk \
    -v root_depth="$ROOT_OBJECT_DEPTH" \
    -v tool_input_key="$TOOL_INPUT_KEY" \
    -v session_id_key="$SESSION_ID_KEY" \
    -v command_key="$COMMAND_KEY" \
    -v legacy_command_key="$LEGACY_COMMAND_KEY" \
    -v unicode_hex_length="$UNICODE_ESCAPE_HEX_LENGTH" \
    -v ascii_code_point_limit="$ASCII_CODE_POINT_LIMIT" '
    function decoded_unicode(hex, code, j, digit) {
      if (length(hex) != unicode_hex_length || hex ~ /[^[:xdigit:]]/) return "?"
      code = 0
      for (j = 1; j <= unicode_hex_length; j++) {
        digit = index("0123456789abcdef", tolower(substr(hex, j, 1))) - 1
        code = code * 16 + digit
      }

      # \001 is the escaped-backslash placeholder in decoded_json.
      if (code == 1) return "?"
      return code < ascii_code_point_limit ? sprintf("%c", code) : "?"
    }

    # Concatenate pieces[low..high] in O(n log n) instead of appending one by
    # one, which copies the growing string each time.
    function joined(pieces, low, high, middle) {
      if (low > high) return ""
      if (low == high) return pieces[low]

      middle = int((low + high) / 2)
      return joined(pieces, low, middle) joined(pieces, middle + 1, high)
    }

    # Decode with whole-string substitutions so commands with thousands of
    # escapes stay linear. Escaped backslashes hide behind \001 until the end,
    # and \u escapes are decoded last, so decoded text never starts an escape.
    function decoded_json(raw, parts, count, part) {
      if (index(raw, "\\") == 0) return raw

      gsub(/\\\\/, "\001", raw)
      gsub(/\\[nr]/, "\n", raw)
      gsub(/\\t/, "\t", raw)
      gsub(/\\[bf]/, " ", raw)
      gsub(/\\"/, "\"", raw)
      gsub(/\\\//, "/", raw)
      if (index(raw, "\\u")) {
        count = split(raw, parts, /\\u/)
        for (part = 2; part <= count; part++) {
          parts[part] = decoded_unicode(substr(parts[part], 1, unicode_hex_length)) \
            substr(parts[part], unicode_hex_length + 1)
        }
        raw = joined(parts, 1, count)
      }
      gsub(/\001/, "\\", raw)
      return raw
    }

    function finish_string() {
      if (string_is_key) {
        key[depth] = decoded_json(value)
        expect_key[depth] = 0
        return
      }
      if (!capture_string) return

      value = decoded_json(value)

      if (depth == root_depth && key[depth] == session_id_key) {
        # session_id becomes the first line of this output; strip newlines
        # so an embedded one is never mistaken for that line split.
        gsub(/[\r\n]/, "", value)
        session_id = value
        found_session_id = 1
      } else if (depth == tool_input_depth && key[depth] == command_key) {
        command = value
        found_command = 1
      } else if (depth == tool_input_depth && key[depth] == legacy_command_key) {
        legacy_command = value
        found_legacy_command = 1
      }
    }

    function emit_input() {
      if (!found_session_id) return

      if (!found_command && found_legacy_command) {
        command = legacy_command
        found_command = 1
      }
      if (!found_command) exit

      print session_id
      printf "%s", command
      exit
    }

    function scan_structure(text, text_length, position, c, parent_depth) {
      text_length = length(text)
      for (position = 1; position <= text_length; position++) {
        c = substr(text, position, 1)

        if (c == "{") {
          parent_depth = depth
          depth++
          container[depth] = "object"
          expect_key[depth] = 1

          if (parent_depth == root_depth && key[parent_depth] == tool_input_key) {
            tool_input_depth = depth
          }
          continue
        }
        if (c == "[") {
          depth++
          container[depth] = "array"
          continue
        }
        if (c == "}" || c == "]") {
          if (depth == tool_input_depth) {
            tool_input_depth = 0
            tool_input_complete = 1
            emit_input()
          }

          delete container[depth]
          delete expect_key[depth]
          delete key[depth]
          depth--

          if (depth == 0 && tool_input_complete) emit_input()
          continue
        }
        if (c == "," && container[depth] == "object") {
          expect_key[depth] = 1
          delete key[depth]
        }
      }
    }

    # Records split at quotes alternate between JSON structure and string
    # contents, so each payload byte is copied once rather than once per string.
    BEGIN { RS = "\"" }

    in_string {
      if (capture_string) value_piece[++value_pieces] = $0

      # An odd run of trailing backslashes escapes the quote that ended this
      # record, so the string continues into the next one.
      if (match($0, /\\+$/) && RLENGTH % 2) {
        if (capture_string) value_piece[++value_pieces] = "\""
        next
      }

      in_string = 0
      value = joined(value_piece, 1, value_pieces)
      finish_string()
      if (tool_input_complete && found_session_id) emit_input()
      next
    }

    {
      scan_structure($0)

      string_is_key = container[depth] == "object" && expect_key[depth]
      capture_string = string_is_key ||
        (depth == root_depth && key[depth] == session_id_key) ||
        (depth == tool_input_depth &&
          (key[depth] == command_key || key[depth] == legacy_command_key))
      delete value_piece
      value_pieces = 0
      in_string = 1
    }
  '
}

PARSED_INPUT=$(parse_hook_input)
if [[ "$PARSED_INPUT" != *$'\n'* ]]; then
  exit 0
fi

SESSION_ID=${PARSED_INPUT%%$'\n'*}
COMMAND=${PARSED_INPUT#*$'\n'}

# An empty session id can't rate-limit per session, so treat it like no
# session id at all rather than sharing one state file across callers.
if [[ -z "$SESSION_ID" ]]; then
  exit 0
fi

# Heuristic hook detector. Collapse quoted text to one argument before splitting,
# so quoted command examples stay ignored without losing real argument positions.
git_commit_segments() {
  local -r ARGUMENT_PLACEHOLDER='__argument__'
  local -r SHELL_NAMES='bash|dash|ksh|sh|zsh'
  local -r SHELL_EXECUTABLE_PATTERN="([^[:space:]]*/)?(${SHELL_NAMES})"
  local -r ASSIGNMENT_PATTERN='^[[:alpha:]_][[:alnum:]_]*[+]?='
  local -r LEADING_REDIRECTION_PATTERN='^(&>>?|[0-9]*([<>]&|>>?|<<?|<>|>[|]))'
  local -r GLOBAL_FLAG_OPTIONS='-p -P --paginate --no-pager --no-replace-objects --no-lazy-fetch --no-optional-locks --no-advice --bare --literal-pathspecs --glob-pathspecs --noglob-pathspecs --icase-pathspecs'
  local -r GLOBAL_SEPARATE_VALUE_OPTIONS='--git-dir --work-tree --namespace --config-env --super-prefix --attr-source'
  local -r GLOBAL_ATTACHED_VALUE_OPTIONS="--exec-path ${GLOBAL_SEPARATE_VALUE_OPTIONS}"
  local -r GLOBAL_SHORT_VALUE_OPTIONS='-C -c'
  local -r SHELL_PREFIX_KEYWORDS='! if then elif else while until do'
  local -r ENV_FLAG_OPTIONS='-i -0 --ignore-environment --null --debug'
  local -r ENV_SHORT_FLAG_OPTIONS='i0v'
  local -r ENV_SHORT_VALUE_OPTIONS='uCSaP'
  local -r ENV_VALUE_OPTIONS='-u -C -S -a -P --unset --chdir --split-string --argv0'
  local -r SUDO_FLAG_OPTIONS='-A -b -B -E -H -k -n -P -S --askpass --background --bell --preserve-env --set-home --reset-timestamp --non-interactive --preserve-groups --stdin'
  local -r SUDO_SHORT_FLAG_OPTIONS='AbBEHknPS'
  local -r SUDO_SHORT_VALUE_OPTIONS='CDghpRrTtu'
  local -r SUDO_VALUE_OPTIONS='-C -D -g -h -p -R -r -T -t -u --close-from --chdir --group --host --prompt --chroot --role --command-timeout --type --user'
  local -r SUDO_NON_EXECUTING_OPTIONS='-e -K -l -U -V -v --edit --remove-timestamp --list --other-user --version --validate --help'
  local -r NICE_VALUE_OPTIONS='-n --adjustment'
  local -r WRAPPER_NON_EXECUTING_OPTIONS='--help --version'
  local -r TIME_FLAG_OPTIONS='-a -h -l -p -q -v --append --portability --quiet --verbose'
  local -r TIME_SHORT_FLAG_OPTIONS='ahlpqv'
  local -r TIME_SHORT_VALUE_OPTIONS='fo'
  local -r TIME_VALUE_OPTIONS='-f -o --format --output'
  local -r TIMEOUT_FLAG_OPTIONS='-f -p -v --foreground --preserve-status --verbose'
  local -r TIMEOUT_SHORT_FLAG_OPTIONS='fpv'
  local -r TIMEOUT_SHORT_VALUE_OPTIONS='ks'
  local -r TIMEOUT_VALUE_OPTIONS='-k -s --kill-after --signal'
  local -r VALUE_OPTIONS='-m -F -C -c -t --message --file --reuse-message --reedit-message --fixup --squash --template --author --date --cleanup --trailer --pathspec-from-file'
  local -r SHORT_VALUE_OPTIONS='mFCct'
  local -r HELP_OPTIONS='--help -h'
  local -r DRY_RUN_OPTIONS='--dry-run --dry'
  local -r STATUS_ONLY_OPTIONS='--short --porcelain --long --null -z'

  # The sed rules below see one line at a time, so first drop heredoc bodies
  # (keeping substitutions that an unquoted delimiter still runs) and collapse
  # quoted text that spans lines. Quotes holding substitutions or shell -c/eval
  # code stay intact and are lexed as code because they may run a commit.
  printf '%s\n' "$1" |
    awk -v argument_placeholder="$ARGUMENT_PLACEHOLDER" \
      -v shell_executable_pattern="$SHELL_EXECUTABLE_PATTERN" '
    function push(kind, position) {
      context[++depth] = kind
      opened_at[depth] = position
      decided[depth] = 0
      parentheses[depth] = 0
    }

    function pop(position) {
      if (collapsing && depth == collapse_depth) {
        output = collapse_prefix argument_placeholder
        chunk_start = position + 1
        collapsing = 0
      }
      depth--
    }

    # A substitution inside the collapsing quote means its text is code, so
    # restore the buffered lines and keep the quote verbatim.
    function abort_collapse(line_index) {
      for (line_index = 1; line_index < raw_count; line_index++) print raw[line_index]
      output = ""
      chunk_start = 1
      collapsing = 0
    }

    # Print the bodies of the command substitutions in text, one per line.
    function print_substitutions(text, text_length, position, c, start, parentheses_left) {
      text_length = length(text)
      for (position = 1; position <= text_length; position++) {
        c = substr(text, position, 1)
        if (c == "\\") {
          position++
          continue
        }
        if (c == "`") {
          start = position + 1
          for (position++; position <= text_length && substr(text, position, 1) != "`"; position++) {
            if (substr(text, position, 1) == "\\") position++
          }
          print substr(text, start, position - start)
          continue
        }
        if (c != "$" || substr(text, position + 1, 1) != "(" || substr(text, position + 2, 1) == "(") continue

        start = position + 2
        parentheses_left = 1
        for (position = start; position <= text_length; position++) {
          c = substr(text, position, 1)
          if (c == "\\") position++
          else if (c == "(") parentheses_left++
          else if (c == ")" && !--parentheses_left) break
        }
        print substr(text, start, position - start)
      }
    }

    # Queue the delimiter of the heredoc operator at position and return the
    # last position of its delimiter word. Inside shell -c code, the code
    # string ends the heredoc too, so remember its closing quote.
    function queue_heredoc(line, position, line_length, c, delimiter, strip, quote, quoted, level) {
      line_length = length(line)
      position += 2
      if (substr(line, position, 1) == "-") {
        strip = 1
        position++
      }
      while (substr(line, position, 1) ~ /[ \t]/) position++

      delimiter = ""
      for (; position <= line_length; position++) {
        c = substr(line, position, 1)
        if (c ~ /[[:space:];&|()<>]/) break
        if (c == "\\") {
          quoted = 1
          delimiter = delimiter substr(line, ++position, 1)
          continue
        }
        if (c == "\047" || c == "\"") {
          quoted = 1
          quote = c
          for (position++; position <= line_length && substr(line, position, 1) != quote; position++) {
            delimiter = delimiter substr(line, position, 1)
          }
          continue
        }
        delimiter = delimiter c
      }

      if (delimiter != "") {
        heredoc_delimiter[++heredoc_count] = delimiter
        heredoc_strip[heredoc_count] = strip
        heredoc_quoted[heredoc_count] = quoted
        heredoc_closer[heredoc_count] = ""
        for (level = depth; level; level--) {
          if (context[level] == "code_single") heredoc_closer[heredoc_count] = "\047"
          else if (context[level] == "code_double") heredoc_closer[heredoc_count] = "\""
          else continue
          break
        }
      }
      return position - 1
    }

    BEGIN {
      shell_code_pattern = "(^|[[:space:];&|(])(" shell_executable_pattern \
        "([[:space:]]+[^[:space:]]+)*[[:space:]]+-[[:alpha:]]*c[[:alpha:]]*([[:space:]]+--)?|eval)[[:space:]]+$"
    }

    in_heredoc {
      line = $0
      if (heredoc_strip[heredoc_index]) sub(/^\t+/, "", line)
      delimiter = heredoc_delimiter[heredoc_index]
      closer = heredoc_closer[heredoc_index]
      if (line != delimiter &&
          (closer == "" || substr(line, 1, length(delimiter) + 1) != delimiter closer)) {
        if (!heredoc_quoted[heredoc_index]) print_substitutions(line)
        next
      }

      if (++heredoc_index > heredoc_count) {
        in_heredoc = 0
        heredoc_count = 0
      }
      # Text after the delimiter closes the enclosing shell -c string.
      $0 = substr(line, length(delimiter) + 1)
      if (in_heredoc || $0 == "") next
    }

    {
      line = $0
      line_length = length(line)
      if (collapsing) {
        raw[++raw_count] = line
        chunk_start = 0
      } else {
        chunk_start = 1
      }

      for (position = 1; position <= line_length; position++) {
        c = substr(line, position, 1)
        next_c = substr(line, position + 1, 1)
        kind = depth ? context[depth] : ""

        if (kind == "single") {
          if (c == "\047") pop(position)
          continue
        }
        if (kind == "code_single" && c == "\047") {
          depth--
          continue
        }
        if (c == "\\") {
          position++
          continue
        }
        if (kind == "code_double" && c == "\"") {
          depth--
          continue
        }
        if (kind == "ansi") {
          if (c == "\047") pop(position)
          continue
        }
        if (kind == "double") {
          if (c == "\"") {
            pop(position)
            continue
          }
          if (c != "`" && !(c == "$" && next_c == "(")) continue
          if (collapsing && depth == collapse_depth) abort_collapse()
        }
        if (kind == "arithmetic") {
          if (c == "(") parentheses[depth]++
          else if (c == ")" && !--parentheses[depth]) depth--
          continue
        }

        if (c == "$" && next_c == "(") {
          if (substr(line, position + 2, 1) == "(") {
            push("arithmetic", position)
            parentheses[depth] = 2
            position += 2
          } else {
            push("substitution", position)
            parentheses[depth] = 1
            position++
          }
          continue
        }
        if (c == "`") {
          if (kind == "backtick") depth--
          else push("backtick", position)
          continue
        }
        if (kind == "substitution") {
          if (c == "(") parentheses[depth]++
          else if (c == ")" && !--parentheses[depth]) {
            depth--
            continue
          }
        }

        if (c == "#" && (position == 1 || substr(line, position - 1, 1) ~ /[[:space:];&|()]/)) break
        if (c == "\047" || c == "\"") {
          code = substr(line, 1, position - 1) ~ shell_code_pattern ? "code_" : ""
          push(code (c == "\047" ? "single" : "double"), position)
        }
        else if (c == "$" && next_c == "\047") {
          push("ansi", position)
          position++
        }
        else if (c == "<" && next_c == "<" && substr(line, position + 2, 1) != "<" &&
            substr(line, position - 1, 1) != "<") {
          position = queue_heredoc(line, position)
        }
      }

      # Quotes still open at the end of the line span lines. Collapse the
      # innermost one unless it holds a substitution; shell code quotes are
      # lexed as code instead and never match here.
      for (level = 1; !collapsing && level <= depth; level++) {
        if (decided[level] || context[level] !~ /^(single|double|ansi)$/) continue

        decided[level] = 1
        if (level < depth) continue

        collapsing = 1
        collapse_depth = level
        collapse_prefix = output substr(line, chunk_start, opened_at[level] - chunk_start)
        raw_count = 1
        raw[1] = output substr(line, chunk_start)
      }

      if (!collapsing) {
        print output substr(line, chunk_start)
        output = ""
      }
      if (heredoc_count) {
        in_heredoc = 1
        heredoc_index = 1
      }
    }

    END {
      if (collapsing) {
        for (line_index = 1; line_index <= raw_count; line_index++) print raw[line_index]
      }
    }' |
    sed -E \
      -e "s#(^|[[:space:]])(([^[:space:]]*/)?env[[:space:]]+([^'\";|&]+[[:space:]]+)*(-[^[:space:]'\";|&]*S|--split-string)(=|[[:space:]]+)?)'([^']*)'#\\1\\2$ARGUMENT_PLACEHOLDER; \\7#g" \
      -e "s#(^|[[:space:]])(([^[:space:]]*/)?env[[:space:]]+([^'\";|&]+[[:space:]]+)*(-[^[:space:]'\";|&]*S|--split-string)(=|[[:space:]]+)?)\"(([^\"\\\\]|\\\\.)*)\"#\\1\\2$ARGUMENT_PLACEHOLDER; \\7#g" \
      -e "s#(^|[[:space:]])'([^']*/)?(${SHELL_NAMES})'([[:space:]]|$)#\\1\\3\\4#g" \
      -e "s#(^|[[:space:]])\"([^\"\\\\]*/)?(${SHELL_NAMES})\"([[:space:]]|$)#\\1\\3\\4#g" \
      -e "s#(^|[[:space:]])(${SHELL_EXECUTABLE_PATTERN})([[:space:]]+[^[:space:]'\"]+)*[[:space:]]+-[[:alpha:]]*c[[:alpha:]]*[[:space:]]+(--[[:space:]]+)?'([^']*)'#\\1\\7#g" \
      -e "s#(^|[[:space:]])(${SHELL_EXECUTABLE_PATTERN})([[:space:]]+[^[:space:]'\"]+)*[[:space:]]+-[[:alpha:]]*c[[:alpha:]]*[[:space:]]+(--[[:space:]]+)?\"(([^\"\\\\]|\\\\.)*)\"#\\1\\7#g" \
      -e "s#(^|[[:space:]])'([^']*/)?git(\\.exe)?'([[:space:]]|$)#\\1git\\4#g" \
      -e "s#(^|[[:space:]])\"([^\"\\\\]*/)?git(\\.exe)?\"([[:space:]]|$)#\\1git\\4#g" \
      -e 's#(^|[[:space:]])\\git([[:space:]]|$)#\1git\2#g' \
      -e 's/"([^"\\]|\\.)*(\$\(([^"\\]|\\.)*\))([^"\\]|\\.)*"/\2/g' \
      -e 's/"([^"\\]|\\.)*(`([^"\\]|\\.)*`)([^"\\]|\\.)*"/\2/g' \
      -e "s/''/$ARGUMENT_PLACEHOLDER/g" \
      -e "s/\"\"/$ARGUMENT_PLACEHOLDER/g" \
      -e "s/'([^'[:space:]]*)'/\\1/g" \
      -e "s/\"([^\"[:space:]\\\\]*)\"/\\1/g" \
      -e "s/'[^']*'/$ARGUMENT_PLACEHOLDER/g" \
      -e "s/\\\\?\"([^\"\\\\]|\\\\.)*\\\\?\"/$ARGUMENT_PLACEHOLDER/g" |
    awk -v argument_placeholder="$ARGUMENT_PLACEHOLDER" '
    function emit_segments(text, c, next_c, segment, position, text_len,
      parenthesis_depth, brace_depth, expansion, command_substitution,
      nested_expansion, nested_depth) {
      segment = ""
      expansion = ""
      text_len = length(text)
      for (position = 1; position <= text_len; position++) {
        c = substr(text, position, 1)
        next_c = substr(text, position + 1, 1)

        if (!parenthesis_depth && !brace_depth && c == "$" &&
            (next_c == "(" || next_c == "{")) {
          segment = segment argument_placeholder
          if (next_c == "(") {
            parenthesis_depth = 1
            command_substitution = substr(text, position + 2, 1) != "("
          } else {
            brace_depth = 1
          }
          position++
          continue
        }

        if (!parenthesis_depth && c == "`") {
          expansion = ""
          for (position++; position <= text_len; position++) {
            c = substr(text, position, 1)
            next_c = substr(text, position + 1, 1)
            if (c == "\\" && position < text_len) {
              expansion = expansion c next_c
              position++
              continue
            }
            if (c == "`") break

            expansion = expansion c
          }

          segment = segment argument_placeholder
          emit_segments(expansion)
          expansion = ""
          continue
        }

        if (parenthesis_depth || brace_depth) {
          if ((brace_depth || !command_substitution) &&
              c == "$" && next_c == "(") {
            nested_expansion = ""
            nested_depth = 1
            position += 2
            for (; position <= text_len; position++) {
              c = substr(text, position, 1)
              next_c = substr(text, position + 1, 1)
              if (c == "\\" && position < text_len) {
                nested_expansion = nested_expansion c next_c
                position++
                continue
              }
              if (c == "(") nested_depth++
              else if (c == ")") {
                nested_depth--
                if (!nested_depth) break
              }

              nested_expansion = nested_expansion c
            }

            emit_segments(nested_expansion)
            nested_expansion = ""
            continue
          }

          if (c == "(") parenthesis_depth++
          else if (c == ")" && parenthesis_depth) {
            parenthesis_depth--
            if (command_substitution && !parenthesis_depth) {
              emit_segments(expansion)
              expansion = ""
              command_substitution = 0
              continue
            }
          }
          else if (c == "{") brace_depth++
          else if (c == "}" && brace_depth) brace_depth--

          if (command_substitution) expansion = expansion c
          continue
        }

        if (c == "\\" && position < text_len) {
          if (next_c ~ /[[:space:]]/) segment = segment argument_placeholder
          else segment = segment c next_c
          position++
          continue
        }
        if (c == "#" && (segment == "" || segment ~ /[[:space:]]$/)) {
          print segment
          return
        }
        if (c == "&" &&
            (next_c == ">" || segment ~ /[0-9]*[<>]$/)) {
          segment = segment c
          continue
        }
        if (index(";|&(){}", c)) {
          print segment
          segment = ""
          continue
        }

        segment = segment c
      }

      print segment
    }

    {
      if (continued) $0 = continued $0
      if (sub(/\\$/, "")) {
        continued = $0
        next
      }

      continued = ""
      emit_segments($0)
    }
    END { if (continued) emit_segments(continued) }' |
    awk -v global_flag_options="$GLOBAL_FLAG_OPTIONS" \
      -v global_separate_value_options="$GLOBAL_SEPARATE_VALUE_OPTIONS" \
      -v global_attached_value_options="$GLOBAL_ATTACHED_VALUE_OPTIONS" \
      -v global_short_value_options="$GLOBAL_SHORT_VALUE_OPTIONS" \
      -v assignment_pattern="$ASSIGNMENT_PATTERN" \
      -v shell_prefix_keywords="$SHELL_PREFIX_KEYWORDS" \
      -v leading_redirection_pattern="$LEADING_REDIRECTION_PATTERN" \
      -v env_flag_options="$ENV_FLAG_OPTIONS" \
      -v env_short_flag_options="$ENV_SHORT_FLAG_OPTIONS" \
      -v env_short_value_options="$ENV_SHORT_VALUE_OPTIONS" \
      -v env_value_options="$ENV_VALUE_OPTIONS" \
      -v sudo_flag_options="$SUDO_FLAG_OPTIONS" \
      -v sudo_short_flag_options="$SUDO_SHORT_FLAG_OPTIONS" \
      -v sudo_short_value_options="$SUDO_SHORT_VALUE_OPTIONS" \
      -v sudo_value_options="$SUDO_VALUE_OPTIONS" \
      -v sudo_non_executing_options="$SUDO_NON_EXECUTING_OPTIONS" \
      -v nice_value_options="$NICE_VALUE_OPTIONS" \
      -v wrapper_non_executing_options="$WRAPPER_NON_EXECUTING_OPTIONS" \
      -v time_flag_options="$TIME_FLAG_OPTIONS" \
      -v time_short_flag_options="$TIME_SHORT_FLAG_OPTIONS" \
      -v time_short_value_options="$TIME_SHORT_VALUE_OPTIONS" \
      -v time_value_options="$TIME_VALUE_OPTIONS" \
      -v timeout_flag_options="$TIMEOUT_FLAG_OPTIONS" \
      -v timeout_short_flag_options="$TIMEOUT_SHORT_FLAG_OPTIONS" \
      -v timeout_short_value_options="$TIMEOUT_SHORT_VALUE_OPTIONS" \
      -v timeout_value_options="$TIMEOUT_VALUE_OPTIONS" \
      -v value_options="$VALUE_OPTIONS" -v short_value_options="$SHORT_VALUE_OPTIONS" \
      -v help_options="$HELP_OPTIONS" -v dry_run_options="$DRY_RUN_OPTIONS" \
      -v status_only_options="$STATUS_ONLY_OPTIONS" '
      # Turn a space-separated option list into a lookup set for `in` checks.
      function to_set(str, set,    items, item) {
        split(str, items)
        for (item in items) set[items[item]] = 1
      }

      # Walk a bundled short-option cluster like "-abc" against a wrapper
      # flag/value char set. Returns CLUSTER_INVALID if the cluster is not
      # made entirely of known chars (caller falls through to its other
      # option checks), CLUSTER_STOPS_HERE if valid and the cluster does
      # not consume the next token, CLUSTER_CONSUMES_NEXT if it does (a
      # value char appeared last in the cluster).
      function short_cluster_consumes_next(token, flag_chars, value_chars,
        short_options, position, char_at) {
        if (token !~ /^-[^-]+$/) return CLUSTER_INVALID

        short_options = token
        sub(/^-/, "", short_options)
        for (position = 1; position <= length(short_options); position++) {
          char_at = substr(short_options, position, 1)
          if (index(flag_chars, char_at)) continue
          if (index(value_chars, char_at)) {
            return position == length(short_options) ? CLUSTER_CONSUMES_NEXT : CLUSTER_STOPS_HERE
          }
          return CLUSTER_INVALID
        }
        return CLUSTER_STOPS_HERE
      }

      BEGIN {
        CLUSTER_INVALID = -1
        CLUSTER_STOPS_HERE = 0
        CLUSTER_CONSUMES_NEXT = 1

        to_set(global_flag_options, global_flag_option)
        to_set(global_separate_value_options, global_separate_value_option)
        to_set(global_attached_value_options, global_attached_value_option)
        to_set(global_short_value_options, global_short_value_option)
        to_set(shell_prefix_keywords, shell_prefix_keyword)
        to_set(env_flag_options, env_flag_option)
        to_set(env_value_options, env_value_option)
        to_set(sudo_flag_options, sudo_flag_option)
        to_set(sudo_value_options, sudo_value_option)
        to_set(sudo_non_executing_options, sudo_non_executing_option)
        to_set(nice_value_options, nice_value_option)
        to_set(wrapper_non_executing_options, wrapper_non_executing_option)
        to_set(time_flag_options, time_flag_option)
        to_set(time_value_options, time_value_option)
        to_set(timeout_flag_options, timeout_flag_option)
        to_set(timeout_value_options, timeout_value_option)
        to_set(value_options, value_option)
        to_set(help_options, help_option)
        to_set(dry_run_options, dry_run_option)
        to_set(status_only_options, status_only_option)
      }

      {
        write_position = 1
        for (read_position = 1; read_position <= NF; read_position++) {
          token = $read_position
          if (token ~ leading_redirection_pattern) {
            redirection_target = token
            sub(leading_redirection_pattern, "", redirection_target)
            if (redirection_target == "") read_position++
            continue
          }

          $write_position = token
          write_position++
        }
        NF = write_position - 1

        i = 1
        while (i <= NF) {
          token = $i
          if (token ~ assignment_pattern ||
              token in shell_prefix_keyword) {
            i++
            continue
          }

          if (token == "env" || token ~ /\/env$/) {
            for (i++; i <= NF; i++) {
              token = $i
              if (token ~ assignment_pattern ||
                  token in env_flag_option) {
                continue
              }
              if (token in env_value_option) {
                i++
                continue
              }
              consumes_next = short_cluster_consumes_next(token, env_short_flag_options, env_short_value_options)
              if (consumes_next != CLUSTER_INVALID) {
                if (consumes_next) i++
                continue
              }

              option = token
              sub(/=.*/, "", option)
              if (option in env_value_option && token != option) continue
              if (token == "--") i++
              break
            }
            continue
          }

          if (token == "command") {
            i++
            if ($i == "-v" || $i == "-V") next
            if ($i == "-p") i++
            if ($i == "--") i++
            continue
          }

          if (token == "exec") {
            for (i++; i <= NF; i++) {
              if ($i ~ /^-[cl]+$/) continue
              if ($i == "-a") {
                i++
                continue
              }
              if ($i == "--") i++
              break
            }
            continue
          }

          wrapper = token
          sub(/^.*\//, "", wrapper)

          # Consume wrapper options before selecting the executed command.
          if (wrapper == "sudo") {
            for (i++; i <= NF; i++) {
              token = $i
              if (token in sudo_non_executing_option) next
              if (token in sudo_flag_option) continue
              if (token in sudo_value_option) {
                i++
                continue
              }

              option = token
              sub(/=.*/, "", option)
              if ((option in sudo_value_option ||
                  option == "--preserve-env") && token != option) continue

              consumes_next = short_cluster_consumes_next(token, sudo_short_flag_options, sudo_short_value_options)
              if (consumes_next != CLUSTER_INVALID) {
                if (consumes_next) i++
                continue
              }

              if (token == "--") i++
              break
            }
            continue
          }

          if (wrapper == "nice") {
            for (i++; i <= NF; i++) {
              token = $i
              if (token in wrapper_non_executing_option) next
              if (token in nice_value_option) {
                i++
                continue
              }

              option = token
              sub(/=.*/, "", option)
              if (option in nice_value_option && token != option) continue
              if (token ~ /^-n[+-]?[0-9]+$/) continue
              if (token ~ /^-[0-9]+$/) continue
              if (token == "--") i++
              break
            }
            continue
          }

          if (wrapper == "nohup") {
            i++
            if ($i in wrapper_non_executing_option) next
            if ($i == "--") i++
            continue
          }

          if (token == "time" || token ~ /\/time$/) {
            for (i++; i <= NF; i++) {
              token = $i
              if (token in time_flag_option) continue
              if (token in time_value_option) {
                i++
                continue
              }

              option = token
              sub(/=.*/, "", option)
              if (option in time_value_option && token != option) continue

              consumes_next = short_cluster_consumes_next(token, time_short_flag_options, time_short_value_options)
              if (consumes_next != CLUSTER_INVALID) {
                if (consumes_next) i++
                continue
              }

              if (token == "--") i++
              break
            }
            continue
          }

          # timeout (or coreutils gtimeout) takes a duration before the command.
          if (wrapper == "timeout" || wrapper == "gtimeout") {
            for (i++; i <= NF; i++) {
              token = $i
              if (token in wrapper_non_executing_option) next
              if (token in timeout_flag_option) continue
              if (token in timeout_value_option) {
                i++
                continue
              }

              option = token
              sub(/=.*/, "", option)
              if (option in timeout_value_option && token != option) continue

              consumes_next = short_cluster_consumes_next(token, timeout_short_flag_options, timeout_short_value_options)
              if (consumes_next != CLUSTER_INVALID) {
                if (consumes_next) i++
                continue
              }

              if (token == "--") i++
              break
            }
            i++
            continue
          }

          break
        }

        if (i > NF || $i !~ /(^|\/)git(\.exe)?$/) next

        # Global short options are never bundled with other flags (only
        # -C/-c take a value here), so this does not need the wrapper
        # cluster walk in short_cluster_consumes_next.
        for (i++; i <= NF && $i != "commit"; i++) {
          token = $i
          if (token in global_flag_option) continue

          if (token in global_separate_value_option) {
            i++
            continue
          }

          option = token
          sub(/=.*/, "", option)
          if (option in global_attached_value_option && token != option) continue

          if (token in global_short_value_option) {
            i++
            continue
          }
          if (token ~ /^-[Cc].+/) continue

          next
        }
        if (i > NF) next

        delete active_non_mutating
        expects_value = 0
        for (i++; i <= NF; i++) {
          token = $i
          if (expects_value) {
            expects_value = 0
            continue
          }
          if (token == "--") break
          if (token in help_option) next
          if (token in dry_run_option) {
            active_non_mutating["dry-run"] = 1
            continue
          }
          if (token in status_only_option) {
            state = token == "-z" ? "--null" : token
            active_non_mutating[state] = 1
            continue
          }
          if (token ~ /^--no-(dry-run|short|porcelain|long|null)$/) {
            state = token
            sub(/^--no-/, "--", state)
            if (state == "--dry-run") state = "dry-run"
            delete active_non_mutating[state]
            continue
          }

          option = token
          sub(/=.*/, "", option)
          if (option in value_option && token == option) {
            expects_value = 1
            continue
          }
          if (token !~ /^-[^-]+$/) continue

          # Unlike short_cluster_consumes_next, an unrecognized char here is
          # assumed to be a harmless commit flag rather than rejected: this
          # walk only needs to know whether the last char of the cluster
          # takes a value, not whether the whole token is a known option.
          short_options = token
          sub(/^-/, "", short_options)
          for (j = 1; j <= length(short_options); j++) {
            short_option = substr(short_options, j, 1)
            if (!index(short_value_options, short_option)) continue

            expects_value = (j == length(short_options))
            break
          }
        }

        for (state in active_non_mutating) next
        matched = 1
        print
      }

      END { exit !matched }'
}

if [[ "$COMMAND" != *commit* || "$COMMAND" != *git* ]] || ! git_commit_segments "$COMMAND" >/dev/null; then
  exit 0
fi

# Cap automatic nudges per session. The skill separately suppresses offers
# after a decline or two completed exercises.
STATE_FILE="${TMPDIR:-/tmp}/lo_auto_${SESSION_ID//[^a-zA-Z0-9_-]/_}.state"

offers=0
if [[ -f "$STATE_FILE" ]]; then
  offers=$(<"$STATE_FILE")
fi
if [[ ! "$offers" =~ ^[0-9]+$ ]]; then
  offers=0
fi
if (( offers >= MAX_SESSION_OFFERS )); then
  exit 0
fi

printf '%s\n' "$(( offers + 1 ))" >"$STATE_FILE"

# ---------------------------------------------------------------------------
# Emit suggestion for Claude via structured JSON. PostToolUse hooks must
# output JSON with hookSpecificOutput on exit 0 to inject context.
# The message contains no special characters that need escaping.
# ---------------------------------------------------------------------------

cat <<'HOOK_JSON'
{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"[learning-opportunities-auto] The user just ran a git commit command. If it succeeded, use the learning-opportunities skill to consider whether this is a good moment to offer a learning exercise. If the committed work involved new files, schema changes, architectural decisions, refactors, or unfamiliar patterns, ask the user (one short sentence) if they'd like a 10-15 minute exercise. Do not start the exercise until they confirm. If they decline, note it — no more offers this session."}}
HOOK_JSON

exit 0
