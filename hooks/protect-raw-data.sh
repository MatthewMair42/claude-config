#!/usr/bin/env bash
# protect-raw-data.sh — PreToolUse hook: never modify data/raw/ without asking.
#
# Raw data is read-only by convention (see /newproject): it gets copied into
# data/clean/ and everything downstream happens in scripts. This hook makes
# that convention enforced rather than remembered. When a tool call would
# modify anything under a `data/raw/` folder, it returns "ask", so the user
# sees a permission prompt and can still approve a one-off override.
#
# Coverage:
#   Edit / Write / NotebookEdit / MultiEdit — exact: the target path is checked.
#   Bash / PowerShell — heuristic: the command text is scanned for a modifying
#     verb (rm, mv, sed -i, redirects, Remove-Item, ...) alongside data/raw.
#     Copying OUT of raw (`cp data/raw/x data/clean/`) passes untouched.
#
# Not covered: scripts that write to data/raw internally (e.g. an R script
# calling write.csv on a raw path). The hook sees only `Rscript clean.R`.
# Protect against that with filesystem permissions, not this hook.
#
# Deliberately dependency-free (no jq, no Python) so it runs under Git Bash on
# Windows and natively on macOS/Linux. On any parse failure it exits 0 with no
# output, which leaves Claude Code's normal permission flow in place.

input=$(cat)

# First "key": "string" value in the payload, JSON escapes left intact.
json_str() {
  printf '%s' "$input" \
    | grep -oE "\"$1\"[[:space:]]*:[[:space:]]*\"(\\\\.|[^\"\\\\])*\"" \
    | head -n 1 \
    | sed -E "s/^\"$1\"[[:space:]]*:[[:space:]]*\"//; s/\"\$//"
}

# Lowercase, unescape \" and \\, and turn every backslash into a slash so
# Windows and POSIX paths compare the same way.
normalize() {
  printf '%s' "$1" \
    | sed -e 's/\\"/"/g' -e 's/\\\\/\//g' -e 's/\\/\//g' \
    | tr '[:upper:]' '[:lower:]'
}

ask() {
  cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"protect-raw-data: $1 Raw data is never modified in place: copy it into data/clean/ and transform it there with a script. Approve only if this change to data/raw/ is intentional."}}
EOF
  exit 0
}

tool=$(json_str tool_name)
RAW='(^|[^a-z0-9_.-])data/raw(/|$|[^a-z0-9_.-])'

case "$tool" in
  Edit|Write|MultiEdit|NotebookEdit)
    path=$(json_str file_path)
    [ -z "$path" ] && path=$(json_str notebook_path)
    path=$(normalize "$path")
    if printf '%s' "$path" | grep -qE '(^|/)data/raw(/|$)'; then
      ask "$tool targets a file inside data/raw/."
    fi
    ;;

  Bash|PowerShell)
    cmd=$(normalize "$(json_str command)")
    printf '%s' "$cmd" | grep -qE "$RAW" || exit 0

    # Verbs that modify, move, or delete whatever they touch. Any of these in
    # a command that names data/raw is enough to ask.
    MODIFY='(^|[^a-z0-9_-])(rm|rmdir|unlink|shred|truncate|mv|touch|tee|chmod|chown|attrib|ln|dd|del|erase|ren|rename|move|remove-item|rename-item|move-item|set-content|add-content|clear-content|out-file|new-item|set-itemproperty)([^a-z0-9_-]|$)'
    INPLACE='(sed|perl|ruby)[^;&|]*[[:space:]]-[a-z]*i'
    GIT='git[[:space:]]+(rm|mv|clean|restore|checkout)([^a-z]|$)'

    if printf '%s' "$cmd" | grep -qE "$MODIFY"; then
      ask "The command modifies, moves, or deletes files and names data/raw/."
    fi
    if printf '%s' "$cmd" | grep -qE "$INPLACE"; then
      ask "The command edits files in place and names data/raw/."
    fi
    if printf '%s' "$cmd" | grep -qE "$GIT"; then
      ask "The command runs a git operation that can change files and names data/raw/."
    fi
    # Output redirected into raw: `> data/raw/x`, `>> "data/raw/x"`.
    if printf '%s' "$cmd" | grep -qE ">>?[[:space:]]*[\"']?[^[:space:];&|]*data/raw"; then
      ask "The command redirects output into data/raw/."
    fi
    # Copy INTO raw: raw path is the last argument of a cp-like command, or
    # the -Destination of Copy-Item. Copying out of raw stays allowed.
    if printf '%s' "$cmd" | grep -qE "(^|[^a-z0-9_-])(cp|copy|copy-item|rsync|install)[[:space:]][^;&|]*[[:space:]][\"']?[^[:space:];&|]*data/raw[^[:space:];&|]*[\"']?[[:space:]]*($|[;&|])"; then
      ask "The command copies files into data/raw/."
    fi
    if printf '%s' "$cmd" | grep -qE "(-destination|-dest)[[:space:]]+[\"']?[^[:space:];&|]*data/raw"; then
      ask "The command copies files into data/raw/."
    fi
    if printf '%s' "$cmd" | grep -qE "(^|[^a-z0-9_-])(robocopy|xcopy)[[:space:]]"; then
      ask "The command runs a bulk copy tool and names data/raw/."
    fi
    ;;
esac

exit 0
