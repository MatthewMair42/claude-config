---
name: compiledeck
description: Create and compile beautiful Beamer presentations following the Rhetoric of Decks philosophy. Use when making slides, creating decks, or compiling .tex presentation files.
allowed-tools: Bash(pdflatex*), Bash(latexmk*), Bash(ls*), Bash(open*), Bash(python*), Read, Write, Edit, Glob, Grep
argument-hint: [topic-or-tex-file-path]
source: mixtapetools
author: Scott Cunningham
adapted_by: Matthew Mair
adaptation: moderate
upstream_url: https://github.com/scunning1975/MixtapeTools/blob/main/.claude/skills/compiledeck/SKILL.md
last_synced: 2026-10-12
upstream_status: >
  Active. Since this fork, upstream split deck work across three skills:
  `compiledeck` (mechanical compile loop, preamble templates, palette, TikZ
  rules — still the layer this file tracks), `beautiful_deck` (end-to-end
  authoring: audience triage, original theme design, three-act narrative arc,
  code-first figures, rhetoric and graphics audit agents), and `tikz`
  (measurement-based collision audit). `beautiful_deck` delegates compilation
  to `compiledeck` rather than duplicating it, so this skill remains the
  correct counterpart — it has not been superseded.
---

# Compile Deck

Create beautiful Beamer presentations. This skill enforces the **Rhetoric of Decks** philosophy through concrete, measurable rules — not aspirational guidance.

## Step 1: Triage

Before touching anything, answer three questions:

**Q1: New deck or editing existing?**
- If editing: Read the `.tex` file first. Understand its palette, structure, and style before changing anything.
- If new: Proceed to Q2.

**Q2: Who is the audience?**
1. **Academic seminar** — sparse, one idea per slide, titles carry the argument
2. **Teaching lecture** — clarity over compression, repetition OK, progressive revelation
3. **Working deck** (coauthors) — more detail OK, document choices, preserve uncertainty
4. **External non-academic** — storytelling, visual impact, minimal jargon

See `domain_patterns.md` for detailed guidance per audience type.

**Q3: What's the tone?**
1. **Professional/Academic** — use the Warm Professional palette (default) or Academic Muted
2. **Colorful/Expressive** — create something new each time. See `palette_reference.md` for inspiration.

---

## Step 1.5: The Outline Checkpoint (new decks only)

Before writing any slides, design the arc (Step 6) and write it to
`<deck>_outline.md` next to the `.tex`. Show it to the user and **wait for
approval**. Fixing an arc here costs one file; fixing it after every slide is
written costs a rewrite. Skip this step when editing an existing deck.

```markdown
# <Deck name> — Outline

## Audience and tone
<Q2 and Q3 answers>

## The one sentence
<What the audience should remember tomorrow — this becomes the closing slide.
If it cannot be stated in one sentence, resolve that before going further.>

## The arc
### Act I — Setup (slides 1–4)
  1. Title
  2. Opening: <puzzle, surprise, or provocation>
  3. Stakes: <why this matters>
### Act II — Development (slides 5–N)
  5. <Assertion title>
  ...
### Act III — Resolution
  K. Closing: <the one sentence>

## Figures and tables
  - <what each shows, and the script that generates it>
```

Read only the titles in sequence. If they do not tell the argument on their
own, the arc is broken — fix it here.

---

## Step 2: The Non-Negotiable Rules

These are not guidelines. They are constraints.

### ONE idea per slide
If a slide has two ideas, split it. No exceptions.

### Titles are assertions, not labels
- Bad: "Results"
- Good: "Treatment increased distance by 61 miles on average"
- Bad: "Literature Review"
- Good: "Prior work ignores the supply-side margin"

If someone reads only the slide titles in sequence, they should understand the entire argument.

### Typography minimums
- Body text: 24pt minimum
- Absolute floor (footnotes, source notes): 18pt
- Sans-serif fonts only
- Never justify text — always ragged right

### No bullet lists (usually)
Bullets are a confession that you haven't found the structure. Look for:
- A sequence (use a flow diagram)
- A contrast (use two columns)
- A hierarchy (use size/color differentiation)
- A causal chain (use arrows)

Exception: genuinely parallel items (e.g., a list of axioms in a teaching deck).

