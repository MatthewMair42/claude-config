---
name: voice-review
description: |
  Audit a .tex file or text block for alignment with the stored voice profile, outputting a numbered suggestion report.
  Use when reviewing prose that may have drifted from the researcher's natural writing voice (e.g., AI-assisted drafts, co-authored sections).
author: Matthew Mair
version: 1.1.0
argument-hint: "[file path to .tex, .md, or .txt — or paste inline text] [optional: --section <name>]"
allowed-tools: ["Read", "Write", "Grep", "Glob"]
---

# Voice Review

Audit a piece of academic writing for alignment with the researcher's voice profile. Read-only — produces a numbered suggestion report; never edits the source file.

**Input:** `$ARGUMENTS` — file path or inline text. Accepts `.tex`, `.md`, `.txt`. Optionally append `--section <name>` (e.g., `--section intro`) to focus the review on a single named section rather than the full document.

**Requires:** `~/.claude/private/voice-profile.md` — run `/build-voice` first if missing.

---

## Workflow

### Step 1: Load Voice Profile

1. Read `~/.claude/private/voice-profile.md`.
2. If the file does not exist, **halt**:

   > Voice profile not found. Run `/build-voice` first to generate your profile from writing samples.

3. Parse all 7 dimensions. Also load any content under `## Manual Annotations`.
4. Note the corpus composition: Examples 1 and 2 are fully human-written (**strong signal** for sentence-level patterns); Examples 3 and 4 were written with AI assistance (**limited signal** for sentence-level patterns, stronger for methodological/identification language).

### Step 2: Read Target Text

1. If the argument contains `--section <name>`, extract the section name and set a section filter. Only prose within that section will be analysed in Step 3.
2. If the argument is a file path, read the file. For `.tex` files, strip LaTeX boilerplate: remove preamble, math environments, figure/table blocks, bibliography. Retain prose paragraphs.
3. If the argument appears to be inline text (no file extension, or no matching file found), treat it as the raw text to review.
4. If a section filter is set, isolate the matching section(s) from the prose. If no match is found, note this and analyse the full document.
5. Split the prose into paragraphs for analysis. Number them for reference.

### Step 2.5: Assess Genre

Before checking for deviations, identify the **genre** of the target text. This governs which dimension patterns are applicable.

**Classify as one of:**
- **Empirical** — contains data analysis, results, coefficient tables, identification strategy, robustness checks
- **Theory/Conceptual** — develops a theoretical argument, formal model, or conceptual framework; no empirical results
- **Literature Review** — surveys prior work; argues through synthesis of existing literature

**Genre-applicability by dimension:**

| Dimension | Empirical | Theory/Conceptual | Lit Review |
|---|---|---|---|
| 1. Sentence Architecture | Full | Full | Full |
| 2. Hedging Signature | Full | Full | Full |
| 3. Argument Structure | Full (incl. coefficient-first check, table/figure refs) | Partial (enumeration and pairing patterns apply; coefficient/table patterns do not) | Partial (citation-as-subject pattern applies; pairing patterns apply) |
| 4. Methodological Language | Full | Partial (limitation-stating and assumption-stating apply; "we employ/apply" for identification may not) | Limited |
| 5. Transition Fingerprint | Full | Full | Full |
| 6. Engagement Register | Full | Full (note: "This paper" subject is appropriate for theory/lit review genre) | Full |
| 7. Opening and Closing Patterns | Full | **Limited** (opener patterns primarily attested in empirical corpus; treat findings here with lower confidence) | Partial |

**Tag any finding that arises from a dimension marked Partial or Limited for this genre as `[Genre-limited]`.** These findings are lower confidence — flag but do not prioritise over Full-applicability findings.

### Step 3: Check for Voice Deviations

Work through each applicable dimension. For each dimension, identify passages in the target text that deviate from the profiled pattern. A deviation is a passage where the writing does something the profile identifies as *not* characteristic of the researcher's voice — or conspicuously avoids something the profile says they *do* do.

**Deviation types by dimension:**

1. **Sentence Architecture** — sentences consistently longer or shorter than profiled norm; em-dashes used prominently as a parenthetical device (profile: parentheses are the standard for inline definitions and qualifications; em-dashes are *not* a prominent feature); active/passive ratio inverted; two distinct ideas joined by semicolon rather than split into separate sentences
2. **Hedging Signature** — hedges claims the profile shows they state directly; uses hedging phrases not in their vocabulary; omits hedging on mechanism claims or causal interpretations the profile shows they always hedge
3. **Argument Structure** — evidence introduced with non-profiled framing; [empirical only] interpretation-first where profile is coefficient-first (or vice versa); findings not paired with implication; contribution enumeration absent at section transitions
4. **Methodological Language** — [empirical] identification language absent or uses different register; robustness framed without motivation; limitations stated without the profiled scoping pattern; [theory/conceptual] constraints and scope conditions not stated proactively
5. **Transition Fingerprint** — uses transitions not in the researcher's fingerprint; "Crucially" absent at load-bearing claims; lacks adversative pivot where profile shows he bridges; over-signposts with formal meta-announcements ("X clarifications are necessary", "a word is required") rather than the profiled light reader-anticipation touch; [flagged AI phrase] "Having previously identified... we now turn to" — flag if present
6. **Engagement Register** — passive/we ratio inconsistent with profile; reader-anticipation language absent or over-used; [empirical] "This paper" in place of "we" in methods or results sections; [theory/lit review] "we" substituted for "This paper" as the primary agent — note: mixing both is acceptable when genre is mixed
7. **Opening and Closing Patterns** — [Full applicability] paragraphs close without adversative affirmation or cascading implication; section closings omit future directions; [Genre-limited for theory/conceptual] section openers deviate from scope-narrowing or definitional pattern — apply lower confidence here

