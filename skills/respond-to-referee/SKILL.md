---
name: respond-to-referee
description: Structure point-by-point referee responses using the revision-protocol routing. Classifies comments (NEW ANALYSIS / CLARIFICATION / DISAGREE / MINOR), dispatches appropriate agents, and tracks revisions. Use when asked to "respond to referees" or "draft revision".
version: 1.0.0
argument-hint: "[referee-report file path] [paper file path (optional)]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Task"]
source: clo-author
author: Hugo Sant'Anna
adapted_by: Matthew Mair
adaptation: moderate
upstream_url: https://github.com/hugosantanna/clo-author/blob/24abd60ba532ee8db11b6b13e46595587258c1ca/.claude/skills/respond-to-referee/SKILL.md
last_synced: 2026-08-25
upstream_status: removed upstream 2026-03-05; folded into /revise
---

# Respond to Referee

Structure a point-by-point response to referee reports with classification, agent routing, and diplomatic drafting.

**Input:** `$ARGUMENTS` — path to referee report file(s). Optionally followed by paper path.

> **Adaptation notes:**
> - `disable-model-invocation: true` from the original frontmatter has no effect globally — omitted.
> - `revision-protocol.md` is a clo-author rule file not loaded globally. The full classification
>   logic is reproduced inline below — no external dependency.
> - Output goes to `quality_reports/` — create the directory if it doesn't exist in the project.
> - Paper defaults to `Paper/main.tex`; override via `$ARGUMENTS`.

---

## Workflow

### Step 1: Parse Inputs

1. Read referee report(s) from `$ARGUMENTS`
   - If path not explicit, check `correspondence/` for referee report files
   - Support multiple reports (Referee 1, Referee 2, Editor)
2. Read the paper from `$ARGUMENTS` if a `.tex` path is provided. If not, glob `tex/*.tex` — use the single result, or ask the user if multiple files are found.
3. Read existing scripts in `code/` to know what analyses already exist

### Step 2: Classify Every Comment

Assign each referee point to one of the following classes:

| Class | Routing | Action |
|-------|---------|--------|
| **NEW ANALYSIS** | → User (mandatory) | Flag for user approval; handle inline or dispatch `econometrician` agent for ID/spec review |
| **CLARIFICATION** | → Inline | Draft revised text directly in conversation |
| **REWRITE** | → Inline | Draft structural revision directly in conversation |
| **DISAGREE** | → User (mandatory) | Draft diplomatic pushback, flag for review |
| **MINOR** | → Inline | Draft fix directly in conversation |

### Step 3: Build Tracking Document

Save to `quality_reports/referee_response_tracker.md`:

```markdown
# Referee Response Tracker: [Paper Title]
**Date:** [YYYY-MM-DD]
**Journal:** [if known]
**Decision:** [R&R / Major Revision / Minor Revision]

## Summary
- Referee 1: N comments (X new analysis, Y clarification, Z disagree, W minor)
- Referee 2: N comments (...)
- Editor: N comments (...)
- **Total new analyses required:** X

## Action Items (Priority Order)

### HIGH: New Analysis Required
| # | Ref | Point | Agent | Status |
|---|-----|-------|-------|--------|
| 1 | R1.3 | [Brief] | Coder | TODO |

### MEDIUM: Clarification / Rewriting
| # | Ref | Point | Agent | Status |
|---|-----|-------|-------|--------|
| 1 | R1.1 | [Brief] | Writer | TODO |

### FLAGGED: Disagreements (require user review)
| # | Ref | Point | Draft Response |
|---|-----|-------|---------------|
| 1 | R2.5 | [Brief] | [Draft] |

### LOW: Minor Edits
- [ ] R1.7: Fix typo on p. 12
```

### Step 4: Handle CLARIFICATION/REWRITE/NEW ANALYSIS

For comments classified as CLARIFICATION or REWRITE:
- Draft revised text inline, matching the user's academic voice
- Preserve all technical content and citation density

For NEW ANALYSIS:
- Do NOT proceed automatically — flag for user approval first
- Create a concrete task description for each required analysis
- If the analysis involves an identification or specification question, offer to dispatch the `econometrician` agent for review after user approves

### Step 5: Draft Response Letter

```latex
\documentclass[12pt]{article}
\usepackage[margin=1in]{geometry}
\usepackage{xcolor}
\definecolor{response}{RGB}{0,0,128}

\begin{document}

\title{Response to Referee Reports}
\author{[Authors]}
\date{\today}
\maketitle

Dear Editor,

We thank the editor and referees for their careful and constructive comments.
We have revised the manuscript to address all points raised.

\bigskip

\textbf{Summary of major changes:}
\begin{enumerate}
\item [Major change 1 — addresses R1.3, R2.1]
\item [Major change 2 — addresses R1.5]
\end{enumerate}

\newpage
\section*{Response to Referee 1}

\subsection*{Comment 1.1}
\textit{[Exact quote of referee comment]}

\medskip
\textcolor{response}{%
\textbf{Response:} [Draft response]

\textbf{Paper change:} [Section X, page Y]
}

\end{document}
```

### Step 6: Diplomatic Disagreement Protocol

When classification is **DISAGREE**:
1. Open with acknowledgment
2. Provide specific evidence (theorem, data, published result)
3. Offer partial concession where possible
4. **Never say:** "The referee is wrong/misunderstood"
5. **Instead say:** "We respectfully note...", "Upon reflection, we believe..."
6. **FLAG prominently** for user review

### Step 7: Save Outputs

1. **Tracker:** `correspondence/referee_response_tracker.md`
2. **Response letter:** `correspondence/referee_response_[journal]_[date].tex`
3. **Revised sections:** `tex/` (only for CLARIFICATION/REWRITE items)

---

## Principles

- **The response letter is the user's voice.** Match their academic tone.
- **Never fabricate results.** Mark NEW ANALYSIS items as TBD.
- **Flag all DISAGREE items.** These need human judgment.
- **Prioritize editor's comments.** The editor signals which concerns matter most.
- **Track everything.** Every referee comment appears in both tracker and response letter.
