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

Name, institution, and collaborators. **Leave blank anything you are unsure
about.** A blank field makes skills ask you; a guessed field makes them act
confidently on a wrong value.

Working preferences do *not* go here — see step 6.

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

The template registers one hook, `hooks/protect-raw-data.sh`. Any edit, write,
delete, move, or redirect that targets a `data/raw/` folder triggers a permission
prompt instead of running silently, so raw data is only ever copied out, never
changed in place. It runs under Git Bash on Windows and natively on macOS/Linux,
with no dependencies. It guards Claude's own tool calls, not scripts that write
to `data/raw/` internally. Remove the `hooks` block if you don't want it.

### 5. Project index — `private/PROJECTS.md` (optional)

```bash
cp PROJECTS.template.md private/PROJECTS.md
```

Needed only by `/overview`. `/newproject` maintains it as you go.

### 6. Working preferences — `private/CLAUDE.md` (optional)

The shipped conventions live in `rules/` — one file per topic (identity,
approval gates, git, data verification, LaTeX, tool paths, domain profile,
session logging). Claude Code loads every `.md` in `~/.claude/rules/` at the
start of each session, at the same priority a user-level `CLAUDE.md` would
have. They apply as soon as you clone. Delete any file whose conventions are
not yours; nothing else depends on it.

Your *personal* preferences — how much to explain, when to ask before acting,
tone — are not conventions anyone should inherit, so they live outside this
repo:

```bash
cp CLAUDE.template.md private/CLAUDE.md
echo '@private/CLAUDE.md' > CLAUDE.md
```

Two files, because Claude Code loads `~/.claude/CLAUDE.md` at that exact path
and nowhere else. The stub is gitignored and machine-local; the file it imports
sits in your private repo and travels between machines with it. A missing import
is skipped silently, so if you clone this repo without `private/`, sessions
start with no personal layer and no warning.

Keep it short, and mind the boundary: rules about *how the work is done* —
estimators, clustering, seed policy, table style — belong in
`private/domain-profile.md`, where the skills that care about them will read it.

```markdown
## Working preferences

- Recommend one option rather than surveying all of them.
- Explain at the level of a second-year PhD student; skip the basics.
- Show me the diff before editing anything under `code/`.
- Ask before running anything that takes more than a minute.
```

**Already have your own `~/.claude/CLAUDE.md`?** Keep it — this repo does not
track one, so cloning will not touch it. Add the `@private/CLAUDE.md` line to
it if you want the synced personal layer as well.

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
any specific person, and `rules/identity.md` explicitly forbids inferring your name from
repository files. Run `/check-public` before publishing a fork — it enforces
exactly this distinction.
