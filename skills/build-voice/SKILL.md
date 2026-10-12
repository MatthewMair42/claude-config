---
name: build-voice
description: |
  Analyze a corpus of the user's human-written papers and build a persistent voice profile at ~/.claude/private/voice-profile.md.
  Use when setting up the voice skill suite for the first time, or after adding new writing samples.
  Reads .tex, .txt, and .pdf samples; each PDF is read once and its prose saved to a reusable extract.
author: Matthew Mair
version: 1.1.0
argument-hint: "[optional: extra .tex, .txt, or .pdf file paths beyond the default writing-samples/ directory]"
allowed-tools: ["Read", "Write", "Glob", "Bash", "Agent"]
---

# Build Voice Profile

Analyze a corpus of the researcher's human-written academic papers and synthesize a structured voice profile saved to `~/.claude/private/voice-profile.md`. This profile is the shared foundation for `/voice-review` and `/voice-write`.

**Input:** `$ARGUMENTS` — optional extra file paths. Default corpus is all `.tex`, `.txt`, and `.pdf` files in `~/.claude/private/writing-samples/`.

---

## Workflow

### Step 1: Collect Files

1. Glob `~/.claude/private/writing-samples/*.tex`, `*.txt`, and `*.pdf`.
2. If `$ARGUMENTS` contains additional paths, add them.
3. If the combined file list is empty, **halt** with this message:

   > No writing samples found. Drop `.tex`, `.txt`, or `.pdf` files into `~/.claude/private/writing-samples/` and re-run `/build-voice`.

4. **Note each file's provenance.** A file whose name marks AI involvement (e.g.
   "(written with some AI assistance)") is *AI-assisted*; everything else is
   *human-written*. Do not drop or rename these tags — the filename is where the
   provenance lives, and losing it would let a rebuild treat assisted prose as
   ground truth.
5. Report the list of files to be analyzed, with provenance, before proceeding.

### Step 1.5: Extract PDF Prose (once per PDF)

A PDF is read once. Its prose is saved to `<basename>_voice.md` next to the PDF,
and every later rebuild reads that extract instead of the PDF.

For each PDF:

1. **Extract exists** — if `<basename>_voice.md` sits beside the PDF, use it and
   skip the PDF entirely.
2. **Text layer** — otherwise, try pulling text with pypdf. Python's path is in
   `~/.claude/machine.md`; never trust a bare `python` on Windows. If it yields
   roughly 100+ words per page, write the text to `<basename>_voice.md` and
   continue. No page images are read.
3. **Scanned PDF** (no usable text layer) — use the `/split-pdf` mechanics with one
   change in what is extracted:
   - Split into 4-page chunks in `writing-samples/split_<basename>/` (the split
     script is in `/split-pdf` Step 2). Never delete the original PDF.
   - **Always read in a subagent** — this skill keeps working after the read, so
     page images must not land in the parent conversation (`/split-pdf`, Agent
     Isolation Protocol). The subagent reads 3 chunks at a time.
   - **Transcribe, don't summarize.** Unlike `/split-pdf`'s 8 research
     dimensions, the voice analysis needs the author's actual sentences. The
     subagent copies body prose verbatim — preserving punctuation, hedges, and
     transitions exactly — and skips equations, tables, figures, captions,
     headers/footers, page numbers, and the reference list. Section headings stay
     as `##` lines. Illegible text is marked `[illegible]`, never guessed.
   - The subagent appends to `<basename>_voice.md` after each batch, so an
     interrupted read resumes from the last chunk written.
4. Begin every extract with a header line recording source file, method
   (`text layer` or `scanned, N chunks`), date, and provenance. Then tell the user
   which extracts were created or reused.

`split_<basename>/` is a working copy and can be regenerated; the extract is the
durable artifact.

### Step 2: Extract Prose

For each file (for PDFs, read the `_voice.md` extract — never the PDF itself):

1. Read the full content.
2. **Strip LaTeX boilerplate** — discard:
   - Everything before `\begin{document}` (preamble)
   - `\begin{equation}` / `\end{equation}` and all math environments (`align`, `gather`, `multline`, `eqnarray`, `equation*`, etc.)
   - `\begin{figure}` / `\begin{table}` blocks and their contents
   - `\begin{lstlisting}` / `\begin{verbatim}` blocks
   - `\bibliography`, `\bibitem`, and `thebibliography` blocks
   - `\maketitle`, `\tableofcontents`, `\listoffigures`
3. **Retain** text inside: `abstract`, `section`, `subsection`, plain paragraph text, `quote`, `quotation` environments.
4. Strip remaining LaTeX commands (e.g., `\textit{}`, `\cite{}`, `\label{}`, `\ref{}`, `\footnote{}`) but keep their text content where applicable.
5. Collect the cleaned prose from all files into a single analysis corpus. Track approximate word count, per provenance.

**Weighting by provenance.** Human-written samples are the ground truth for
sentence-level voice (Dimensions 1, 2, 5, 6, 7). AI-assisted samples may inform
content framing (Dimensions 3, 4), but must not be the sole source for any
sentence-level pattern. If the corpus has no human-written sample, say so in the
profile's Corpus note rather than presenting the profile as the author's voice.

