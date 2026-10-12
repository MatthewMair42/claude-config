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
# On any parse failure it exits 0 with no output, which leaves Claude Code's
# normal permission flow in place.

. "$(dirname "$0")/lib.sh" 2>/dev/null || exit 0
input=$(cat)

NAME=protect-raw-data
WHY='Raw data is never modified in place: copy it into data/clean/ and transform it there with a script. Approve only if this change to data/raw/ is intentional.'
RAW='(^|[^a-z0-9_.-])data/raw(/|$|[^a-z0-9_.-])'

tool=$(json_str tool_name)
case "$tool" in
  Edit|Write|MultiEdit|NotebookEdit)
    if file_target | grep -qE '(^|/)data/raw(/|$)'; then
      ask $NAME "$tool targets a file inside data/raw/. $WHY"
    fi
    ;;

  Bash|PowerShell)
    cmd=$(normalize "$(json_str command)")
    printf '%s' "$cmd" | grep -qE "$RAW" || exit 0

    if printf '%s' "$cmd" | grep -qE "$MODIFY_VERBS"; then
      ask $NAME "The command modifies, moves, or deletes files and names data/raw/. $WHY"
    fi
    if printf '%s' "$cmd" | grep -qE "$INPLACE_EDIT"; then
      ask $NAME "The command edits files in place and names data/raw/. $WHY"
    fi
    if printf '%s' "$cmd" | grep -qE "$GIT_WRITE"; then
      ask $NAME "The command runs a git operation that can change files and names data/raw/. $WHY"
    fi
    # Output redirected into raw: `> data/raw/x`, `>> "data/raw/x"`.
    if printf '%s' "$cmd" | grep -qE ">>?[[:space:]]*[\"']?[^[:space:];&|]*data/raw"; then
      ask $NAME "The command redirects output into data/raw/. $WHY"
    fi
    # Copy INTO raw: raw path is the last argument of a cp-like command, or
    # the -Destination of Copy-Item. Copying out of raw stays allowed.
    if printf '%s' "$cmd" | grep -qE "(^|[^a-z0-9_-])(cp|copy|copy-item|rsync|install)[[:space:]][^;&|]*[[:space:]][\"']?[^[:space:];&|]*data/raw[^[:space:];&|]*[\"']?[[:space:]]*($|[;&|])"; then
      ask $NAME "The command copies files into data/raw/. $WHY"
    fi
    if printf '%s' "$cmd" | grep -qE "(-destination|-dest)[[:space:]]+[\"']?[^[:space:];&|]*data/raw"; then
      ask $NAME "The command copies files into data/raw/. $WHY"
    fi
    if printf '%s' "$cmd" | grep -qE "(^|[^a-z0-9_-])(robocopy|xcopy)[[:space:]]"; then
      ask $NAME "The command runs a bulk copy tool and names data/raw/. $WHY"
    fi
    ;;
esac

exit 0
