---
name: startup
description: |
  Session-start skill. Load, prioritize, and walk through open action items
  with pedagogical problem/solution framing. Use when starting a work session
  on any project. Trigger phrases: "startup", "start session", "recall action items".
author: Matthew Mair
version: 1.2.0
allowed-tools: ["Read", "Glob", "Grep", "Bash"]
disable-model-invocation: true
---

# /startup — Session Start Protocol

Load the project's open action items, prioritize them into three buckets, and guide
the user through each item with a structured pedagogical walkthrough.

---

## PHASE 0: Git Pull Check

Before loading action items, check whether this project is a git repository:

1. Run `git status` in the current working directory (Bash).
2. **If not a git repository:** skip this phase silently.
3. **If a git repository:** check whether the local branch is behind the remote
   by running `git fetch --dry-run` or checking `git status` output for
   "Your branch is behind".
   - If **behind or unknown:** prompt the user:
     > "This project uses git. Do you want to pull before starting? (`git pull`)"
     Run `git pull` only if the user confirms.
   - If **up to date:** note it briefly ("Git is up to date.") and continue.

---

## PHASE 1: Load Action Items

1. **Find the action items file:** Look for `.claude/ACTION-ITEMS.md` in the current
   working directory. If not found, say so and stop.

1.5. **Detect project type**, since it changes what "CRITICAL" means in step 4:
   - **Software package**: presence of `DESCRIPTION` (R), `pyproject.toml`/`setup.py`
     (Python), or `package.json` with no paper/thesis content, plus a test directory
     (`tests/`, `testthat/`). Review targets are things like CRAN, rOpenSci, JOSS,
     PyPI, or npm rather than a journal.
   - **Empirical paper** (default): `.tex` files, a `data/` + analysis-script
     structure, or no package manifest present. Review targets are journals and
     referees.
   - If ambiguous, default to empirical paper — it's the more common case — but note
     the mismatch to the user if the action items clearly don't fit (e.g. items
     mention CRAN/rOpenSci/JOSS while defaulting to paper framing).

2. **Extract open items:** Pull every line matching `- [ ]` from the `## Open` section.
   Also check `## Setup` sections if present.

3. **Separate blocked/waiting items first:** Any item tagged `[BLOCKED: ...]` or
   `[WAITING: ...]` is set aside — do not include them in the prioritized list.
   After displaying the active list, show them in a separate section:

   ```
   --- BLOCKED / WAITING ---
   • [item summary] — waiting on: [what/who]
   ```

   These are informational only. The user cannot select them until the block is resolved.

4. **Classify remaining items into one of three buckets.** Criteria depend on the
   project type detected in step 1.5:

   **CRITICAL**
   - Tagged `[HIGH]` or `[HIGH PRIORITY]`
   - Empirical paper: touches identification, parallel trends, clustering, standard
     errors, robustness, structural decisions, empirical specification, referee
     concerns, journal submission — any item where the paper's empirical credibility
     depends on resolution
   - Software package: touches correctness bugs, numerical edge cases (e.g. zero/NA
     standard errors, divide-by-zero), test coverage gaps for core functionality, or
     items explicitly flagged as blocking by a package review process (CRAN NOTEs/
     ERRORs, rOpenSci reviewer requests, JOSS reviewer requests) — any item where the
     package's correctness or its review outcome depends on resolution

   **QUICK WIN**
   - Empirical paper: tagged writing, footnote, appendix, placeholder, disclosure, or
     N-per-bin; resolvable without running code or fetching new data — prose, LaTeX,
     or config edits only
   - Software package: tagged docs, roxygen/docstring, test fixture, or metadata;
     resolvable without a methodological or design judgment call — doc edits, adding
     a test fixture that mirrors an existing pattern, or config/metadata edits only
   - Either type: no methodological/design judgment call required — execution only
   - Note: figure/output items only qualify if the artifact already exists and just
     needs inserting; anything requiring a fresh run (R/Stata analysis, package
     rebuild, doc regeneration via `devtools::document()` or equivalent) still counts
     as QUICK WIN as long as it's a mechanical regeneration step with no judgment call
     — but goes to OPTIONAL / OTHER if the run itself is slow/exploratory or its
     output is uncertain

   **OPTIONAL / OTHER**
   - Tagged `[OPTIONAL]`
   - Exploratory, speculative, or nice-to-have
   - Doesn't fit CRITICAL or QUICK WIN
   - Ambiguous items default here (not QUICK WIN)

5. **Display the prioritized list**, grouped in this order: CRITICAL → QUICK WIN → OPTIONAL.
   Format:

   ```
   --- CRITICAL ---
   1. [one-line summary of item]

   --- QUICK WIN ---
   2. [one-line summary of item]
   3. [one-line summary of item]

   --- OPTIONAL / OTHER ---
   4. [one-line summary of item]
   ```

   If a bucket is empty, omit it.

6. **Prompt:** "Which item would you like to focus on? (Give a number, or say
   'all quick wins first' to work through them in order.)"

---

## PHASE 1.5: Load Project Context