### Step 3: Analyze — 7 Dimensions

Work through each dimension carefully. For each dimension, (a) write a 2–4 sentence description of the observed pattern, and (b) extract 3–6 verbatim examples from the cleaned corpus that best illustrate it. Examples should be quoted exactly as they appear in the original prose (before LaTeX stripping), short enough to scan quickly (one sentence to one short paragraph each).

#### Dimension 1: Sentence Architecture
Examine:
- Typical sentence length (short = <15 words, medium = 15–30, long = 30+) — estimate the rough distribution
- How often subordinate clauses are used, and where they appear (before or after the main clause)
- Punctuation habits: comma density, use of em-dashes, semicolons, parenthetical asides
- Preference for active vs. passive voice at the sentence level

#### Dimension 2: Hedging Signature
Examine:
- The specific words and phrases used to hedge claims (e.g., "appear to", "consistent with", "we interpret this as", "suggest", "may reflect")
- Which types of claims get hedged (causal claims? descriptive claims? mechanism claims?) vs. which are stated directly
- Whether hedging clusters at the end of paragraphs or is distributed throughout

#### Dimension 3: Argument Structure
Examine:
- How empirical evidence is introduced (e.g., "Table X shows...", "Column (3) of Table X reports...", "The estimate in row Y...")
- Whether the writing is coefficient-first ("The coefficient on X is 0.05...") or interpretation-first ("X is associated with a 5 percentage point increase...")
- How findings are connected to the identification strategy or theory

#### Dimension 4: Methodological Language
Examine:
- How identification claims are stated (e.g., "We exploit variation in...", "Our identification assumption is...", "The key assumption is...")
- How robustness checks are described and framed
- How limitations or caveats are introduced and scoped
- Whether assumptions are defended or just stated

#### Dimension 5: Transition Fingerprint
Examine:
- The specific transition words and phrases that appear repeatedly, and in what positions (paragraph opener, mid-paragraph pivot, section bridge)
- How the writing moves between results (e.g., "Turning to...", "Next, we examine...", "A natural concern is...")
- Whether transitions are explicit signposts or implicit (built into the logic of the sentence)

#### Dimension 6: Engagement Register
Examine:
- Whether "we" or passive voice is the primary engagement mode, and whether this varies by section
- How often the reader is addressed or anticipated ("One might worry that...", "Note that...", "It is worth emphasizing...")
- Whether the writing is formal and distant or has a more direct, conversational quality
- Use of first-person ("we find", "we show") vs. distanced phrasing ("the results suggest", "the evidence indicates")

#### Dimension 7: Opening and Closing Patterns
Examine:
- How paragraphs typically begin: direct claim, context-setting, question-raising, evidence-first
- How paragraphs typically close: forward-looking implication, call-back to thesis, open question, summary
- How sections open (broad framing vs. immediate specifics) and close (does the author recap or move directly into the next section?)

### Step 4: Write Voice Profile

Write the analysis to `~/.claude/private/voice-profile.md` using this format:

```markdown
# Voice Profile — <researcher name from private/profile.md>
**Built:** YYYY-MM-DD
**Corpus:** [list filenames, one per line, each with its provenance: human-written or AI-assisted]
**Prose words analyzed:** ~N

> **Corpus note:** [which samples set sentence-level voice, and which only inform framing]

> This profile is manually editable. Add, remove, or annotate any section. Re-run
> `/build-voice` to regenerate from the corpus, which will overwrite this file.

---

## 1. Sentence Architecture

[2–4 sentence description of observed patterns]

**Corpus examples:**
- "[verbatim example 1]"
- "[verbatim example 2]"
- "[verbatim example 3]"

---

## 2. Hedging Signature

[2–4 sentence description]

**Corpus examples:**
- "[example]"
...

---

## 3. Argument Structure
...

## 4. Methodological Language
...

## 5. Transition Fingerprint
...

## 6. Engagement Register
...

## 7. Opening and Closing Patterns
...

---

## Manual Annotations

> Add notes here that override or extend the above analysis. These are preserved across
> `/build-voice` rebuilds only if you copy them back in manually after regeneration.
```

### Step 5: Report to User

Tell the user:
- Which files were analyzed and total prose word count
- Path to `voice-profile.md`
- Top 2–3 most distinctive findings (what stands out as most characteristic)
- Reminder: **review the profile together before using `/voice-review` or `/voice-write`**
- That the profile is editable — annotate freely, then re-run `/build-voice` only when adding new corpus files

---

## Principles

- **Corpus-only.** Extract examples only from the provided writing samples — never invent or import external writing conventions.
- **Concrete over abstract.** Every dimension description must be anchored by at least 3 verbatim examples. No hand-waving.
- **Overwrite on rebuild.** Running `/build-voice` again overwrites `voice-profile.md`. Manual annotations in the `## Manual Annotations` section are the user's responsibility to preserve.
- **Prose only.** Math, tables, figures, and bibliography are not voice signals — exclude them from analysis.
