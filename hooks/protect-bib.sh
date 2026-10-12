#!/usr/bin/env bash
# protect-bib.sh — PreToolUse hook: never modify a .bib file without asking.
#
# Bibliography entries are verified by hand. Claude proposes entry text in
# chat; the user checks it and makes the change. When a tool call would modify
# a .bib file, this hook returns "ask", so the user sees a permission prompt
# and can still approve a specific edit.
#
# Coverage:
#   Edit / Write / NotebookEdit / MultiEdit — exact: the target path is checked.
#   Bash / PowerShell — heuristic: the command text is scanned for a modifying
#     verb (rm, mv, sed -i, redirects, -o outputs, Remove-Item, ...) alongside
#     a .bib file. Reading (cat, grep, /validate-bib) and LaTeX builds
#     (bibtex/biber read the .bib and write a .bbl) pass untouched.
#
# Not covered: scripts that write a .bib internally. On any parse failure it
# exits 0 with no output, which leaves Claude Code's normal permission flow
# in place.

. "$(dirname "$0")/lib.sh" 2>/dev/null || exit 0
input=$(cat)

NAME=protect-bib
WHY='Bibliography entries are verified by hand: propose the exact entry text in chat instead. Approve only if you have checked this change.'
BIB='\.bib([^a-z0-9_]|$)'

tool=$(json_str tool_name)
case "$tool" in
  Edit|Write|MultiEdit|NotebookEdit)
    if file_target | grep -qE '\.bib$'; then
      ask $NAME "$tool targets a .bib file. $WHY"
    fi
    ;;

  Bash|PowerShell)
    cmd=$(normalize "$(json_str command)")
    printf '%s' "$cmd" | grep -qE "$BIB" || exit 0

    if printf '%s' "$cmd" | grep -qE "$MODIFY_VERBS"; then
      ask $NAME "The command modifies, moves, or deletes files and names a .bib file. $WHY"
    fi
    if printf '%s' "$cmd" | grep -qE "$INPLACE_EDIT"; then
      ask $NAME "The command edits files in place and names a .bib file. $WHY"
    fi
    if printf '%s' "$cmd" | grep -qE "$GIT_WRITE"; then
      ask $NAME "The command runs a git operation that can change files and names a .bib file. $WHY"
    fi
    # Output redirected into a .bib: `> refs.bib`, `>> "refs.bib"`.
    if printf '%s' "$cmd" | grep -qE ">>?[[:space:]]*[\"']?[^[:space:];&|]*$BIB"; then
      ask $NAME "The command redirects output into a .bib file. $WHY"
    fi
    # A tool told to write its output to a .bib (bibtool, pandoc, curl, ...).
    if printf '%s' "$cmd" | grep -qE "(^|[[:space:]])(-o|--output|-outfile|--outfile|-outputfile)([[:space:]]+|=)[\"']?[^[:space:];&|]*$BIB"; then
      ask $NAME "The command writes its output to a .bib file. $WHY"
    fi
    # Copy ONTO a .bib: the .bib is the last argument of a cp-like command, or
    # the -Destination of Copy-Item. Copying a .bib elsewhere stays allowed.
    if printf '%s' "$cmd" | grep -qE "(^|[^a-z0-9_-])(cp|copy|copy-item|rsync|install)[[:space:]][^;&|]*[[:space:]][\"']?[^[:space:];&|]*\.bib[\"']?[[:space:]]*($|[;&|])"; then
      ask $NAME "The command copies a file onto a .bib file. $WHY"
    fi
    if printf '%s' "$cmd" | grep -qE "(-destination|-dest)[[:space:]]+[\"']?[^[:space:];&|]*$BIB"; then
      ask $NAME "The command copies a file onto a .bib file. $WHY"
    fi
    ;;
esac

exit 0
