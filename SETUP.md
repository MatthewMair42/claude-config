# Setup Checklist

This repo ships with **no personal data in it**. Nothing here knows who you are
until you tell it. That is deliberate — see [Why this repo is empty](#why-this-repo-is-empty).

The fast path is one command. The manual path is below it.

---

## Fast path

```
/setup
```

Claude interviews you and writes every file listed below. It asks about five
things — identity, field, methods, tool paths, settings — and you can skip any
of them. Re-running it only asks about what is still missing.

---

## Manual path

### 1. Your profile — `private/profile.md`

```bash
mkdir -p private
cp profile.template.md private/profile.md
```

Name, institution, collaborators, working preferences. **Leave blank anything you
are unsure about.** A blank field makes skills ask you; a guessed field makes
them act confidently on a wrong value.

### 2. Field conventions — `private/domain-profile.md`

```bash
cp domain-profile.template.md private/domain-profile.md
```

House-style packages and estimators, clustering rules, seed policy, document
toolchain, table and figure conventions. Skills read this to decide what counts
as an error in your field. Delete sections that don't apply rather than leaving
them empty.

### 3. Tool paths — `machine.md`

Machine-local, never synced — it differs on every machine you work on. Record
the full path and version for R, Python, `pdflatex`, and anything else your
skills invoke, plus any invocation gotchas you hit.

### 4. Settings — `settings.json`

```bash
cp settings.template.json settings.json
```

Gitignored. Yours alone.

### 5. Project index — `private/PROJECTS.md` (optional)

```bash
cp PROJECTS.template.md private/PROJECTS.md
```

Needed only by `/overview`. `/newproject` maintains it as you go.

---

## Syncing your own state across machines

`private/` is gitignored by this repo on purpose, so your personal state never
enters the public one. To get it onto your other machines, make it its own
**private** repository:

```bash
git -C ~/.claude/private init
git -C ~/.claude/private add -A
git -C ~/.claude/private commit -m "Initial private state"
# create a PRIVATE repo on your host, then:
git -C ~/.claude/private remote add origin <your-private-repo-url>
git -C ~/.claude/private push -u origin main
```

`/setup` offers to do the local half of this for you, and will always ask first.
It never creates a remote or pushes.

A new machine is then two clones:

```bash
git clone <this-public-repo>     ~/.claude
git clone <your-private-repo>    ~/.claude/private
```

> **Keep it private, and keep data out of it.** This repo will accumulate your
> research context. Never commit human-subjects data, credentials, or anything
> under a data use agreement — those belong in your institution's approved
> storage, not in git, however private the repo is.

---

## The three tiers

Every file here belongs to exactly one tier. If you add files, put them in the
right one.

| Tier | What | Synced how | Location |
|---|---|---|---|
| **1 — Shareable** | skills, agents, templates, docs | this public repo | `~/.claude/` |
| **2 — Personal, portable** | profile, domain profile, projects, writing samples | your private repo | `~/.claude/private/` |
| **3 — Machine-local** | `machine.md`, `settings.json` | not synced | `~/.claude/` |

---

## Why this repo is empty

Skills adapted from someone else's config tend to carry that person with them. A
home directory in an example path, a name in a checklist, a "replace X with
Scott" instruction — Claude reads those as facts about *you*, and starts
addressing you by the previous owner's name or scaffolding files under their
conventions.

The fix is a rule about where identity is allowed to live:

- **Metadata** — `author:` frontmatter, `LICENSE`, README credits — is inert.
  Claude reads it as *who wrote this tool*. Attribution belongs here.
- **Instruction prose** — skill bodies, checklists, example paths, `CLAUDE.md` —
  is live. Claude reads it as *a fact about the user*. Identity must never
  appear here.

So this repo credits its authors in metadata, keeps its instruction prose free of
any specific person, and `CLAUDE.md` explicitly forbids inferring your name from
repository files. Run `/check-public` before publishing a fork — it enforces
exactly this distinction.
