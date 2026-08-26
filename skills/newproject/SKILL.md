---
name: newproject
description: Scaffold a new research project with standard directory structure, CLAUDE.md template, and documented README. Use this at the start of every new project to ensure consistent organization.
allowed-tools: Bash(mkdir*), Bash(cp*), Bash(ls*), Write, Read
argument-hint: [project-name]
source: mixtapetools
author: Scott Cunningham
adapted_by: Matthew Mair
adaptation: substantial
upstream_url: https://github.com/scunning1975/MixtapeTools/blob/main/.claude/skills/newproject/SKILL.md
last_synced: 2026-08-25
upstream_status: active upstream; unchanged since fork
local_changes: >
  Removed progress_logs/ (superseded by the .claude/logs/ session-logging system);
  removed code/stata/ (R and Python only); added step 3b scaffolding
  data/dictionary.md and code/R/00_validate_dictionary.R; added step 6
  scaffolding .claude/ACTION-ITEMS.md and logs/ with a first session log;
  registers the new project in private/PROJECTS.md.
---

# New Project Scaffold

Create a new research project folder with the researcher's standard structure. This skill is invoked at the start of every project.

## What Gets Created

```
[project-name]/
├── CLAUDE.md              # Permanent research rules (copied from template)
├── README.md              # Project-specific overview (auto-generated)
├── .claude/
│   ├── ACTION-ITEMS.md    # Evolving task list; persists across sessions
│   └── logs/              # Per-day session logs (YYYY-MM-DD.md)
├── code/
│   ├── R/
│   │   └── 00_validate_dictionary.R  # Validates dictionary vs data/clean/ columns
│   └── python/
├── data/
│   ├── raw/               # Original source data (never modify)
│   ├── clean/             # Cleaned/merged datasets
│   └── dictionary.md      # Source of truth for all variable names and definitions
├── output/
│   ├── tables/
│   └── figures/
├── documents/             # Outside PDFs, papers (use /split-pdf on these)
├── correspondence/        # Referee reports, responses, reviews, pre-analysis plans
├── decks/                 # Beamer presentations (rhetoric of decks)
└── notes/                 # Scratch notes, random ideas, misc
```

## Execution

1. **Get the project name** from the argument. If none provided, ask.
   - Convert spaces to hyphens, lowercase

2. **Determine location** — default is current working directory. Confirm if unclear.

3. **Create all directories:**
   ```bash
   mkdir -p [project-name]/{code/{R,python},data/{raw,clean},output/{figures,tables},documents,correspondence,decks,notes,.claude/logs}
   touch [project-name]/.claude/logs/.gitkeep
   ```

3b. **Scaffold data dictionary and validator:**

   Create `data/dictionary.md`:
   ```markdown
   # Data Dictionary — [Project Name]

   Update this file whenever new variables are constructed, datasets are merged, or column names change.
   Run `code/R/00_validate_dictionary.R` to check coverage against `data/clean/`.

   | Variable | Type | Source | Description | Notes |
   |----------|------|--------|-------------|-------|
   ```

   Create `code/R/00_validate_dictionary.R`:
   ```r
   # Validates that all columns in data/clean/ are documented in data/dictionary.md
   # Run this at the top of any analysis session or pipeline

   dict_path <- "data/dictionary.md"
   if (!file.exists(dict_path)) {
     stop("data/dictionary.md not found. Create it before running analysis.")
   }

   lines <- readLines(dict_path)
   data_rows <- lines[grepl("^\\|", lines) &
                      !grepl("^\\|[-|]+\\|", lines) &
                      !grepl("Variable", lines)]
   dict_vars <- trimws(sapply(strsplit(data_rows, "\\|"), function(x) x[2]))
   dict_vars  <- dict_vars[nchar(dict_vars) > 0]

   clean_files <- list.files("data/clean", pattern = "\\.(rds|csv)$", full.names = TRUE)
   if (length(clean_files) == 0) {
     message("No datasets in data/clean/ — skipping validation.")
     quit(status = 0)
   }

   issues <- list()
   for (f in clean_files) {
     df      <- if (grepl("\\.rds$", f)) readRDS(f) else read.csv(f, nrows = 0)
     missing <- setdiff(names(df), dict_vars)
     if (length(missing) > 0) issues[[basename(f)]] <- missing
   }

   if (length(issues) > 0) {
     stop(
       "DATA DICTIONARY OUT OF DATE — update data/dictionary.md before proceeding:\n\n",
       paste(mapply(function(file, vars) {
         paste0("  ", file, ": ", paste(vars, collapse = ", "))
       }, names(issues), issues), collapse = "\n")
     )
   } else {
     message("Dictionary check passed — all columns documented.")
   }
   ```

4. **Copy CLAUDE.md** from `~/.claude/CLAUDE.md`:
   - This copies the full global machine config including all behavioral rules (Identity, Approval Gates, Git, Data Verification, LaTeX, Session Logging, Tool Paths)
   - No placeholder substitution needed — Identity section points at private/profile.md

5. **Generate README.md** with:
   - Project title
   - Visual directory tree in a fenced code block (monospace)
   - Explanation of each folder's purpose
   - Note that CLAUDE.md is copied from a permanent template and edited per-project
   - Note that README.md is for project-specific documentation
   - Note that `.claude/logs/` maintains session continuity across Claude conversations
   - Placeholder sections: Overview, Collaborators, Status, Key Files

   The README must include this tree block:

   ````markdown
   ```
   [project-name]/
   ├── CLAUDE.md              # Research rules & estimation philosophy (permanent)
   ├── README.md              # This file — project-specific notes
   ├── .claude/
   │   ├── ACTION-ITEMS.md    # Open and completed tasks (auto-maintained)
   │   └── logs/              # Per-day session logs for Claude continuity
   ├── code/
   │   ├── R/                 # R scripts (00_validate_dictionary.R checks data coverage)
   │   └── python/            # Python scripts
   ├── data/
   │   ├── raw/               # Original source data (never modify these)
   │   ├── clean/             # Cleaned and merged datasets
   │   └── dictionary.md      # Source of truth for all variable names and definitions
   ├── output/
   │   ├── tables/            # Generated tables (LaTeX, CSV)
   │   └── figures/           # Generated figures (PDF, PNG)
   ├── documents/             # Outside papers and PDFs (split with /split-pdf)
   ├── correspondence/        # Referee reports, responses, code reviews, PAPs
   ├── decks/                 # Beamer presentations (rhetoric of decks philosophy)
   └── notes/                 # Scratch notes, ideas, miscellaneous
   ```
   ````

6. **Scaffold `.claude/` session-logging structure** — create `.claude/ACTION-ITEMS.md`:
   ```markdown
   # Action Items — [Project Name]

   ## Open

   ## Completed
   ```
   Then create the first session log at `.claude/logs/YYYY-MM-DD.md`:
   - Record the creation date under `## Work Done`
   - List next steps under `## Key Decisions` if any structural choices were made

7. **Update `~/.claude/private/PROJECTS.md`** — add a new row to the projects table:
   ```
   | [project-name] | `[relative path from your research root]` | Early stage | 0 | YYYY-MM-DD |
   ```
   Use today's date. Status defaults to "Early stage". Confirm the row was added.

8. **Report success** — show structure with `ls`, remind user to:
   - Update CLAUDE.md and fill in the project's status in `PROJECTS.md`
   - Run `/verify-data` after populating `data/clean/` to generate the first verification report and baseline N state
