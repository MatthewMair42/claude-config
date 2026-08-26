---
name: compiletex
description: Compile LaTeX and report errors/warnings. Use after editing any .tex file.
allowed-tools: Bash(pdflatex*), Bash(latexmk*), Bash(ls*), Read, Glob
argument-hint: [tex-file-path]
source: mixtapetools
author: Scott Cunningham
adapted_by: Matthew Mair
adaptation: substantial
upstream_url: https://github.com/scunning1975/MixtapeTools/blob/main/.claude/commands/compiletex.md
last_synced: 2026-08-25
upstream_status: active upstream; unchanged since fork
---

# Compile LaTeX

Compile the specified .tex file and report all errors and warnings.

## Usage

The user provides a path to a .tex file (or you infer it from context).

## Steps

1. **Identify the .tex file**
   - If argument provided, use that path
   - If no argument, glob for `tex/*.tex`; use the single result, or ask if multiple found
   - Never guess — confirm if ambiguous

2. **Compile**

   Prefer `latexmk` (handles multi-pass and biber/bibtex automatically):
   ```bash
   cd [directory containing .tex file]
   latexmk -pdf -interaction=nonstopmode -halt-on-error [filename].tex
   ```

   If `latexmk` is unavailable, run manually (3 passes + bibliography):
   ```bash
   pdflatex -interaction=nonstopmode [filename].tex
   biber [filename]          # or bibtex [filename] if using bibtex
   pdflatex -interaction=nonstopmode [filename].tex
   pdflatex -interaction=nonstopmode [filename].tex
   ```

3. **Grep the log for issues**
   ```bash
   grep -n "^!" [filename].log                          # fatal errors
   grep -n "Overfull\\|Underfull" [filename].log        # hbox warnings
   grep -ni "warning" [filename].log                    # all warnings
   grep -n "undefined\|multiply defined" [filename].log # reference issues
   ```

4. **If fatal errors (`!`) exist:**
   - Show the error message and line number
   - Suggest a fix if obvious
   - Do not proceed until errors are resolved

5. **If warnings exist:**
   - List each `Overfull \hbox` with its line and severity (pt too wide)
   - List undefined references or citations
   - Suggest fixes (rephrase, adjust `\textwidth` fraction, add missing bib entry)
   - The goal is **zero warnings** — not "mostly clean"

6. **If clean:**
   - Report success and output PDF path
   - Confirm reference pass completed (no `??` in output)

## Example Output

```
✓ Compiled successfully: paper.pdf (3 passes + biber)

Warnings (2):
- Line 245: Overfull \hbox (15.2pt too wide) in paragraph
- Line 312: Citation 'Smith2020' undefined

No fatal errors.
```

## After Compilation

If there were warnings or errors, offer to fix them. The goal is a clean compile with zero warnings.
