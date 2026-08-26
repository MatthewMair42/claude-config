---
name: validate-bib
description: Validate bibliography entries against citations in .tex and .qmd source files. Find missing entries, unused references, and key typos. Use before any submission, talk, or paper draft.
version: 1.0.0
allowed-tools: ["Read", "Grep", "Glob"]
source: clo-author
author: Pedro H. C. Sant'Anna
adapted_by: Matthew Mair
adaptation: substantial
upstream_url: https://github.com/hugosantanna/clo-author/blob/24abd60ba532ee8db11b6b13e46595587258c1ca/.claude/skills/validate-bib/SKILL.md
last_synced: 2026-08-25
upstream_status: removed upstream 2026-03-05; folded into /tools
---

# Validate Bibliography

Cross-reference all citations in source files against bibliography entries.

> **Adaptation note:** Default scan paths and bib location are project-specific defaults —
> override as needed. Common alternatives:
> - Source files: `Paper/sections/*.tex`, `*.qmd`, `Talks/*.tex`
> - Bibliography: `refs.bib`, `Paper/references.bib`, `../Bibliography_base.bib`

**Usage:** `/validate-bib [--fast]`
- `--fast` — skip step 4 (entry quality checks). Use when only missing/unused/typo
  detection is needed (e.g., called from `/presubmit`).

## Steps

1. **Read the bibliography file** and extract all citation keys

2. **Scan all source files for citation keys:**
   - `.tex` files: look for `\cite{`, `\citet{`, `\citep{`, `\citeauthor{`, `\citeyear{`
   - `.qmd` files: look for `@key`, `[@key]`, `[@key1; @key2]`
   - Extract all unique citation keys used

3. **Cross-reference:**
   - **Missing entries:** Citations used in source files but NOT in bibliography
   - **Unused entries:** Entries in bibliography not cited anywhere
   - **Potential typos:** Similar-but-not-matching keys

4. **Check entry quality** for each bib entry *(skip if `--fast` was passed)*:
   - Required fields present (author, title, year, journal/booktitle)
   - Author field properly formatted
   - Year is reasonable
   - No malformed characters or encoding issues

5. **Report findings:**
   - List of missing bibliography entries (CRITICAL)
   - List of unused entries (informational)
   - List of potential typos in citation keys
   - List of quality issues (omitted if `--fast`)

## Default paths (auto-detected):

```
# Source files to scan:
Glob **/*.tex and **/*.qmd in the project root
Exclude: .claude/, output/, correspondence/

# Bibliography:
Glob *.bib in the project root and tex/
Use the single result; ask the user if multiple are found
```
