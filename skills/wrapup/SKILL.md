---
name: wrapup
description: |
  End-of-session closing ritual. Archives completed action items, checks git state,
  and catches anything missed before closing. Use at the end of any work session.
  Trigger phrases: "wrapup", "wrap up", "end session", "close out".
author: Matthew Mair
version: 2.0.0
allowed-tools: ["Read", "Glob", "Grep", "Bash", "Edit", "Write"]
disable-model-invocation: true
---

# /wrapup — End-of-Session Protocol

---

## PHASE 1: Load & Archive (no user input)

1. Read `.claude/ACTION-ITEMS.md` and today's log at `.claude/logs/YYYY-MM-DD.md`
   (use today's actual date). If neither file exists, say so and stop.

2. **Immediately archive completed items:** Move every item under `## Completed` in
   `ACTION-ITEMS.md` to `.claude/completed_archive.md` (create if it doesn't exist).
   Preserve the full line including Added/Completed dates. Leave the `## Completed`
   section header in place but empty. Do this silently — no output to the user.

---

## PHASE 2: Git (one combined prompt if action needed)

1. Run `git status` and `git log --oneline -5` in the project root.
2. If not a git repository: skip silently.
3. If the branch is clean and synced with the remote: note "Git is clean." and continue.
4. If there are uncommitted changes **or** unpushed commits: show a brief status summary
   and ask **one combined question**:

   > "You have [uncommitted changes / N unpushed commits / both].
   > Commit message (leave blank to skip): ___
   > Push to origin/[branch]? (yes/no)"

5. Based on the single response: commit (if a message was given), then push (if yes).
   Confirm success after each git operation.

---

## PHASE 3: Catch-all (single open-ended question)

Ask once:

> "Anything I missed? (undocumented decisions, new action items, or anything else
> to log before we close)"

- If the user provides **decisions:** append each to `## Key Decisions` in today's log
  using the standard format:
  `- **[Decision title]:** [What was decided.] **Why:** [The reason.] **Alternatives considered:** [What was ruled out.]`
  If the log has no `## Key Decisions` section, add it before appending.
- If the user provides **new action items:** add each to `## Open` in `ACTION-ITEMS.md`
  with today's date.
- If nothing: continue immediately.

---

## PHASE 4: Summary (no user input)

Print:

```
--- SESSION WRAP-UP ---
Date: YYYY-MM-DD
Git: [clean / committed / pushed / uncommitted changes remaining]
```

If the project's stage changed during this session (e.g., submitted, received an R&R,
restructured scope), add one line:
> "This looks like a stage change — update `~/.claude/private/PROJECTS.md` with the new status."

If `private/PROJECTS.md` does not exist, skip this prompt entirely rather than offering to create it.

Say: "Session closed. See you next time."

---

## Notes

- Git push requires explicit user confirmation — never push silently.
- The archive in Phase 1 is unconditional and requires no confirmation.
