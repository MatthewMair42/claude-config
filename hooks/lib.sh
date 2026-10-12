# lib.sh — shared helpers for the PreToolUse hooks in this directory.
#
# Sourced, not run. Dependency-free (no jq, no Python) so hooks run under Git
# Bash on Windows and natively on macOS/Linux. Callers read stdin into $input
# before using json_str.

# First "key": "string" value in $input, JSON escapes left intact.
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

# The target path of a file tool call, normalized. Empty for other tools.
file_target() {
  local p
  p=$(json_str file_path)
  [ -z "$p" ] && p=$(json_str notebook_path)
  normalize "$p"
}

# Shell verbs that modify, move, or delete whatever they touch.
MODIFY_VERBS='(^|[^a-z0-9_-])(rm|rmdir|unlink|shred|truncate|mv|touch|tee|chmod|chown|attrib|ln|dd|del|erase|ren|rename|move|remove-item|rename-item|move-item|set-content|add-content|clear-content|out-file|new-item|set-itemproperty)([^a-z0-9_-]|$)'
INPLACE_EDIT='(sed|perl|ruby)[^;&|]*[[:space:]]-[a-z]*i'
GIT_WRITE='git[[:space:]]+(rm|mv|clean|restore|checkout)([^a-z]|$)'

# Emit an "ask" decision and stop. $1 = hook name, $2 = reason shown in the
# prompt. Keep reasons free of double quotes and backslashes (raw JSON).
ask() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"%s: %s"}}\n' "$1" "$2"
  exit 0
}