Before entering Focus Mode, load project-specific context to inform the walkthrough:

1. Check for `.claude/domain-profile.md` in the current project directory. If it exists, read it.
2. Check for `~/.claude/private/domain-profile.md` (global). Read it.
3. Check for the project's `CLAUDE.md`. Read any sections relevant to methods, journal
   target, advisor constraints, or (for software packages) review target/package
   conventions.

Extract and hold in context, matching the project type detected in step 1.5:

**Empirical paper:**
- **Journal target** (affects how conservative to be on identification, what referees will ask)
- **Identification strategy** (DiD, IV, RDD, CF, etc. — affects what CRITICAL items mean)
- **Advisor constraints or known preferences** (affects RECOMMENDED option)
- **Current paper stage** (working paper, R&R, pre-submission — affects urgency calibration)

**Software package:**
- **Review target** (CRAN, rOpenSci, JOSS, PyPI, npm — affects what reviewers/
  automated checks will flag)
- **Package conventions** (e.g. a two-layer extract/plot API, a required test
  fixture pattern — affects what CRITICAL and QUICK WIN items mean)
- **Known reviewer or maintainer preferences** (affects RECOMMENDED option)
- **Current release stage** (pre-release, submitted for review, published — affects
  urgency calibration)

This context is used silently to sharpen the Phase 2 walkthrough. Do not display it to the user — just let it inform the RECOMMENDED option and WHY IT MATTERS framing.

---

## PHASE 2: Focus Mode

When the user selects an item number (or the next item in a sequence), present the
appropriate walkthrough based on the item's bucket, then wait for confirmation before
doing any work.

### QUICK WIN items

```
TASK
[One sentence: what specifically will be done.]

WHY
[One sentence: why this item exists.]
```

Then ask: **"Ready to proceed?"**

### CRITICAL and OPTIONAL items

```
PROBLEM
[Describe the identified issue in plain, direct language. 2–4 sentences max.
What specifically is wrong, missing, or uncertain?]

WHY IT MATTERS
[Explain why this is worth resolving. For an empirical paper, frame it in terms a
2nd-year applied economics PhD student would recognize from methods coursework or
referee reports, grounded in the journal target and identification strategy.
Examples: "this is a classic parallel trends threat", "with ~26 clusters, your
t-based inference may over-reject", "referees at your target journal will ask whether the
1-mile buffer is wide enough to prevent contamination." For a software package,
frame it in terms a package reviewer or maintainer would recognize, grounded in the
review target. Examples: "rOpenSci reviewers routinely flag untested edge cases in
core statistical functions", "a silent zero-SE substitution can mask a real
computation bug rather than surfacing it", "CRAN will NOTE on this at submission."
2–4 sentences.]

APPROACHES
Option A — [descriptive name]
  [What this approach involves, concretely]
  Pros: [1–3 bullet points]
  Cons: [1–2 bullet points]

Option B — [descriptive name]
  [What this approach involves, concretely]
  Pros: [1–3 bullet points]
  Cons: [1–2 bullet points]

[Option C — include a third only if genuinely distinct and useful]

RECOMMENDED
[State which option is preferred and why, given this project's specific context —
for a paper: journal norms, identification strategy, advisor constraints; for a
package: review target conventions, existing API patterns, maintainer preferences.
Be direct. One short paragraph.]

LEARNING NOTE
[1–2 sentences connecting this problem to broader practice in the relevant field.
For a paper: what would a thoughtful methods instructor or seasoned referee say —
cite a paper, a standard, or a well-known principle if relevant. For a package:
what would a thoughtful package reviewer or the language's package-review standards
(CRAN Repository Policy, rOpenSci review guide, JOSS review checklist) say.]
```

Then ask: **"Ready to proceed with [Recommended option]? Say yes to start, or tell me
which approach you prefer."**

Do not begin editing files, running code, or writing prose until the user confirms.

---

## PHASE 3: After Completing an Item

Once an item is finished:
1. Update `ACTION-ITEMS.md` — mark the item `[x]`, move it to `## Completed` with today's date.
2. **If a meaningful decision was made during this item** (e.g., chose one estimator over another, changed paper structure, dropped a variable, fixed a buffer distance), log it in the `## Key Decisions` section of the day's log (`logs/YYYY-MM-DD.md`) with the format: **Decision:** what was chosen. **Why:** the reason. **Alternatives considered:** what was ruled out and why.
3. Ask: "Move to the next item, or are we done for today?"
4. If continuing, return to Phase 2 for the next selected item.

---

## Notes

- This skill is read-only. All edits happen in the normal conversation after the
  walkthrough is presented and the user confirms.
- Quick Win walkthroughs use the lightweight format (TASK + WHY only). CRITICAL and
  OPTIONAL items use the full format. User confirmation is required before work starts
  in both cases.
- Calibrate explanation depth to a 2nd-year applied economics PhD student: technically
  literate, has taken econometrics sequences, but may not have deep expertise in every
  identification strategy or software tool. This applies to both project types — for
  software packages, assume the same technical baseline plus working R/Python fluency,
  not professional software-engineering background.
