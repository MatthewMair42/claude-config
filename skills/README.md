# Skills Directory

All global Claude Code skills for the researcher's research workflow. Invoke any skill with `/<name>` in the prompt.

---

## Session Management

| Skill | Command | Purpose |
|-------|---------|---------|
| **overview** | `/overview` | Cross-project dashboard. Reads `~/.claude/private/PROJECTS.md` and each project's `ACTION-ITEMS.md` live, sorts projects by priority tier (R&R → pre-submission → active → early stage), flags stale projects (last session >30 days), and shows open-item counts. Drill into any project for the full item list. Optionally updates open-item counts in `PROJECTS.md`. Use weekly, not per-session. |
| **startup** | `/startup` | Session-start ritual. Reads `ACTION-ITEMS.md`, classifies open items into CRITICAL / QUICK WIN / OPTIONAL, and walks through each with a problem–approaches–recommendation frame calibrated to a 2nd-year applied econ PhD student. Checks git sync status first. |
| **wrapup** | `/wrapup` | Session-end ritual. Audits session log for undocumented decisions, sweeps for new action items, checks git status (commit + push prompts), checks compile status on LaTeX projects, silently archives all completed items to `completed_archive.md`, and prints a summary. **Does not start new editorial work.** |
| **newproject** | `/newproject` | Scaffolds a new research project: creates standard folder tree (`code/`, `data/`, `output/`, `documents/`, `correspondence/`, `decks/`, `notes/`, `.claude/`), writes `README.md`, seeds `ACTION-ITEMS.md` and first session log, scaffolds `data/dictionary.md` (variable table template) and `code/R/00_validate_dictionary.R` (pipeline-level column validator), and registers the project in `~/.claude/private/PROJECTS.md`. |
| **learn** | `/learn` | Extracts non-obvious session discoveries into a reusable persistent skill. Use when you find a workaround, debug a misleading error, or develop a multi-step workflow worth repeating. Self-evaluates whether the discovery warrants a new skill, checks for existing overlaps, then writes to `~/.claude/skills/` or `.claude/skills/`. |

---

## Manuscript Writing

| Skill | Command | Purpose |
|-------|---------|---------|
| **review-paper** | `/review-paper` | Full simulated peer review. Dispatches two blind Referee agents in parallel, then an Editor agent to synthesize. Scores across contribution, identification, data, writing, and journal fit. Saves referee reports and editorial decision to `correspondence/review-paper/`. Use for pre-submission quality checks — not for code or replication (use `/empirical-audit` for that). |
| **prose-audit** | `/prose-audit` | Audits academic prose for formulaic patterns. Checks 24 patterns across four categories: structural tics (triplet lists, formulaic transitions), lexical tells ("delve", "multifaceted", "underscores"), rhetorical patterns (excessive hedging, performative enthusiasm), and formatting tells (over-signposting, colon-list pattern). Writes suggestions to a `.suggestions.md` file — never modifies the original. |
| **respond-to-referee** | `/respond-to-referee` | Structures point-by-point referee responses. Classifies each comment as NEW ANALYSIS / CLARIFICATION / REWRITE / DISAGREE / MINOR, routes accordingly, builds a tracking document, and drafts a LaTeX response letter. Flags DISAGREE items for mandatory user review. Saves tracker and letter to `correspondence/`. |
| **validate-bib** | `/validate-bib` | Cross-references all citations in `.tex` and `.qmd` files against bibliography entries. Reports missing entries (critical), unused entries (informational), potential key typos, and quality issues (missing fields, malformed authors). Use before any submission, talk, or draft share. |
| **final-proofread** | `/final-proofread` | Final pre-submission proofreader. Dispatches the `proofreader` agent for prose/LaTeX polish, then runs structural checks: figure/table/appendix cross-references, placeholder text (`TODO`, `??`, `[CITE]`, hardcoded `Figure X` / `Table X` references), LaTeX comment hygiene, and a submission checklist (abstract word count, JEL codes, keywords, acknowledgments). Saves a numbered fix-list to `correspondence/final-proofread/`. **Never edits source files.** |
| **presubmit** | `/presubmit` | Pre-submission pipeline. Sequences `validate-bib` → `final-proofread` → `compiletex` with gate logic (pauses on critical bib errors), skip flags (`--skip-bib`, `--skip-proofread`, `--skip-compile`), and a single consolidated GO/NO-GO report saved to `correspondence/presubmit/`. **Never edits source files.** |

