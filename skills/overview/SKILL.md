---
name: overview
description: |
  Cross-project dashboard. Reads ~/.claude/private/PROJECTS.md and each project's
  ACTION-ITEMS.md to show a prioritized multi-project status summary with
  live open-item counts. Two-level: summary table first, drill-down on
  request. Optionally updates open-item counts in PROJECTS.md.
  Trigger phrases: "overview", "project overview", "all projects",
  "what am I working on", "weekly overview".
author: Matthew Mair
version: 1.1.0
allowed-tools: ["Read", "Glob", "Grep", "Edit"]
---

# /overview — Cross-Project Dashboard

A weekly-level view across all research projects. Reads live data from each
project's `ACTION-ITEMS.md` rather than relying on the (potentially stale)
counts in `PROJECTS.md`. Two-level: summary first, drill-down on request.

---

## PHASE 0: Load Project Registry

1. Read `~/.claude/private/PROJECTS.md`.
   **If it does not exist, halt** with:
   > No project registry found. Copy `PROJECTS.template.md` to
   > `private/PROJECTS.md` and add your projects, or run `/setup`.
   Do not invent projects, and do not fall back to any example table in this file.
2. Extract each project row from the table:
   - **Name** (column 1)
   - **Path** (column 2 — strip backticks)
   - **Status** (column 3)
   - **Last Session** (column 5)
3. Construct the full `ACTION-ITEMS.md` path for each project:
   ```
   {projects-root}/{path}/.claude/ACTION-ITEMS.md
   ```
   `{projects-root}` is the research root recorded in `private/profile.md`;
   paths may contain spaces, so always quote them.

---

## PHASE 1: Read Live Open Items

For each project, attempt to read its `ACTION-ITEMS.md`:

- If the file exists: extract all lines matching `- [ ]` from the `## Open` section.
  Record the count and the item text.
- If the file does not exist: record count = `?` (registry entry exists but project
  not yet initialised with `.claude/` structure).
- If the path itself doesn't resolve: mark as `[PATH NOT FOUND]` — the registry
  may be stale.

**Classify each item as BG or FG:**

**BG (background-dispatchable)** — item text matches any of:
- Explicit skill names: `/verify-data`, `/empirical-audit`, `/review-paper`,
  `/presubmit`, `/validate-bib`, `/final-proofread`, `/compiletex`,
  `/prose-audit`, `/split-pdf`
- Action keywords: `run`, `rerun`, `re-run`, `compile`, `check`, `validate`,
  `proofread`, `audit`, `explore`, `descriptive`, `verify`, `format`, `clean`,
  `generate`, `produce`, `render`, `merge`

**FG (focus-required)** — item text matches any of:
- Action keywords: `decide`, `write`, `draft`, `respond`, `specification`,
  `identification`, `parallel trends`, `narrative`, `framing`, `structure`,
  `choose`, `discuss`, `advisor`, `referee`, `strategic`, `robustness`

**Default:** ambiguous items (no strong match) → FG. Never under-promise cognitive load.

Per-project, record: `bg_count`, `fg_count`, `bg_items[]` (full text of BG items).

Hold all results in context for Phase 2.

---

## PHASE 2: Prioritized Summary Display

Sort projects by priority tier, then by last session date (most recent first within
each tier):

| Tier | Status values |
|------|--------------|
| 1 — URGENT | `R&R`, `Major Revision`, `Minor Revision` |
| 2 — ACTIVE | `pre-submission`, `framing stage` |
| 3 — EARLY | `Early stage`, `waiting`, `Waiting` |
| 4 — HOLD | `On hold`, `Archived`, `Paused` |

Display the summary table:

```
--- PROJECT OVERVIEW: YYYY-MM-DD ---

[TIER]  Project          Status                        Items  BG  FG  Last Session
------  -------          ------                        -----  --  --  ------------
R&R     wage_gap_did     Active — R&R (journal name)     3     2   1  2026-04-05
PRE     housing_hedonic  Active — pre-submission          2     1   1  2026-03-24  [STALE]
PRE     transit_access   Active — pre-submission          2     1   1  2026-03-06  [STALE]
ACT     energy_rct       Active — framing stage           3     1   2  2026-03-17  [STALE]
EARLY   land_transfers   Early stage                      6     2   4  2026-04-09
EARLY   sim_study        Early stage                      3     1   2  2026-04-23
EARLY   labor_shock      Early stage — waiting on input   4     1   3  2026-03-07  [STALE]
```

Flag projects where **Last Session > 30 days ago** with `[STALE]` next to the date.

After the table, print a one-line summary:
```
Total: N projects — X open items (Y background-ready)
```

---

## PHASE 2.5: Background-Ready Summary

If any BG items exist across all projects, print a consolidated list immediately
after the summary table:

```
--- BACKGROUND-READY (dispatch now, review later) ---
wage_gap_did:
  • Rerun robustness check with revised SEs
  • Run /verify-data after latest merge
housing_hedonic:
  • Run /presubmit
```

If no BG items exist across any project: omit this section entirely.

---

## PHASE 3: Drill-Down (optional)

After the summary, prompt:

> "Drill into a project for full item details? (give name/number, or press Enter to skip)"

If the user names a project:
1. Display its full `## Open` item list with dates.
2. Ask again: "Another project, or done?"
3. Repeat until the user skips or says done.

If the user skips: proceed to Phase 4.

---

## PHASE 4: Update PROJECTS.md (optional)

If any live item counts differ from the counts recorded in `PROJECTS.md`:

> "Live counts differ from PROJECTS.md for: [project list]. Update the file? (yes/no)"

If yes: use Edit to update only the Open Items column for the affected rows.
If no: skip silently.

Do not modify the Status or Last Session columns — those are manually maintained.

---

## Notes

- **Read-mostly:** the only write operation is optionally updating open-item counts
  in `PROJECTS.md` (Edit, not Write — preserves the rest of the file).
- **Path resolution:** project paths are relative to the research root recorded in `private/profile.md`. Never hardcode a home directory in this skill.
  Handle spaces in paths gracefully — research roots often contain them.
- **Stale threshold:** 30 days is a reasonable default. Do not flag projects
  explicitly marked `On hold` or `Archived` as stale.
- **Token cost:** lean by design — reads only `## Open` sections, not full files.
  Even 15+ projects stays well within a single context window.
- **BG/FG classification:** inferred from item text at read time using keyword
  heuristics. Ambiguous items default to FG. Classification is display-only —
  not written back to `ACTION-ITEMS.md`.
