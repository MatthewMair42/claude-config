---
name: voice-write
description: |
  Generate academic prose in the researcher's voice from a structured outline or bullet points.
  Use when drafting a new section from scratch and wanting output that matches their natural writing patterns.
author: Matthew Mair
version: 1.0.0
argument-hint: "[outline or bullets as inline text, or --file path/to/outline.md] [--section intro|methods|results|discussion] [--journal JAERE|JEEM|AJAE|...]"
allowed-tools: ["Read", "Write", "Glob"]
---

# Voice Write

Generate a full section draft in the researcher's academic voice from a structured outline or bullet-point input. Does not write to file until the user confirms.

**Input:** `$ARGUMENTS` — outline or bullets (inline or via `--file path`). Optional flags:
- `--section intro|methods|results|discussion` — calibrates register for the section type
- `--journal JAERE|JEEM|AJAE|AER|...` — tightens register for the target venue

**Requires:** `~/.claude/private/voice-profile.md` — run `/build-voice` first if missing.

---

## Workflow

### Step 0: Clarify Audience and Venue

Before loading context or reading the outline, confirm two things:

1. **Target audience** — who is reading this? Examples: specialist journal referee, interdisciplinary academic audience, policy audience, general reader. If the user has named a target journal, infer audience from that.
2. **Target journal or venue** — if a manuscript, which journal? This calibrates register, citation density, hedging level, and how explicit identification language needs to be.

If neither is provided via `--journal` flag or inline in `$ARGUMENTS`, **ask explicitly before proceeding:**

> "Before I draft this — who is the target audience, and is there a target journal? (You can also say 'general academic' or 'policy audience' if it's not a specific venue.)"

Do not proceed to Step 1 until both are known.

---

### Step 1: Load Context

1. Read `~/.claude/private/voice-profile.md`.
2. If missing, **halt**:

   > Voice profile not found. Run `/build-voice` first to generate your profile from writing samples.

3. If the current project directory has a `.claude/domain-profile.md`, read it. Also read `~/.claude/private/domain-profile.md`. Use these alongside the audience/venue from Step 0 to calibrate register.
4. Parse `$ARGUMENTS`:
   - Extract any `--section` and `--journal` flags.
   - If `--file` is present, read the outline from that file path.
   - Otherwise, treat the remaining text as the inline outline.

### Step 2: Parse the Outline

1. Read the outline or bullet points provided.
2. Identify the top-level points (major claims or moves) and any sub-points (supporting evidence, qualifications, examples).
3. If the outline is ambiguous, ask one clarifying question before proceeding — do not guess at the intended argument.
4. Note: the goal is to generate prose that makes the *provided argument*, not to introduce new claims or re-order the logic.

### Step 3: Generate Draft

Write a full section draft with the following constraints, derived from the voice profile:

**Apply all 7 profile dimensions:**

1. **Sentence architecture** — match the profiled length distribution and punctuation habits. If the profile shows a mix of short and long sentences, replicate that rhythm. If it shows comma-heavy constructions or em-dash use, incorporate them naturally.

2. **Hedging signature** — use the same hedging vocabulary the profile identifies. Hedge where the profile shows they hedge (causal claims, mechanism interpretations), and be direct where they are direct (identification setup, summary of prior literature).

3. **Argument structure** — follow the profiled evidence-introduction pattern. If the profile shows coefficient-first presentation, use it. Structure evidence introduction using the profiled table/column reference conventions where applicable.

4. **Methodological language** — if generating a methods or results section, use the profiled identification language verbatim where possible (e.g., if the profile shows "we exploit variation in...", use that register). Frame robustness and limitations in the profiled register.

5. **Transition fingerprint** — use transitions from the profiled fingerprint. Avoid transitions that are absent from the profile even if they seem natural. If the profile shows implicit transitions (logic-driven rather than signpost-driven), do not add explicit signposting.

6. **Engagement register** — match the profiled we/passive balance. If the profile shows the author addresses reader anticipations ("One might worry that..."), include that where it fits the outline.

7. **Opening and closing patterns** — open and close paragraphs in the profiled style. If the profile shows paragraphs close with forward-looking implications, do that. If they close with summary, do that.

**Section-type calibration** (if `--section` provided):
- `intro` — broader framing, motivation, contribution statement; typically more direct and less hedged
- `methods` — precise identification language, assumption statements, robustness preview; often the most passive-voice-heavy section
- `results` — evidence-first or interpretation-first per profile; coefficient presentation; mechanism discussion
- `discussion` — implications, limitations, open questions; profile's limitation-scoping pattern matters most here

**Journal calibration** (if `--journal` provided):
- Apply any journal-specific register adjustments from the domain profile (e.g., JAERE vs. AJAE may differ in how explicit identification claims need to be).

### Step 4: Present Draft and Confirm

1. Present the full draft to the user. Do **not** write to any file yet.
2. Add a brief note after the draft:

   > **Voice check:** [2–3 sentences noting which profile dimensions were most and least straightforward to apply, and any places where the outline's content pushed against the profile — so the researcher can calibrate expectations.]

3. Ask: **"Happy with this draft? Say yes to save, give me a path to write it to, or tell me what to revise."**
4. On confirmation with a path: write the draft to the specified file. Append, don't overwrite, if the file already exists and the user hasn't said otherwise.
5. On revision request: revise in place and re-present. Do not write to file until confirmed.

---

## Disclosure

This skill produces AI-generated prose from your outline. Many journals,
funders, and universities now require disclosure of AI assistance in manuscript
preparation, and the policies differ — some require a statement, some restrict
it to specific sections, some ask for nothing.

**Before submitting anything drafted here, check the target venue's policy.**
Check `.claude/domain-profile.md` for the target journal, then that journal's
author instructions. If a policy is unclear, say so rather than assuming none
applies.

Remind the user of this the first time `/voice-write` is used on a given
project. Do not repeat it every invocation.

## Principles

- **Outline-faithful.** Generate the argument the user provided — do not add claims, re-order the logic, or introduce new evidence that wasn't in the outline.
- **Profile-anchored.** Every stylistic choice should be traceable to the voice profile. This is not generic "good academic writing" — it is the researcher's writing.
- **No file writes until confirmed.** The user must approve the draft before it is saved anywhere.
- **Transparent about gaps.** If the outline is too sparse to generate a full section without invention, say so and ask for more detail rather than padding.
- **Drafting is the first pass, not the last.** A generated draft is a starting
  point you revise, not finished prose. `/prose-audit` catches formulaic
  patterns and `/voice-review` checks alignment against the profile — both
  produce suggestions for you to accept or reject. Neither is a substitute for
  reading the draft yourself and rewriting what does not say what you mean.
- **Profile quality gate.** The quality of this output is bounded by the quality of the voice profile. If the profile was built on a thin or unrepresentative corpus, say so in the voice check note.