### Charts: one message, direct labels
- Every chart communicates ONE finding
- Title states the finding ("Enrollment doubled after 2015"), not the chart type ("Enrollment Over Time")
- Label data directly on the chart — no legends requiring eye movement
- Remove all chartjunk: gridlines, borders, unnecessary axis marks

### White space is confidence, not waste
Empty space on a slide signals that you chose carefully. A full slide signals anxiety.

### Zero compile warnings
Not "try to fix." Zero. See the Compile Loop below.

---

## Step 3: The Preamble

For new decks, use this template. It is extracted from real decks that work.

### Default: Warm Professional Palette (10 colors)

```latex
\documentclass[aspectratio=169,11pt]{beamer}

% Packages
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{lmodern}
\usepackage{microtype}
\usepackage{amsmath,amssymb}
\usepackage{booktabs}
\usepackage{graphicx}
\usepackage{tikz}
\usepackage{pgfplots}
\usepackage{xcolor}
\usepackage{ragged2e}
\usepackage{colortbl}
\usepackage{array}
\usepackage{hyperref}
\usepackage{adjustbox}

\usetikzlibrary{shapes.geometric, arrows.meta, positioning, calc,
                backgrounds, decorations.pathreplacing, shadows, fadings}
\pgfplotsset{compat=1.18}

% --- Color Palette: Warm Professional ---
\definecolor{DeepNavy}{HTML}{2E4057}
\definecolor{Teal}{HTML}{048A81}
\definecolor{WarmOrange}{HTML}{E85D04}
\definecolor{SoftPurple}{HTML}{9D4EDD}
\definecolor{WarmGray}{HTML}{6C757D}
\definecolor{LightGray}{HTML}{E9ECEF}
\definecolor{Cream}{HTML}{FBF8F1}
\definecolor{DeepRed}{HTML}{D62828}
\definecolor{Gold}{HTML}{D4A03A}
\definecolor{SoftWhite}{HTML}{FAFAFA}

% Beamer colors
\setbeamercolor{normal text}{fg=DeepNavy, bg=SoftWhite}
\setbeamercolor{structure}{fg=DeepNavy}
\setbeamercolor{alerted text}{fg=DeepRed}
\setbeamercolor{example text}{fg=Teal}
\setbeamercolor{frametitle}{fg=DeepNavy, bg=SoftWhite}
\setbeamercolor{title}{fg=DeepNavy}
\setbeamercolor{subtitle}{fg=WarmGray}
\setbeamercolor{block title}{bg=DeepNavy, fg=SoftWhite}
\setbeamercolor{block body}{bg=LightGray, fg=DeepNavy}
\setbeamercolor{itemize item}{fg=WarmOrange}
\setbeamercolor{itemize subitem}{fg=Gold}

% Fonts
\usefonttheme{professionalfonts}
\setbeamerfont{title}{size=\huge, series=\bfseries}
\setbeamerfont{frametitle}{size=\Large, series=\bfseries}

% Strip chrome
\setbeamertemplate{navigation symbols}{}
\setbeamertemplate{headline}{}

% Minimal footline
\setbeamertemplate{footline}{%
    \hfill
    \begin{beamercolorbox}[wd=3cm,ht=2.5ex,dp=1ex,right,rightskip=0.6cm]{page number}
        \usebeamercolor[fg]{WarmGray}\scriptsize\insertframenumber
    \end{beamercolorbox}
    \vspace{0.3cm}
}

% Bullets
\setbeamertemplate{itemize item}{\footnotesize\raisebox{0.3ex}{\tikz\fill[WarmOrange] (0,0) circle (0.45ex);}}
\setbeamertemplate{itemize subitem}{\footnotesize\raisebox{0.3ex}{\tikz\fill[Gold] (0,0) circle (0.35ex);}}

% Custom commands
\newcommand{\transitionslide}[2]{%
    {\setbeamercolor{normal text}{fg=SoftWhite,bg=DeepNavy}
    \begin{frame}[plain]\vfill\begin{center}
        {\huge\bfseries\textcolor{Gold}{#1}}\\[0.6cm]
        {\large\textcolor{LightGray}{#2}}
    \end{center}\vfill\end{frame}}
}

\graphicspath{{figures/}}
```

For alternative palettes, see `palette_reference.md`.

---

## Step 4: Slide Architecture Patterns

