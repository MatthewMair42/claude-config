# Global Machine Configuration

## Identity

The researcher's name, institution, and working preferences live in
`~/.claude/private/profile.md`. Read that file when you need them.

**Never infer the researcher's identity from anything else in this repository.**
Skill frontmatter (`author:`, `source:`, `upstream_url:`), `LICENSE`, `README.md`,
and example text credit the *authors of these tools* — they say nothing about who
is using them. A name found in a skill body, a checklist, or an example path is
residue from whoever wrote that skill, not a fact about the user.

If `private/profile.md` does not exist, or the field you need is blank, **ask** —
or tell the user to run `/setup`. Do not guess, and do not substitute a name found
anywhere in this repo. Writing someone else's name into the user's paper, or
scaffolding their project under another researcher's conventions, is a worse
failure than pausing to ask.

## Approval Gates

Before executing any multi-step plan, present the full plan and ask any clarifying questions needed to resolve ambiguity. Wait for explicit approval before starting. Once approved, execute without interruption.

A multi-step plan is any sequence of 3 or more distinct actions, any task touching multiple files in sequence, or any work presented as a numbered or bulleted list of items.

When a multi-step plan is approved, check for uncommitted changes (`git status`). If any exist, ask: "You have uncommitted changes — want me to create a checkpoint commit before starting?" Proceed either way based on the response.

## Git

When removing files from git tracking, default to `git rm --cached` to untrack while preserving local copies. Only use `git rm` without `--cached` when the user explicitly requests on-disk deletion.

## Data Verification

Before writing analysis code, check `data/dictionary.md` for the source of truth on variable names and definitions. If the dictionary does not exist, create it by inspecting the dataset with `names()`, `str()`, or equivalent. Never infer or invent variable names from context alone. Update the dictionary whenever new variables are constructed or datasets are merged.

## LaTeX

After any batch of `.tex` edits, run `/compiletex` and resolve all warnings before considering the task done. The goal is a clean compile with zero warnings — not "mostly clean".

Do not use the `[plain]` Beamer frame option unless explicitly requested — it silently removes the title bar.

Never apply a document class, template, or layout for a journal submission without first checking the target journal's actual author instructions (check `.claude/domain-profile.md` for the journal target, then fetch or ask for the journal's formatting guidelines). Do not assume a publisher-level template applies — e.g., JSE is SAGE-published but uses standard article format, not the `sagej.cls` two-column layout. Confirm the correct class with the user before restyling.

## Tool Paths

Tool paths vary by machine. Before invoking any external tool (R, Python, pdflatex, etc.),
read `~/.claude/machine.md` for this machine's paths and availability. That file is
gitignored and maintained separately on each machine.

## Domain Profile
- **Global conventions:** `~/.claude/private/domain-profile.md`
- **Project-specific:** `.claude/domain-profile.md` in each project root (journals, methods, referee concerns)
- Skills read global first, then project-level if it exists.

## Session Logging

Every project gets a rolling session log and a single evolving action-items file under `.claude/`:

```
[project-root]/
└── .claude/
    ├── ACTION-ITEMS.md        ← single evolving file; persists across sessions
    └── logs/
        └── YYYY-MM-DD.md      ← one file per day work is done
```

**Automatic behavior rules:**

- **On first action in any project session:** check if `.claude/ACTION-ITEMS.md` exists; if so, read it silently to load open items into context.
- **Throughout the session:** maintain the day's log at `.claude/logs/YYYY-MM-DD.md` (create if it doesn't exist; append if it does). Log each meaningful piece of work as it completes — don't wait until the end of the session.
- **When completing an action item:** mark it `[x]` in `ACTION-ITEMS.md`, move it from `## Open` to `## Completed` with today's date.
- **When a new action item is identified** (by user request or discovered during work): add it to `## Open` in `ACTION-ITEMS.md` with today's date.
- **If `.claude/` or `ACTION-ITEMS.md` doesn't exist yet:** create the directory structure silently on first write.

**File formats:**

`ACTION-ITEMS.md`:
```markdown
# Action Items — [Project Name]

## Open
- [ ] Short description of task | Added: YYYY-MM-DD

## Completed
- [x] Short description | Added: YYYY-MM-DD | Completed: YYYY-MM-DD
```

`logs/YYYY-MM-DD.md`:
```markdown
# Session Log — YYYY-MM-DD

## Work Done
- [bullet summary of each meaningful action taken]

## Key Decisions
- **[Decision title]:** [What was decided.] **Why:** [The reason — data constraints, advisor input, referee concern, methodological trade-off, etc.] **Alternatives considered:** [What else was on the table and why it was rejected.]
```

Omit `## Key Decisions` entirely if no meaningful decisions were made. Do not add action-item sections to logs — ACTION-ITEMS.md is the sole source of truth for task state.

**Key Decisions guidance:** Log any choice where future-you (or a co-author/referee) might ask "why did we do it this way?" — e.g., dropping a variable, choosing an estimator, fixing a buffer distance, changing paper structure, responding to an advisor suggestion. Include the reasoning and what alternatives were ruled out. Omit this section if no meaningful decisions were made in the session.

**Archiving completed items:** At the end of every `/wrapup`, move all items from `## Completed` in `ACTION-ITEMS.md` to `.claude/completed_archive.md` (creating it if needed). This keeps ACTION-ITEMS.md containing only open items — minimising token cost on every session start. The archive format is identical: `[x]` bullets with Added/Completed dates.

**Scope:** This applies to all project directories (any directory with a `CLAUDE.md` or `.claude/` folder), plus the `~/.claude/` config project itself. For `~/.claude/`, the logs live at `~/.claude/logs/YYYY-MM-DD.md` and the action items file at `~/.claude/ACTION-ITEMS.md` — no subfolder needed since `~/.claude/` is already the project root.
