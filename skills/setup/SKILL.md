---
name: setup
description: >
  First-run configuration for a freshly cloned claude-config. Interviews the user
  and writes their personal profile, domain profile, machine paths, and settings.
  Idempotent — re-running only asks about what is still unconfigured.
  Trigger phrases: "setup", "first run", "configure this repo", "I just cloned this".
author: Matthew Mair
---

# /setup — First-Run Configuration

This repo ships with **no personal data**. Skills read the user's identity, field
conventions, and tool paths from files that do not exist until this skill creates
them. Your job is to create them by interview.

## Prime directive

**Never infer the user's identity from anything in this repository.** Skill
frontmatter, example text, `LICENSE`, and `README.md` credit the *authors of the
tools*. They say nothing about who is using them. If you do not know the user's
name, you ask — you never borrow one from a file.

---

## PHASE 0: Detect what is already configured

Check each path and build a list of what is missing:

| Path | Holds | Tier |
|---|---|---|
| `~/.claude/private/profile.md` | identity and collaborators | 2 |
| `~/.claude/private/domain-profile.md` | field and method conventions | 2 |
| `~/.claude/private/PROJECTS.md` | project index | 2 |
| `~/.claude/private/CLAUDE.md` | personal working preferences | 2 |
| `~/.claude/CLAUDE.md` | one-line stub importing the above | 3 |
| `~/.claude/machine.md` | tool paths and research roots for THIS machine | 3 |
| `~/.claude/settings.json` | Claude Code settings | 3 |

- **All present:** report that setup is already complete, list the paths, and
  offer to revise any one of them. Do not re-interview.
- **Some present:** only ask about what is missing. Never overwrite an existing
  file without showing its current contents and getting explicit confirmation.
- **None present:** run the full interview below.

State up front roughly how many questions are coming, and that every one can be
skipped with "skip" or "later".

---

## PHASE 1: Identity  → `private/profile.md`

Ask, in one batch:

1. Name, and what you should call them
2. Institution and role (optional)
3. Any collaborators whose names should be recognised in project files

Write `private/profile.md` from `profile.template.md`. Leave skipped fields
blank — a blank field is a valid answer meaning "ask me later", and is always
safer than a guess.

