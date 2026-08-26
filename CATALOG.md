# Skill & Command Catalog

## Global Agents

| Name | Source | Purpose | Tools |
|---|---|---|---|---|
| econometrician | clo-author | Causal inference critic — 4-phase audit of DiD, IV, RDD, SC, event studies | Read, Grep, Glob |
| proofreader | clo-author | Manuscript polish critic — grammar, LaTeX compilation, hedging, notation | Read, Grep, Glob |
| debugger | clo-author | Code quality critic — 12 categories, standalone (cat. 4–12) or full pipeline | Read, Grep, Glob |
| referee | clo-author | Blind peer reviewer — 5-dimension scoring (contribution, identification, data, writing, journal fit) | Read, Grep, Glob |
| editor | clo-author | Journal editor (Mode 3 only) — journal targeting, referee assignment, editorial decision; Modes 1–2 stripped to avoid overlap with proofreader | Read, Grep, Glob |

---

## Active Skills

| Name | Source | Purpose |
|---|---|---|
| compiledeck | mixtapetools | Beamer presentations following the Rhetoric of Decks philosophy |
| compiletex | mixtapetools | Compile .tex files and report errors/warnings |
| learn | clo-author | Extract non-obvious session discoveries into reusable persistent skills |
| review-r | clo-author | Per-script code quality audit: reproducibility, figure standards, polish (R/Stata/Python/Julia) |
| validate-bib | clo-author | Cross-reference citations vs. bibliography; find missing entries, unused refs, key typos |
| respond-to-referee | clo-author | Classify, track, and draft point-by-point responses to real referee reports |
| pre-analysis-plan | clo-author | Draft PAPs to AEA RCT Registry, OSF, or EGAP standards; flags all assumed items for review |
| newproject | mixtapetools | Scaffold research project with standard directory structure |
| review-paper | clo-author | Simulated peer review — dispatches 2 Referee agents in parallel then Editor for decision |
| referee2 | mixtapetools | Adversarial five-audit empirical research review protocol |
| split-pdf | mixtapetools | Chunked academic PDF reading (4-page batches, structured notes) |
| overview | local | Cross-project dashboard: reads PROJECTS.md + each project's ACTION-ITEMS.md, sorts by priority tier, flags stale projects, drill-down on request |
| startup | local | Session-start: load and prioritize open action items; pedagogical walkthrough (problem/approaches/pros-cons/learning note) for each item |
| presubmit | local | Pre-submission pipeline: validate-bib → final-proofread → compiletex with gate logic, skip flags, and consolidated GO/NO-GO report |
| project-manager | local | Broad-use project health scan: organization, naming, version control, reproducibility, sustainability — auto-detects research/software/generic project type, writes report to correspondence/project-manager/ |

## Sources

| Source | Author | URL | Date Added | Status |
|---|---|---|---|---|
| mixtapetools | Scott Cunningham | github.com/scunning1975/MixtapeTools | 2026-03-01 | active |
| clo-author | Hugo Sant'Anna (maint.); Pedro H. C. Sant'Anna (contrib.) | github.com/hugosantanna/clo-author | 2026-03-01 | restructured — forked skills removed upstream 2026-03-05 |

---

## Intake Process

To add a skill from an external source:

1. **Stage** — copy raw into `staging/[source]/[skill-name]/`
2. **Document** — fill in provenance metadata; note any conflicts with existing skills
3. **Identify conflicts** — check for overlap with existing commands
4. **Adapt** — modify for this environment (R path, bibtex not biber, Windows paths)
5. **Test** — use on a real or toy task before promoting
6. **Promote** — copy to `skills/` or `commands/`, add entry to this CATALOG
7. **Note skips** — document any skills intentionally not imported and why

## Attribution Convention

Every derivative skill and agent carries this in its frontmatter:

```yaml
source:          upstream project slug
author:          the originator — unchanged, never overwritten
adapted_by:      whoever did the local adaptation
adaptation:      light | moderate | substantial
upstream_url:    permalink to the version forked from
last_synced:     date the upstream comparison was last run
upstream_status: what has happened to it upstream since
local_changes:   (optional) what diverged and why
```

`adaptation` is set from measured line-level divergence against the forked
version — the share of local lines with no verbatim upstream counterpart:

| Level | Divergence | Meaning |
|---|---|---|
| `light` | < 40% | Adapter, not co-author. Upstream structure and most prose intact. |
| `moderate` | 40–59% | Meaningful local rework on an upstream skeleton. |
| `substantial` | ≥ 60% | Effectively co-authored; upstream supplied the idea and starting point. |

`author` is never replaced by the adapter's name, at any divergence level.
Attribution lives in metadata only — never in instruction prose, where a model
reads it as a fact about the user rather than as credit to the tool's author.
