---
name: project-manager
description: |
  Broad-use project health scan. Assesses organization/file structure, naming
  conventions, version control hygiene, reproducibility, and long-term workflow
  sustainability. Auto-detects project type (research/data, software, or generic)
  and adapts checks accordingly. Report-only — never edits source files. Writes
  a dated suggestions document to correspondence/project-manager/.
  Trigger phrases: "project manager", "project health check", "assess this project",
  "project review".
author: Matthew Mair
version: 1.0.0
allowed-tools: ["Read", "Glob", "Grep", "Bash(git*)", "Write"]
argument-hint: "[project-path]"
---

# /project-manager — Project Health Scan

A big-picture audit of a project's organization, hygiene, and sustainability —
distinct from `/review-code` (per-script quality) and `/econometrics-check`
(identification validity). This skill never touches source files; it only
produces a suggestions report for the user to act on later.

---

## PHASE 0: Detect Project Type & Locate Root

1. **Root:** use `$ARGUMENTS` if given, else the current working directory.
2. **Classify the project** by checking for marker files/folders:

   | Type | Markers |
   |------|---------|
   | **Research/data** | `CLAUDE.md` + `data/` + (`code/R/` or `code/python/`) + `.claude/ACTION-ITEMS.md` |
   | **Software** | `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, or `tests/` |
   | **Generic** | none of the above strongly present |

   A project can match more than one loosely — pick the strongest match. If truly
   ambiguous, default to Generic and say so in the report header.

3. **Record** the detected type — it gates which checks in Phase 2 apply (noted
   inline below as `[Research]`, `[Software]`, `[Universal]`).

---

## PHASE 1: Gather

Read only what's needed — this is a survey, not a deep audit:

- Directory listing (`Glob` one or two levels deep; don't recurse into `node_modules/`,
  `.git/`, `renv/library/`, or similar dependency/cache trees)
- `git status` and `git log --oneline -20` (skip entirely if not a git repo — note that
  as a CRITICAL finding instead)
- `.gitignore` contents, if present
- `.claude/ACTION-ITEMS.md` and `.claude/logs/` file list with dates `[Research]`
- `README.md` (or `README*`) contents
- `data/dictionary.md` presence and row count `[Research]`
- Lightweight greps across code directories: hardcoded absolute paths (`C:/`, `/Users/`,
  `~/`), `set.seed(` occurrence count vs. script count `[Research]`
- Lockfile/env-spec presence check only — `renv.lock`, `requirements.txt`,
  `package-lock.json`/`pnpm-lock.yaml`, `environment.yml`, `Gemfile.lock` — existence only,
  not contents `[Software/Research]`

Do not open every file. Sample naming patterns from directory listings rather than
reading file contents unless a specific check requires it.

---

## PHASE 2: Assess

Produce findings in five categories. Tag every bullet with a priority:
**CRITICAL** (undermines correctness, safety, or recoverability of work),
**QUICK WIN** (small, concrete, no judgment call — e.g. add a missing folder,
fix a filename), or **OPTIONAL** (nice-to-have, stylistic, or long-horizon).

If a category has no findings, write "No issues found" under it rather than omitting
it — an empty category is itself informative.

### A. Organization & File Structure
- `[Research]` Compare top-level dirs against the `newproject` standard scaffold
  (`code/`, `data/{raw,clean}`, `output/{tables,figures}`, `documents/`,
  `correspondence/`, `decks/`, `notes/`, `.claude/`). Flag missing folders whose
  absence suggests disorganization (not every project needs every folder — use
  judgment, e.g. a project with no presentations doesn't need `decks/`).
- `[Universal]` Stray files sitting at project root that clearly belong in a
  subfolder (loose data files, loose scripts, loose PDFs).
- `[Research]` Evidence that `data/raw/` has been modified in place (e.g. file
  mtimes newer than corresponding `data/clean/` outputs — treat as a soft signal,
  not proof).

### B. Naming Conventions
- `[Universal]` Inconsistent casing/separators across similar files (mixing
  `snake_case`, `camelCase`, spaces, and hyphens within the same directory).
- `[Universal]` Duplicate/versioned-filename smells: patterns like `_v2`, `_final`,
  `_FINAL`, `_final_FINAL`, `(1)`, `(2)`, `copy of`, ` - Copy`. These indicate
  version control isn't being trusted to do its job.
- `[Research]` Scripts in `code/` missing numeric prefixes when siblings have them
  (breaks run-order clarity).

### C. Version Control
- `[Universal]` Not a git repo at all → CRITICAL.
- `[Universal]` Long-uncommitted working tree (many modified/untracked files with
  no recent commits) vs. evidence of active work (recent log entries, recent file
  mtimes).
- `[Universal]` `.gitignore` missing or missing obvious candidates (large data
  formats, OS cruft, credentials-looking filenames) while those file types exist
  untracked in the repo.
- `[Universal]` Large files tracked in git history that look like data/binaries
  (check `git ls-files` sizes lightly — don't do a full history scan).
- `[Research]` Commit activity that looks stale relative to `.claude/logs/`
  activity (sessions logged with no corresponding commits — work isn't being
  checkpointed).

### D. Reproducibility
- `[Research]` `data/dictionary.md` missing, empty, or clearly stale (e.g. row
  count far below what the data files would suggest).
- `[Research]` No dictionary-validator script (`00_validate_dictionary.R` or
  equivalent) despite a dictionary existing.
- `[Universal]` Hardcoded absolute paths found in code (from Phase 1 grep).
- `[Research]` `set.seed()` present in far fewer scripts than exist in `code/`
  (soft signal, not every script needs a seed — flag only if suspiciously absent
  project-wide).
- `[Software/Research]` No lockfile/environment spec found at all for a project
  that clearly has dependencies (e.g. library calls/imports present but no lock
  file) → QUICK WIN at minimum, CRITICAL if the project appears to be
  actively shared/collaborated on.

### E. Sustainability
- `[Research]` `.claude/ACTION-ITEMS.md` present but hasn't had a `[x]` completion
  in a long time relative to `.claude/logs/` activity (tracked but not maintained).
- `[Research]` `.claude/logs/` gap — most recent log file far older than the most
  recent git commit (session logging has lapsed).
- `[Universal]` `README.md` missing, or present but still containing obvious
  template placeholders (e.g. "Overview", "TBD", "[Project Name]").
- `[Universal]` `notes/` or equivalent scratch folder grown large/unsorted enough
  that it's unlikely to be useful to future-you.
- `[Universal]` No `CLAUDE.md`/config documenting project-specific conventions,
  in a project complex enough (many scripts/collaborators) that one would help.

---

## PHASE 3: Write Report

1. **Determine output path:**
   - If `correspondence/` exists: `correspondence/project-manager/project-manager_YY.MM.DD.md`
   - Else (generic/software project with no `correspondence/`): write to
     project root as `project-manager_YY.MM.DD.md` instead.
   - Create the `project-manager/` subfolder if it doesn't exist.
   - **If a report for today already exists**, append the current time:
     `project-manager_YY.MM.DD_HHMM.md` — never overwrite a same-day report.

2. **Report structure:**

   ```markdown
   # Project Health Scan — [project name] — YYYY-MM-DD

   Detected type: [Research / Software / Generic]

   ## Snapshot
   Organization: N issues | Naming: N | Version Control: N | Reproducibility: N | Sustainability: N

   ## Organization & File Structure
   - [CRITICAL/QUICK WIN/OPTIONAL] [finding]
   ...

   ## Naming Conventions
   ...

   ## Version Control
   ...

   ## Reproducibility
   ...

   ## Sustainability
   ...
   ```

3. Write the file (`Write` tool).

---

## PHASE 4: Summarize in Chat

After writing, print a short summary (not the full report) to the conversation:
- Detected project type
- The one-line snapshot
- The single highest-priority CRITICAL finding, if any
- The file path where the full report was saved

---

## Notes

- **Report-only.** This skill never edits `ACTION-ITEMS.md`, source files, or
  configuration. Findings are meant to be triaged and acted on manually
  afterward (optionally copied into `ACTION-ITEMS.md` by the user).
- **Broad use.** Works on any directory, not just projects scaffolded by
  `/newproject`. Research-specific checks (marked `[Research]`) are skipped
  entirely for Software/Generic projects rather than reported as absent.
- **Proportional judgment.** Not every missing folder or naming inconsistency is
  worth flagging — use the same proportionality principle as the `debugger`
  agent: a missing `.gitignore` entry that's actively causing tracked bloat is
  CRITICAL; a single oddly-cased filename is OPTIONAL at most.
- **Lightweight by design.** This is a survey pass, not a deep audit — sample
  rather than exhaustively read. For deep per-script review use `/review-code`;
  for identification/design validity use the `econometrician` agent via
  `/empirical-audit`.