Strip the template's instructional prose as you fill it: the blockquote at the
top **and** the prompt line under each section ("Names that should be recognised
in project files and session logs"). Those are directions to whoever fills the
file in, not content. Keep the headers and the values.

---

## PHASE 2: Field and methods  → `private/domain-profile.md`

Ask:

1. Primary field, and adjacent fields
2. Main analysis language, and any house-style packages or estimators
3. Standing conventions worth enforcing — clustering rules, seed policy, path
   rules, table and figure style
4. Document toolchain, if they write papers: compiler, bibliography backend
5. Typical target venues, if any

Write `private/domain-profile.md` from `domain-profile.template.md`. Drop whole
sections that don't apply to their field rather than leaving empty headers.

If the user is not an academic researcher, say plainly that several skills in
this repo (`/review-paper`, `/respond-to-referee`, `/validate-bib`,
`/pre-analysis-plan`) assume a research-paper workflow and will be of limited
use, and offer to note that in their profile. Do not pretend the repo is
field-neutral when it isn't.

---

## PHASE 3: Machine paths  → `machine.md`

This file is **machine-local and never synced** — it differs on every machine
the user works on.

Detect what you can rather than asking. Probe for the tools the skills actually
use, and record the invocation that works.

**Resolving a tool is not the same as running it.** `command -v python`
succeeding proves only that *something* answers to that name. Always execute
each candidate — `<tool> --version` — and record only an invocation that
actually returns a version.

Two traps this catches:

- **Windows Store stubs.** On Windows, `python` and `python3` often resolve to
  `.../AppData/Local/Microsoft/WindowsApps/python`, a shim that prints "Python
  was not found; run without arguments to install from the Microsoft Store" and
  exits 0. It is on `PATH`, it is not Python, and the real interpreter is
  usually an Anaconda or python.org install elsewhere.
- **Shadowed or stale installs.** The first match on `PATH` may be an older
  version than the one the user means.

When the on-`PATH` name fails to execute, search common install roots
(`/c/R/`, `~/anaconda3/`, `/c/Program Files/`, `/opt/`, `/usr/local/`), verify
by running, and record the full working path — noting explicitly that the bare
name does NOT work, so nothing later tries it.

Probe for:

- R / Rscript
- Python
- A LaTeX distribution (`pdflatex`)
- Anything else their field answers implied

For each: record the full path, the version, whether it is on `PATH`, and any
invocation gotcha discovered while testing. Ask only about tools you could not
find. If a tool is absent, record it as absent — that is useful information, not
a failure.

### Research roots — the one thing here you must ask

Tool paths can be probed. Where the user keeps their research cannot.

Ask: **"Where do your research projects live? Give me each top-level folder —
most people have one, some keep a cloud-synced tree and a local one."**

Record them as named roots in `machine.md`:

```markdown
## Research roots
- **cloud:** `C:\Users\you\OneDrive - Your University`
- **local:** `C:\Research`
```

Explain why the names matter: `private/PROJECTS.md` stores paths as
`{cloud}/papers/coastal-hedonics`, and it syncs across machines while `machine.md`
does not. The same row then resolves on every machine, provided each machine
defines the **same names**. If the user works on more than one machine, say
plainly that they will need this section in the other machine's `machine.md`
too, with the same names and that machine's paths.

If they skip, record the section with a blank list. `/overview` will report
unresolved roots rather than guessing — which is the intended failure, not a bug.

---

## PHASE 4: Settings and personal layer  → `settings.json`, `CLAUDE.md`

Copy `settings.template.json` to `settings.json` if it does not exist. Ask only
about theme and whether they want the fullscreen TUI. Leave `model` unset so
Claude Code's own default applies.

Never copy a `model` pin, `autoMode` block, or permission entry out of anyone
else's settings file.

Then wire the personal layer, without asking — it is two small files and both
are reversible:

1. Copy `CLAUDE.template.md` to `private/CLAUDE.md` if it does not exist.
2. Write `~/.claude/CLAUDE.md` containing exactly `@private/CLAUDE.md`, unless a
   `CLAUDE.md` is already there. **If one exists, do not overwrite it.** Show
   its first lines, say the import line would add a synced personal layer, and
   offer to append it.

Explain the split once, briefly: the conventions in `rules/` ship with the repo
and load every session; `private/CLAUDE.md` is theirs alone and travels with the
private repo; the stub exists only because Claude Code loads `~/.claude/CLAUDE.md`
at that exact path and nowhere else.

Say plainly that a missing import is skipped **silently** — so on a machine where
this repo is cloned but `private/` is not, sessions start with no personal layer
and no warning. If `private/CLAUDE.md` is absent when you write the stub, say so
rather than leaving them to discover it.

---

## PHASE 5: Private repo (ASK FIRST — never do this unprompted)

Only after Phases 1–4 have written files, offer this. Explain it fully before
asking, in roughly these terms:

> Your answers live in `~/.claude/private/`, which this repo ignores on purpose.
> That keeps your name, field, projects, and any writing samples out of the
> public repo permanently.
>
> Right now those files exist only on this machine. If you want them on your
> other machines, the usual approach is to make `~/.claude/private/` its own
> **private** git repository and push it somewhere only you can read.
>
> If I set that up, I would: run `git init` inside `~/.claude/private/`, write a
> `.gitignore` there, and make one initial commit. I would **not** create a
> remote, add a remote, or push anything — you would do that yourself, and I'd
> print the exact commands.
>
> If you'd rather sync that folder another way — cloud storage, or just not sync
> it at all — say no and nothing happens. Your setup is complete either way.

Then ask: **"Set up `~/.claude/private/` as a private git repository? (yes / no)"**

Proceed only on an explicit yes. On yes:

1. `git init` in `~/.claude/private/`
2. Write a `.gitignore` there covering OS noise and any credential file patterns
3. One initial commit
4. Print, without running them:
   ```
   # Create a PRIVATE repo on your host, then:
   git -C ~/.claude/private remote add origin <your-private-repo-url>
   git -C ~/.claude/private push -u origin main
   ```
5. Warn plainly: this repo will hold personal research context. Keep it private.
   **Never** put human-subjects microdata, credentials, or anything under a data
   use agreement in it — those belong in your institution's approved storage,
   not in git.

On no: confirm setup is complete and say the folder can be turned into a repo
later by re-running `/setup`.

---

## PHASE 6: Report

Print what was written, what was skipped, and what to do next:

```
CONFIGURED
  private/profile.md          — identity and collaborators
  private/domain-profile.md   — field and method conventions
  private/CLAUDE.md           — your working preferences (synced)
  CLAUDE.md                   — one-line stub importing the above
  machine.md                  — tool paths and research roots for this machine
  settings.json               — Claude Code settings

SKIPPED
  private/PROJECTS.md         — created by /newproject, or copy PROJECTS.template.md

NEXT
  /startup    load open action items and begin a session
  /overview   cross-project dashboard (needs private/PROJECTS.md)
```

Mention that any of it can be edited by hand at any time, and that re-running
`/setup` only asks about what is missing.

---

## Notes

- Ask in batches, not one question at a time. Five short exchanges, not twenty.
- Blank beats guessed. A field left empty makes a skill ask; a wrong value makes
  it act confidently and wrongly.
- Never write into `~/.claude/` root what belongs in `private/`.
- This skill writes files. It does not create remotes, push, or edit anything
  under `skills/` or `agents/`.
