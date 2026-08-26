---
name: check-public
description: >
  Pre-publish audit for this repo. Scans the working tree AND git history for
  personal identifiers, absolute home paths, and private-tier files that have
  leaked into tracked content. Run before every push to a public remote.
  Trigger phrases: "check public", "pre-publish check", "safe to push", "publish audit".
author: Matthew Mair
---

# /check-public — Pre-Publish Audit

Read-only. Reports; never edits. Run from the repo root.

## Why this exists

Personal data leaks back into a public repo through three routes, and all three
have happened in this repo's ancestry:

1. **Reintroduction.** A sanitizing commit removes a name; a later commit adds it
   back. Nobody notices because the original cleanup is old history.
2. **History.** `git rm` deletes a file from the working tree but leaves it fully
   recoverable in every earlier commit.
3. **Inheritance.** A skill adapted from someone else's repo carries their home
   directory or name inside its prose, and it reads as instruction.

Check all three, every time. A clean working tree proves nothing about history.

---

## PHASE 1: Working tree

Grep tracked files for:

**Identity** — the maintainer's name and any collaborator names in
`private/profile.md`; any name appearing in the body prose of a skill or agent
rather than in its frontmatter.

**Paths** — two distinct classes, and the second is easy to miss:

1. *User paths*: `C:\Users\<anything>`, `C:/Users/<anything>`,
   `/Users/<anything>`, `/home/<anything>`, `OneDrive`, any institution name.
2. *Machine tool paths with no username in them* — `C:/R/...`,
   `C:\Program Files\...`, `/opt/...`, `/usr/local/Cellar/...`, any
   version-pinned install root. These carry no identifying string, so a
   username-based grep misses them entirely, and they are wrong for every
   other machine. Grep bare `C:[/\]`, `/opt/`, `/usr/local/` as well.

   Also grep the **POSIX drive form** — Git Bash on Windows renders `C:/R/...`
   as `/c/R/...`, which no `C:` pattern matches. Include `/[a-z]/` drive roots,
   `.exe`, `Rscript`, `pdflatex`, `python3?`, and version-pinned directory names
   like `R-[0-9]+.[0-9]+`. This exact form shipped past three earlier scans.

   Tool paths belong in `machine.md` (tier 3). A skill should point at
   `machine.md`, never name an install path directly.

**Projects** — every project name listed in `private/PROJECTS.md`, plus any
venue or review status (`R&R`, `Major Revision`, journal names) sitting in a
tracked file.

**Credentials** — `sk-ant-`, `api[_-]?key`, `token`, `password`, `secret`.

**Tier-2 leakage** — is anything from `private/` tracked? Is `settings.json`,
`machine.md`, or any `*.aux/.log/.nav/.snm/.toc/.out` in the index?

### The metadata exemption

An author name in **frontmatter** (`author:`, `source:`, `upstream_url:`), in
`LICENSE`, or in a `README` credit line is correct and expected — it attributes
the tool. Do not flag it.

Flag the same name when it appears in **instruction prose**: a skill body, a
checklist item, an example path, a `CLAUDE.md` directive. There it stops being
attribution and becomes an assertion about whoever is running the repo.

That distinction is the whole point of this check. When unsure, ask: *would
Claude read this line as a fact about the user?* If yes, flag it.

---

## PHASE 2: History

The working tree is only half the audit.

1. Every path ever added:
   `git log --all --pretty=format: --name-only --diff-filter=A | sort -u`
   Flag any tier-2 or tier-3 path — `PROJECTS.md`, `ACTION-ITEMS.md`,
   `completed_archive.md`, `voice-profile.md`, `settings.json`, `machine.md`,
   `writing-samples/`, anything under `private/`.
2. For each hit, confirm recoverability and show the exact retrieval command, so
   the finding is concrete rather than theoretical:
   `git show <commit>^:<path>`
3. Pickaxe for identifiers across all history:
   `git log --all -S'<term>' --oneline`

**A file removed in a later commit is still public.** If any tier-2 path appears
in history, the only real fixes are a fresh repo or `git filter-repo` — report
that plainly and do not suggest another delete commit.

---

## PHASE 3: Report

```
--- BLOCKERS (do not publish) ---
  file:line — what it exposes — how to fix

--- WARNINGS (judgment call) ---
  file:line — why it might matter

--- CLEAN ---
  what was checked and passed
```

End with an explicit verdict: **SAFE TO PUBLISH** or **DO NOT PUBLISH**, and if
the latter, the shortest path to safe.

If history contains tier-2 paths, the verdict is **DO NOT PUBLISH** regardless of
how clean the working tree is.

---

## PHASE 4: Fresh-clone verification

A tracked-file grep can miss what a clone actually delivers. To confirm:

```
git clone --no-local . /tmp/publish-check
```

Re-run Phase 1 against that clone, then delete it. This is the real test — it
sees exactly what a stranger gets.