---

## Presentations

| Skill | Command | Purpose |
|-------|---------|---------|
| **compiledeck** | `/compiledeck` | Creates and compiles Beamer presentations following the Rhetoric of Decks philosophy. Enforces: one idea per slide, assertion titles, 24pt minimum font, no bullet lists (unless genuinely parallel), zero compile warnings. Includes a full Warm Professional color palette, TikZ collision-prevention rules (`tikz_rules.md`), audience-specific structural patterns (`domain_patterns.md`), and alternative palettes (`palette_reference.md`). |

---

## Data

| Skill | Command | Purpose |
|-------|---------|---------|
| **verify-data** | `/verify-data` | Structured session-level data verification. Reads all datasets in `data/clean/`, checks columns against `data/dictionary.md`, runs per-variable-type checks (N, missing values, continuous ranges, categorical levels, binary shares, ID uniqueness), compares N to the previous run to catch unexpected sample changes, and writes a dated `data/verification_YYYY-MM-DD.md` report. Blocks analysis if critical issues (undocumented columns, duplicate IDs, N drift) are found. Use at the start of any analysis session or after any major data step. |

---

## Code & Empirical Analysis

| Skill | Command | Purpose |
|-------|---------|---------|
| **review-code** | `/review-code` | Dispatches the Debugger agent in standalone mode (categories 4–12: script structure, console hygiene, reproducibility, function design, figure quality, RDS pattern, comments, error handling, polish). Works on R, Python, Stata, or Julia. Produces a report to `correspondence/` — **never edits source files**. |
| **empirical-audit** | `/empirical-audit` | Adversarial five-audit protocol for empirical research. Audit 1: code errors and logic gaps. Audit 2: cross-language replication (R↔Python) to exploit orthogonal hallucination errors. Audit 3: directory and replication package readiness (scored 1–10). Audit 4: output automation (tables, figures, in-text stats). Audit 5: econometrics (identification, SEs, fixed effects, parallel trends). Produces a formal referee report and a Beamer deck to `correspondence/referee2/`. **Never modifies author code.** |
| **compiletex** | `/compiletex` | Compiles a `.tex` file with `latexmk` (or manual 3-pass + bibliography fallback) and reports all errors and warnings. Specifically surfaces: fatal errors (`!`), overfull/underfull hbox (with severity in pt), undefined citations, and multiply defined references. Goal is zero warnings — not "mostly clean". |

---

## Research Process

| Skill | Command | Purpose |
|-------|---------|---------|
| **pre-analysis-plan** | `/pre-analysis-plan` | Drafts pre-analysis plans to AEA RCT Registry, OSF, or EGAP standards. Covers: study overview, primary/secondary/mechanism outcomes, estimating equations, subgroup analyses, multiple testing correction, power calculations, sample and exclusion rules, data sources, and a deviations log template. Accepts a research spec file, a topic string, or `interactive` for a guided interview. Flags every ASSUMED item — the researcher must review before registration. |
| **split-pdf** | `/split-pdf` | Downloads (or uses a local path) and deeply reads academic PDFs by splitting into 4-page chunks and reading 3 at a time, pausing for confirmation between batches. Extracts structured reading notes across 8 dimensions: research question, audience, method, data, statistical methods, findings, contributions, replication feasibility. Output: `notes.md` in the split subdirectory. **Never reads a full PDF directly** — avoids context crashes and shallow comprehension. |

---

## Source Notes

Most skills were adapted from external sources:

| Source | Skills |
|--------|--------|
| `clo-author` (Hugo Sant'Anna, Pedro H. C. Sant'Anna) | `prose-audit`, `respond-to-referee`, `validate-bib`, `pre-analysis-plan`, `review-code`, `learn` |
| `MixtapeTools` (Scott Cunningham) | `compiledeck`, `compiletex`, `empirical-audit`, `split-pdf`, `newproject` |
| Local (this repo) | `startup`, `wrapup`, `review-paper`, `verify-data` |

Upstream URLs are recorded in each skill's frontmatter. When syncing from upstream, bump the `version` field and update `last_synced`.
