# Claude Code Configuration

A complete `~/.claude/` for academic research with Claude Code: global
instructions, 26 custom skills, specialist sub-agents, session logging, and
cross-project tracking.

**This repo ships with no personal data in it.** Nothing here knows who you are
until you run `/setup`. That is deliberate — see
[Why this repo is empty](SETUP.md#why-this-repo-is-empty).

---

## Quick start

```bash
npm install -g @anthropic-ai/claude-code
git clone <this-repo-url> ~/.claude
```

If `~/.claude/` already exists because Claude Code created it:

```bash
cd ~/.claude && git init && git remote add origin <this-repo-url>
git pull origin main
```

Then open Claude Code in `~/.claude/` and run:

```
/setup
```

It interviews you — identity, field, methods, tool paths — and writes every file
the skills need. Five short exchanges, all skippable, re-runnable at any time.
Prefer to fill files in by hand? [SETUP.md](SETUP.md) has the manual path.

---

## The three tiers

Every file belongs to exactly one tier. This is what keeps the public repo
publishable and your research context private.

| Tier | What | Synced how | Where |
|---|---|---|---|
| **1 — Shareable** | skills, agents, templates, docs | this repo | `~/.claude/` |
| **2 — Personal, portable** | profile, domain profile, project index, writing samples | *your own private repo* | `~/.claude/private/` |
| **3 — Machine-local** | `machine.md`, `settings.json` | not synced | `~/.claude/` |

`private/` is gitignored here on purpose. Your name, field, projects, and
writing never enter this repository. To carry them between machines, make
`~/.claude/private/` its own **private** repo — `/setup` offers to do the local
half and always asks first.

A new machine is then two clones:

```bash
git clone <this-repo-url>        ~/.claude
git clone <your-private-repo>    ~/.claude/private
```

> Keep tier 2 private, and keep data out of it. Never commit human-subjects
> data, credentials, or anything under a data use agreement — those belong in
> your institution's approved storage, not in git.

---

## What's in this repo

| Path | Purpose |
|---|---|
| `CLAUDE.md` | Global instructions: approval gates, git conventions, LaTeX rules, session logging |
| `skills/` | 26 skills, invoked as `/<name>` or auto-discovered |
| `agents/` | Specialist sub-agents — econometrician, referee, editor, debugger, proofreader |
| `SETUP.md` | Setup checklist and the manual configuration path |
| `*.template.*` | Inert scaffolds you copy into `private/` |

### Skills by area

| Area | Skills |
|---|---|
| **Session** | `setup`, `startup`, `wrapup`, `overview`, `learn` |
| **Writing** | `voice-write`, `voice-review`, `build-voice`, `prose-audit` |
| **Review** | `review-paper`, `review-code`, `empirical-audit`, `respond-to-referee` |
| **Submission** | `presubmit`, `final-proofread`, `validate-bib`, `compiletex`, `compiledeck` |
| **Data** | `verify-data`, `pre-analysis-plan`, `newproject`, `project-manager` |
| **Reading** | `split-pdf` |
| **Repo hygiene** | `check-public` |

Run `/check-public` before publishing a fork — it audits the working tree *and*
git history for personal data, and enforces the metadata-vs-instruction rule
described in [SETUP.md](SETUP.md#why-this-repo-is-empty).

---

## Day-to-day

```bash
cd ~/.claude && git pull        # start of session
/startup                        # load action items and orient
/wrapup                         # archive completed items, check git state
```

Add a project-level `.claude/domain-profile.md` in each research project for
venue-specific and method-specific context. Skills read the global profile
first, then the project one.

---

## Attribution

13 skills are original. 16 files are adapted from two upstream projects, each
recording its origin, the version forked from, and how far it has diverged in
its own frontmatter (`source`, `author`, `adapted_by`, `adaptation`,
`upstream_url`). See [CATALOG.md](CATALOG.md#attribution-convention) for the
convention.

### From [MixtapeTools](https://github.com/scunning1975/MixtapeTools) — Scott Cunningham

| Skill | Adaptation |
|---|---|
| `newproject` | substantial |
| `compiletex` | substantial |
| `split-pdf` | substantial |
| `empirical-audit` | substantial |
| `compiledeck` | light |

### From [clo-author](https://github.com/hugosantanna/clo-author) — Hugo Sant'Anna, with Pedro H. C. Sant'Anna

These six skills and five agents were **removed upstream** on 2026-03-05 when
clo-author consolidated ~25 granular skills into 14 verb-named ones. The
versions here are forks of the last standalone releases; `upstream_url` points
at commit permalinks rather than `main`.

| File | Origin author | Adaptation |
|---|---|---|
| `prose-audit` (upstream `humanizer`) | Hugo Sant'Anna | substantial |
| `pre-analysis-plan` | Hugo Sant'Anna | substantial |
| `validate-bib` | Pedro H. C. Sant'Anna | substantial |
| `respond-to-referee` | Hugo Sant'Anna | moderate |
| `review-code` | Pedro H. C. Sant'Anna | moderate |
| `learn` | Hugo Sant'Anna | moderate |
| `agents/editor` | Hugo Sant'Anna | substantial |
| `agents/debugger` | Hugo Sant'Anna | light |
| `agents/econometrician` | Hugo Sant'Anna | light |
| `agents/proofreader` | Hugo Sant'Anna | light |
| `agents/referee` | Hugo Sant'Anna | light |

### Ideas

The persistent-extract caching, split reuse, and agent isolation protocol in
`split-pdf` originate with **Ben Bentzin** (McCombs School of Business, UT
Austin). See that skill's Acknowledgments.

---

## Credits

Created and maintained by **Matthew Mair**.

Adapts skills and agents from two upstream projects, each retaining its original
attribution in the adapted skill's frontmatter:

- [MixtapeTools](https://github.com/scunning1975/MixtapeTools) — Scott Cunningham
- [clo-author](https://github.com/hsantanna88/clo-author) — Hugo Sant'Anna

MIT licensed. See [LICENSE](LICENSE).