### Opening slide (first content slide after title)
**NOT** "Motivation" with bullet points. Instead:
- A surprising fact or statistic (big number, centered)
- A puzzle or unanswered question
- A provocative claim that the deck will support

### Transition slides
Use `\transitionslide{Section Title}{Subtitle}` for dark-background section dividers.

### Closing slide
**NOT** "Questions?" or "Thank you." Instead:
- The ONE sentence the audience should remember tomorrow
- Full-bleed dark background with the takeaway centered

### Devil's Advocate slide (academic decks)
Present the strongest objection to your argument, then respond to it. This builds credibility.
Format: "A skeptic would say..." followed by your response.

### TikZ diagram slides
Read `tikz_rules.md` BEFORE creating any TikZ figure. The rules are measurement-based — they prevent text from overlapping arrows, boxes, and other objects.

**Critical rule preview**: Before placing a label between two nodes, CALCULATE the edge-to-edge gap and compare it to the estimated text width. If the text is wider than the gap minus 0.6cm padding, the label WILL collide. Move it above/below or shorten the text.

**Never define a parameterized TikZ style inside a frame.** Beamer's frame
parser consumes `#` before TikZ sees it, producing "Illegal parameter number"
errors that cascade through the compile and resist the usual workarounds
(`##1`, `[fragile]`, `\catcode`). Define every style that takes `#1` in the
preamble with `\tikzset{...}`; inside frames, only *use* styles.

---

## Step 5: The Compile Loop

After EVERY edit to a .tex file:

### 5a: Compile
```bash
pdflatex -interaction=nonstopmode [file].tex
```

### 5b: Check for fatal errors
```bash
grep "^!" [file].log
```
If any: fix, recompile, repeat.

### 5c: Check for ALL warnings
```bash
grep -cE "Overfull|Underfull" [file].log
```

This must return **0**. For EACH warning:

| Warning | Fix |
|---------|-----|
| Overfull \hbox | Rephrase shorter, use `\adjustbox`, add `@{}` to table columns |
| Underfull \hbox | Rephrase or adjust paragraph breaks |
| Overfull \vbox | Split the slide or reduce `\vspace`, tighten content |
| Underfull \vbox | Add `\vfill` or adjust spacing |

Even 0.5pt overfull must be fixed. Do NOT proceed until the count is 0.

### 5d: Check fonts
```bash
grep -i "font" [file].log | grep -i "warning"
```

### 5e: TikZ verification (Bézier-first workflow)

TikZ errors don't trigger compile warnings. You must catch them yourself. Follow this order — curves first, everything else second:

**Pass 1 — Find and fix all Bézier curves:**
```bash
grep -n "bend" [file].tex
```
For EACH curved arrow found:
1. Calculate max depth: `(chord / 2) × tan(bend_angle / 2)`
2. Add 0.5cm safety margin
3. Check: is any label within the danger zone? Move it if so.
4. Check: does the curve cross any other arrow? Re-route if so.

**Pass 2 — Everything else:**
- Gap calculation: for every label between two nodes, is estimated text width < usable gap?
- Arrow labels: does every one have `above`, `below`, `left`, or `right`?
- No nodes clipped by slide edges
- All arrows pointing to intended targets

**Pass 3 — Open the PDF and visually confirm.**

Full rules and formulas are in `tikz_rules.md`. This verification runs on ALL TikZ figures in the deck, not just the one you just edited.

### 5f: Open the PDF
Skip this step. The user will open the PDF manually.

### 5g: The circuit breaker
If **three different approaches** to the same error have failed, STOP editing.
Quote the log line, list the three approaches and why each failed, and ask the
user how to proceed. Every failed fix leaves the file harder to repair than
before. "The same error" means one that persists at, or moves near, the same
line after a fix; a warning on a different slide is a new error and resets the
count. This overrides "recompile until clean": zero warnings is the goal, not a
licence for unlimited attempts.

---

## Step 6: The Narrative Arc

Every deck tells a story. The structure depends on context, but the principle is universal:

**Act I — Setup**: Establish the problem or question. Make the audience feel it.
**Act II — Development**: Present evidence, analysis, investigation. Build the logical case.
**Act III — Resolution**: Deliver the insight. State implications. Give the audience something to do or remember.

Two ordering rules apply inside the arc. They govern different kinds of content,
so they do not conflict:

