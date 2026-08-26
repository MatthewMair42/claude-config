---
name: prose-audit
description: >
  Audit academic prose for formulaic patterns — the tics that make writing feel
  templated or generated. Checks 24 patterns across structure, word choice,
  rhetoric, and formatting. Read-only; produces a numbered suggestion report,
  never edits the source. Use on any draft that reads mechanically.
version: 1.1.0
argument-hint: "[file path to .tex, .md, .txt, or .qmd file]"
allowed-tools: ["Read", "Write", "Grep", "Glob"]
source: clo-author
author: Hugo Sant'Anna
adapted_by: Matthew Mair
adaptation: substantial
upstream_url: https://github.com/hugosantanna/clo-author/blob/24abd60ba532ee8db11b6b13e46595587258c1ca/.claude/skills/humanizer/SKILL.md
last_synced: 2026-08-25
upstream_status: removed upstream 2026-03-05; folded into /write
local_changes: >
  Renamed from upstream `humanizer` to `prose-audit`. The upstream name is the
  industry term for AI-detection evasion tooling, which misdescribes what this
  does: it flags formulaic prose faults (formulaic transitions, overused
  intensifiers, hollow hedging, over-signposting) and proposes fixes. Read-only.
  Pattern set expanded to 24 across 4 categories, with academic-context
  calibration so normal formal constructions are not flagged.
---

# Prose Audit

Audit academic prose for formulaic patterns and propose fixes. This provides standalone access to the prose pass built into the upstream Writer agent.

**Input:** `$ARGUMENTS` — path to the file to audit.

> **Adaptation note:** No named `writer` agent exists globally — run the prose pass
> inline using the workflow below. If invoked within the clo-author pipeline, the
> Writer agent handles this automatically; this skill provides direct access without it.

---

## Workflow

### Step 1: Read the File

Read the target file from `$ARGUMENTS`. Support `.tex`, `.md`, `.txt`, and `.qmd` files. If the file extension is not one of these four, warn the user and proceed if the file appears to be plain text.

### Step 2: Scan for AI Patterns

Check all 24 patterns across 4 categories:

#### Category 1: Structural Tics (6 patterns)
1. **Triplet lists** — "X, Y, and Z" appearing 3+ times in a section
2. **Formulaic transitions** — "Moreover", "Furthermore", "Additionally" as sentence starters
3. **Echo conclusions** — final paragraph restates every point
4. **Uniform paragraph length** — all paragraphs suspiciously similar in length
5. **Topic sentence + support** — every paragraph follows identical structure
6. **Numbered/bulleted reasoning** — "First... Second... Third..." in prose

#### Category 2: Lexical Tells (6 patterns)
7. **"Delve"** — almost never used by humans in academic writing
8. **"Landscape"** — as metaphor ("the policy landscape")
9. **"Crucial/pivotal/vital"** — overused intensifiers
10. **"Multifaceted"** — AI favorite
11. **"Underscores"** — as verb ("this underscores the importance")
12. **"Navigate"** — metaphorical ("navigate the challenges")

#### Category 3: Rhetorical Patterns (6 patterns)
13. **Excessive hedging** — "it is worth noting", "interestingly", "arguably"
14. **Performative enthusiasm** — "fascinating", "remarkable", "exciting"
15. **False balance** — "while X, it is also true that Y" for every claim
16. **Hollow acknowledgment** — "this raises important questions" without answering them
17. **Premature synthesis** — summarizing before enough evidence is presented
18. **Universal agreement** — "scholars agree", "it is widely recognized"

#### Category 4: Formatting Tells (6 patterns)
19. **Over-signposting** — "In this section, we will discuss..."
20. **Excessive parallelism** — every sentence in a list has identical structure
21. **Definitional opening** — starting sections with dictionary-style definitions
22. **Disclaimer stacking** — multiple caveats before making a point
23. **Summary before content** — "This section covers X, Y, and Z" at the start
24. **Colon-list pattern** — "There are three key factors: (1)... (2)... (3)..."

### Step 3: Draft Suggestions

For each detected pattern:
1. Identify the specific instance (quote the exact text, note the line number)
2. Draft a rewritten version that sounds more natural/human
3. Preserve the academic content and meaning exactly

#### Academic Adaptation Rules
- **Preserve formal structure** where it's genuinely needed (equations, theorems, proofs)
- **Keep technical terms** — don't simplify domain vocabulary
- **Maintain citation density** — don't remove scholarly references
- **Vary sentence structure** — mix short and long, simple and complex
- **Allow imperfection** — real writing has slight asymmetries and personality

### Step 4: Write Suggestions File

Determine the output directory:
1. If a `correspondence/prose-audit/` directory exists in the project root, write there (creating it first if needed).
2. If a `correspondence/` directory exists but `correspondence/prose-audit/` does not, create `correspondence/prose-audit/` and write there.
3. Otherwise, write in the same directory as the source file.

Write all suggestions to a new file named `[original-filename].suggestions.YYYY-MM-DD.md` (using today's date) in the chosen output directory. **Do not modify the original file.**

Format each suggestion as a numbered, self-contained block:

```markdown
# Prose Audit: [filename]
**Generated:** YYYY-MM-DD
**Patterns found:** N / 24
**Suggestions:** N

---

### Suggestion 1 of N

**Pattern:** [Category] — [Pattern name]
**Location:** Line [N][, Section name if applicable]

**Original:**
```
[exact quoted text from the file]
```

**Suggested:**
```
[rewritten version]
```

**Rationale:** [one sentence explaining the change]

---

### Suggestion 2 of N
...
```

Category values must match the Step 2 headers exactly: `Structural Tics`, `Lexical Tells`, `Rhetorical Patterns`, `Formatting Tells`.

### Step 5: Report to User

Tell the user:
- Path to the suggestions file
- Total patterns found and suggestions written
- That the original file was **not modified**
- That they can apply suggestions manually, or ask you to apply specific ones by number

---

## Scope

This skill audits **writing quality**. The 24 patterns below are prose faults
in their own right — formulaic transitions, overused intensifiers, hollow
hedging, over-signposting — and they are worth fixing whoever wrote the text.
Models overuse them, which is why the list skews the way it does, but a human
writer who leans on "moreover" and "this underscores the importance" gets the
same findings.

It is **not** a tool for making authored-by-AI text pass as human. It changes
how prose reads, not what it is. If a venue requires disclosure of AI
assistance, running this does not alter that obligation — see the disclosure
note in `/voice-write`.

## Principles

- **Read-only.** Never modify the source file. All output goes to the `.suggestions.md` file only.
- **Preserve meaning.** Suggested rewrites must be content-identical — only the expression changes.
- **Don't over-correct.** Some formal academic patterns are normal, not AI tells.
- **Context-aware.** "Moreover" in a proof is fine. "Moreover" as every paragraph opener is not.
- **User approval required.** Each suggestion is a proposal, not an edit. The user applies them selectively.
- **Light touch for good writing.** If only 2-3 patterns found, the text is probably fine. Focus effort on heavily AI-patterned text.