**For each finding, assign two tags:**

**Severity:**
- `HIGH` — reader would likely notice the mismatch; meaningfully changes tone or register
- `MEDIUM` — subtle inconsistency; cumulative effect matters
- `LOW` — minor, easily missed; flag but deprioritize

**Corpus confidence:**
- `[Corpus: Strong]` — pattern is attested in fully human-written Examples 1 or 2
- `[Corpus: Limited]` — pattern is attested primarily in AI-assisted Examples 3 or 4, or has fewer than 3 corpus instances

**Do not flag** passages that are consistent with the profile, even if they seem unusual. Only flag genuine deviations.

**Before writing each finding**, ask: *Is this a true voice deviation, or a legitimate genre/context choice?* If in doubt and the paper type is Theory/Conceptual or Lit Review, default to [Genre-limited] rather than suppressing or promoting.

### Step 4: Write Suggestion Report

**Determine the output directory** by walking up from the source file's directory:
1. Starting from the source file's parent directory, check for a `correspondence/` folder or a `.claude/` folder or `CLAUDE.md` within 3 directory levels up. Use the first match as the project root.
2. If `correspondence/voice-review/` exists under that project root, write there.
3. If `correspondence/` exists but `voice-review/` does not, create `voice-review/` and write there.
4. If no `correspondence/` is found, write in the same directory as the source file (or CWD for inline text).

Write report to `[original-filename].voice-review.YYYY-MM-DD.md`. Use today's date.

Format:

```markdown
# Voice Review: [filename or "Inline Text"]
**Generated:** YYYY-MM-DD
**Profile built:** [date from voice-profile.md]
**Genre assessed:** [Empirical / Theory/Conceptual / Literature Review]
**Scope:** [Full document / Section: <name>]
**Deviations found:** N (HIGH: X, MEDIUM: Y, LOW: Z)

---

## Alignment Summary

**Well-aligned dimensions:** [list dimensions with no or only LOW findings — one clause each explaining what's working]

**Dimensions with deviations:** [list dimensions with MEDIUM or HIGH findings]

---

### Finding 1 of N — [Dimension] — [Severity] — [Corpus: Strong/Limited] [Genre-limited if applicable]

**Deviation:** [one-line description of what's wrong]

**Original:**
```
[exact quoted passage, 1–3 sentences]
```

**Suggested revision:**
```
[rewritten version that matches the profiled pattern]
```

**Why:** Conflicts with profile [Dimension N] — [quote the relevant profiled pattern or example].

---

### Finding 2 of N
...
```

**Ordering:** List HIGH findings first, then MEDIUM, then LOW. Within each severity group, list `[Corpus: Strong]` findings before `[Corpus: Limited]` ones.

### Step 5: Report to User

Tell the user:
- Path to the suggestion report
- Total findings by severity (HIGH / MEDIUM / LOW)
- Which dimensions had the most deviations (top 2–3)
- That the original file was **not modified**
- That they can apply suggestions manually, or ask you to apply specific ones by number

---

## Principles

- **Read-only.** Never modify the source file. All output goes to the `.voice-review.md` report only.
- **Profile-anchored.** Every finding must cite a specific pattern or example from `voice-profile.md`. Never flag something based on general writing quality alone.
- **Not a style guide.** This is not about "good writing" in the abstract — it is about *the researcher's* writing. Flag only deviations from the profile, not things you would personally improve.
- **Genre-aware.** Patterns attested only in empirical papers should not be applied at full confidence to theory or lit review texts. When in doubt, tag `[Genre-limited]` rather than either suppressing or promoting the finding.
- **Revisions must be at least as strong as the original.** A suggested revision that matches the voice profile but is duller, vaguer, or less rhetorically effective than the original is a bad revision. If you cannot write a revision that is both profile-consistent and at least as good as the original, say so explicitly rather than offering a weak substitute.
- **Manual annotations honored.** If `## Manual Annotations` in the profile overrides a dimension finding, apply the annotation.
- **Complement to prose-audit.** This skill is additive (does the prose match the profiled voice?) where `/prose-audit` is subtractive (which formulaic patterns should go?). Run `/prose-audit` first if needed; run `/voice-review` after. Both produce suggestions you accept or reject — neither edits your file.
- **User applies selectively.** Each suggestion is a proposal. The user decides what to accept.
