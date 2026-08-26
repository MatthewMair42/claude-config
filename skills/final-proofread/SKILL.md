---
name: final-proofread
description: |
  Final pre-submission proofreader for academic papers. Checks grammar/typos,
  undefined notation, figure/table cross-references, appendix references,
  placeholder text, LaTeX comment hygiene, and submission checklist items
  (abstract word count, JEL codes, acknowledgments). Produces a numbered
  fix-list — never edits files. Use as the last pass before journal submission.
  Trigger phrases: "final proofread", "proofread paper", "pre-submission check",
  "check my paper", "before I submit".
author: Matthew Mair
version: 1.0.0
allowed-tools: ["Read", "Glob", "Grep", "Bash", "Agent", "Write"]
---

# /final-proofread — Final Pre-Submission Proofreader

A comprehensive final pass before journal submission. Produces a single numbered
fix-list grouped by category and severity. **Never edits source files.**

> For the full pre-submission workflow including bibliography validation and compile
> check, use `/presubmit`. Run `/final-proofread` directly for a standalone prose
> and structure check only.

---

## PHASE 1: File Discovery

1. Glob for `**/*.tex` in the project root (exclude `.claude/`, `output/`, `correspondence/`).
   - If a single main `.tex` file is obvious (named `main.tex`, `paper.tex`, or contains
     `\documentclass`), use it as the primary file.
   - If multiple candidate files exist, ask the user which is the main manuscript before continuing.
2. Glob for `**/*.bib` — note the bibliography path for Phase 6.
3. Scan the main `.tex` file for appendix structure:
   - Look for `\appendix`, `\begin{appendix}`, or sections/chapters after `\appendix`.
   - Record all appendix section labels (`\label{...}` within or after `\appendix`).
4. Record all figure labels: `\label{fig:*}` or `\label{figure:*}`.
5. Record all table labels: `\label{tab:*}` or `\label{table:*}`.
6. Record all equation labels: `\label{eq:*}` or `\label{eqn:*}`.

---

## PHASE 2: Prose & LaTeX Polish (Proofreader Agent)

Dispatch the `proofreader` agent on the main `.tex` file. It will check:
- Grammar mistakes and typos
- Hedging language and weak constructions
- Notation consistency (same symbol used for two things; two symbols for the same thing)
- Overfull and underfull hboxes
- Claims-evidence alignment

Pass the main `.tex` file path to the agent explicitly. Collect its findings —
they will be folded into the final report under **Category A: Prose & LaTeX**.

---

## PHASE 3: Cross-Reference Checks

Perform these checks by reading the main `.tex` file and any included sub-files
(`\input{...}`, `\include{...}`). For multi-file projects, scan all included files.

### 3a. Figures not referenced in main text
- For each figure label found in Phase 1, check whether `\ref{<label>}` or
  `\autoref{<label>}` or `\cref{<label>}` appears in the **main body** (before `\appendix`).
- Flag any figure defined but never referenced in the main text as CRITICAL.
- Flag any figure referenced only in the appendix (not main body) as MINOR.

### 3b. Tables not referenced in main text
- Same logic as 3a, applied to table labels.

### 3c. Equations not referenced
- For each equation label, check whether it is ever `\ref`'d or `\eqref`'d anywhere
  in the document. A numbered equation that is never referenced may be unnecessary
  or may indicate a missing inline reference.
- Flag as MINOR.

### 3d. Appendix sections not referenced in main text
- For each appendix section label (from Phase 1), check whether it is `\ref`'d
  or `\autoref`'d anywhere in the **main body** (before `\appendix`).
- Flag any appendix section with no main-body reference as CRITICAL.

---

## PHASE 4: Placeholder & Hardcoded Reference Scan

Grep the `.tex` source files for each pattern below. Report file name and line number
for every match.

### 4a. Content placeholders (CRITICAL)
- `TODO`, `FIXME`, `\todo{`, `[TODO]`
- `[CITE]`, `\cite{}` (empty cite command), `cite needed`, `citation needed`
- `[INSERT]`, `[PLACEHOLDER]`, `[FILL]`, `[ADD]`
- `[?]`, `???`, `[TBD]`, `[TK]`
- Runs of `X` used as stand-ins: `XX`, `XXX`, `XXXX` (as standalone tokens, not within words)
- `[NUMBER]`, `[N]`, `[REF]`, `[FIG]`, `[TAB]`

### 4b. Undefined LaTeX cross-references (CRITICAL)
- The literal string `??` anywhere in the source — this is what appears when a
  `\ref{}`, `\cite{}`, or `\pageref{}` key is undefined. Any `??` in the source
  almost certainly means a missing label or bib key.

### 4c. Hardcoded figure/table/section references (MINOR — review manually)
- Patterns: `Figure [0-9]`, `Fig\. [0-9]`, `Table [0-9]`, `Appendix [A-Z0-9]`,
  `Section [0-9]`, `Equation [0-9]`, `Eq\. [0-9]`
- Also flag: `Figure X`, `Fig. X`, `Table X`, `Figure [X]`, `Table [X]`
- These *may* be intentional (e.g., "Figure 1 in Smith et al.") but should be
  reviewed — most should be `\ref{}` commands.
- Report each with line number and surrounding context (one line before and after).

### 4d. Orphaned `\ref{}` or `\label{}` calls
- Any `\ref{...}` whose key does not appear as a `\label{...}` anywhere in the project.
- Flag as CRITICAL (will produce `??` in compiled output).

