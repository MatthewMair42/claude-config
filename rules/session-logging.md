# Session Logging


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

**Scope:** This applies to all project directories (any directory with a `CLAUDE.md` or `.claude/` folder), plus the `~/.claude/` config project itself. For `~/.claude/`, the logs live at `~/.claude/logs/YYYY-MM-DD.md` and the action items file at `~/.claude/private/ACTION-ITEMS.md`, which is where the private repo keeps it.