**Presenting findings → the Pyramid Principle.** Lead with the conclusion, then
support it. Academic audiences expect this. Do not build suspense — state the
finding, then prove it.

**Teaching a concept → the pedagogical movement.** Whenever a slide sequence has
to make the audience *understand* something — a method, an identification
strategy, a model, a definition — move in this order, never the reverse:

**Narrative → Application → Picture → Codeblock → Technical**

| Stage | What it looks like |
|---|---|
| Narrative | A concrete scene: a named place, a real decision, a real problem |
| Application | A specific example the audience can hold: "suppose you are a county assessor…" |
| Picture | One figure or diagram that shows the pattern before it is named |
| Codeblock | A short snippet showing how it is computed (optional where code adds nothing) |
| Technical | The equation, assumption, or estimator — as a summary of what the audience already intuits |

The anti-pattern is opening with definitions, stating the theorem, and offering
an example "for intuition" at the end: it treats the technical as primary and
intuition as decoration. The formal statement is what the audience walks away
with, not what they walk in with. If an equation appears before the picture that
motivates it, swap them.

*Exceptions:* a load-bearing term may be defined early, but give the plain-English
meaning first and the formal definition on the next slide. Title slides, roadmaps,
and section dividers are structural and exempt.

*Typical split:* a teaching lecture is mostly pedagogical movement; a research
seminar uses the Pyramid for results and the movement for the methods slides
that explain how those results were identified.

For domain-specific structures, see `domain_patterns.md`.

---

## Step 7: Figure Generation

When a deck needs data visualizations:

1. Write a Python script (`generate_figures.py`) using matplotlib
2. Use the same color palette as the LaTeX deck
3. Save figures as PDF (vector, not raster) to a `figures/` subdirectory
4. Every figure: one message, direct labels, title states the finding
5. Match the deck's background color in `fig.set_facecolor()`

---

## Quick Reference

| Principle | Rule |
|-----------|------|
| Ideas per slide | ONE |
| Title style | Assertion, not label |
| Minimum font | 24pt (18pt floor) |
| Bullets | Avoid — find the structure |
| White space | Confidence, not waste |
| Charts | One message, direct labels |
| Compile target | Zero warnings |
| Opening slide | Puzzle, surprise, or provocation |
| Closing slide | One memorable takeaway |
| TikZ labels | Calculate the gap (see tikz_rules.md) |
| Color palette | 10+ colors, warm by default |
| Narrative | Setup, Development, Resolution |
| Before slides | Outline in `<deck>_outline.md`, approved by user |
| Findings | Conclusion first (Pyramid) |
| Concepts | Narrative → Application → Picture → Code → Technical |
| TikZ styles with `#1` | Preamble only, via `\tikzset` |
| Same error, 3 failed fixes | Stop and ask |

---

## Upstream Lineage

This skill covers the **mechanical** half of deck work: the compile loop,
preamble templates, the Warm Professional palette, and TikZ rules.

Upstream has since added `beautiful_deck`, which covers the **authoring**
half — audience triage with an Aristotelian logos/ethos/pathos balance,
per-audience theme design, a three-act narrative arc with a mandatory outline
checkpoint, code-first figure generation, and separate rhetoric and graphics
audit agents. It calls `compiledeck` for compilation rather than reimplementing
it, and reads the palette from this file.

Ported from `beautiful_deck` on 2026-10-12:

- **The outline checkpoint** (Step 1.5).
- **The pedagogical movement** (Step 6), scoped here to teaching a concept, so
  it sits alongside the Pyramid Principle for findings instead of replacing it.
- **Rule 6** (no parameterized TikZ styles inside frames) and the **circuit
  breaker** (Step 5g).

Not ported: original per-deck theme design, the Aristotelian audience table,
code-first standalone figure scripts, the MB/MC rhythm check, and the rhetoric
and graphics audit agents. Those depend on `/tikz` and on essays this repo does
not ship; adopting them is a separate decision.

## Supporting Files

All in this skill's directory:

- **tikz_rules.md** — Measurement-based TikZ collision prevention rules. READ THIS before creating any TikZ diagram.
- **palette_reference.md** — Four real palettes extracted from existing decks, with a selection guide.
- **domain_patterns.md** — Detailed structural patterns for academic seminars, teaching lectures, and working decks.