---

## PHASE 5: LaTeX Comment Audit

Grep for comments and flag the following:

### 5a. Large commented-out blocks (MINOR)
- Three or more consecutive lines beginning with `%` that appear to be commented-out
  content (not standard header comments or package documentation).
- Report the line range and first line of content.

### 5b. Reminder/task comments (CRITICAL if action required, MINOR if informational)
- `% TODO`, `% FIXME`, `% NOTE:`, `% HACK`, `% REMOVE`, `% DELETE`,
  `% OLD`, `%% OLD`, `% CHECK`, `% REVISE`, `% UPDATE`
- Report each with line number.

### 5c. Commented-out `\cite{}` or `\ref{}` calls
- Any line containing `%.*\\cite{` or `%.*\\ref{` — these may indicate references
  that were temporarily removed and forgotten.
- Report as MINOR.

---

## PHASE 6: Submission Checklist

Read the abstract and preamble of the main `.tex` file.

### 6a. Abstract word count
- Extract the content of `\begin{abstract}...\end{abstract}`.
- Count words (excluding LaTeX commands).
- Report the count. Flag as CRITICAL if over 250 words (common journal hard limit);
  flag as MINOR if between 200–250 (remind user to check the target journal's limit).

### 6b. JEL codes
- Check whether JEL codes appear anywhere in the document
  (search for `JEL`, `jel`, `jelcodes`, `\jelcodes`, `J[A-Z][0-9]` patterns).
- Flag as MINOR if absent.

### 6c. Keywords
- Check for a keywords block (`Keywords:`, `\keywords{`, `key words`).
- Flag as MINOR if absent.

### 6d. Acknowledgments completeness
- Locate the acknowledgments section (search for `acknowledgment`, `acknowledgement`,
  `\section*{Acknowledgment`, `\thanks{`).
- If no acknowledgments section exists, flag as MINOR.
- If it exists, check for:
  - **Funding:** any grant number, NSF/NIH/foundation name, or funding language.
    Flag as MINOR if acknowledgments exist but no funding language found.
  - **IRB/ethics:** if the paper involves human subjects data, check for IRB, ethics
    board, or institutional review language. Flag as MINOR if absent.
  - **Data provider:** if the paper uses proprietary or licensed data, check for
    attribution. Flag as MINOR if no data acknowledgment found.
- Note: these are heuristic — the user must verify. Do not flag false positives for
  purely theoretical papers.

### 6e. Title and running head consistency
- Check whether `\title{}` and any `\shorttitle{}` or running head (`\markright`,
  `\rhead`, `\header`) are consistent (same title, not a leftover placeholder).

---

## PHASE 7: Compile Check

If `pdflatex` is available on the PATH, offer to run a compile check:

> "Run a compile check to catch undefined references and overfull hboxes? (yes/no)"

If yes:
- Run `pdflatex -interaction=nonstopmode <main-tex-file>` twice (to resolve references).
- Parse the log for:
  - `Undefined control sequence`
  - `Citation ... undefined`
  - `Reference ... undefined`
  - Overfull hbox (report in pt)
  - `LaTeX Warning: Label(s) may have changed`
- Fold any new findings into the report.

If no, skip silently.

---

## PHASE 8: Output Report

Compile all findings into a single report. Save to:
```
correspondence/final-proofread/report-YYYY-MM-DD.md
```
(Create `correspondence/final-proofread/` if it doesn't exist.)

### Report format

```markdown
# Final Proofreading Report — YYYY-MM-DD

**Paper:** [title from \title{}]
**Main file:** [path/to/main.tex]

---

## Summary

| Category | Critical | Minor |
|----------|----------|-------|
| A. Prose & LaTeX | N | N |
| B. Cross-References | N | N |
| C. Placeholders | N | N |
| D. LaTeX Comments | N | N |
| E. Submission Checklist | N | N |
| **Total** | **N** | **N** |

---

## A. Prose & LaTeX

[Findings from proofreader agent — grammar, typos, hedging, notation, hboxes]

---

## B. Cross-References

[CRITICAL / MINOR items from Phase 3]

---

## C. Placeholders & Hardcoded References

[CRITICAL / MINOR items from Phase 4]

---

## D. LaTeX Comments

[CRITICAL / MINOR items from Phase 5]

---

## E. Submission Checklist

[CRITICAL / MINOR items from Phase 6]

---

## F. Compile Log (if run)

[Findings from Phase 7]

---

*Generated by /final-proofread. No source files were modified.*
```

Each finding should be a numbered item within its category, formatted as:

```
N. [CRITICAL/MINOR] Short description — file.tex:line_number
   > [quoted line of source, if helpful]
```

After saving the report, display it in full in the terminal.

---

## Notes

- **Read-only:** this skill never modifies source files. All output goes to the report.
- **Multi-file projects:** for projects using `\input{}` or `\include{}`, scan all
  included files. Main-body vs. appendix distinction is based on position relative
  to `\appendix` command in the root file.
- **False positives:** Phase 4c (hardcoded references) will produce noise for papers
  that legitimately refer to "Table 2 in Smith (2020)". The user should review these
  manually — the skill flags them, not condemns them.
- **Severity guide:**
  - CRITICAL = will cause reader confusion, broken PDF, or desk rejection
  - MINOR = should be fixed before submission but won't sink the paper
