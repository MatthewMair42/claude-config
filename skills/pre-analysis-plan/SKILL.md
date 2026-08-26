---
name: pre-analysis-plan
description: Draft pre-analysis plans by dispatching the Strategist agent in PAP mode. Covers AEA RCT Registry, OSF, and EGAP standards. Specifies outcomes, subgroups, multiple testing, power calculations, and exclusion rules.
version: 1.0.0
argument-hint: "[research-spec file OR topic OR 'interactive' for guided interview]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
source: clo-author
author: Hugo Sant'Anna
adapted_by: Matthew Mair
adaptation: substantial
upstream_url: https://github.com/hugosantanna/clo-author/blob/24abd60ba532ee8db11b6b13e46595587258c1ca/.claude/skills/pre-analysis-plan/SKILL.md
last_synced: 2026-08-25
upstream_status: removed upstream 2026-03-05; folded into /strategize
---

# Pre-Analysis Plan

Draft a pre-analysis plan covering AEA RCT Registry, OSF, and EGAP standards.

**Input:** `$ARGUMENTS` — path to research spec file, a topic, or `interactive` for guided questions.

> **Adaptation notes:**
> - No named `strategist` agent exists globally — run that role inline using the 10-section
>   structure below. The `econometrician` agent IS installed globally at `~/.claude/agents/econometrician.md`
>   and can be dispatched for Step 4 (optional econometrician review).
> - Read `~/.claude/private/domain-profile.md` for field conventions, then `.claude/domain-profile.md`
>   in the project root if it exists (project-level overrides global).
> - Output goes to `correspondence/` in the project root.

---

## Workflow

### Step 1: Load Context

- If `$ARGUMENTS` is a file: read it (research spec)
- If `$ARGUMENTS` is `interactive`: conduct guided interview (see below)
- Otherwise: treat as topic and draft with ASSUMED placeholders marked clearly
- Read `~/.claude/private/domain-profile.md` for field conventions; also read `.claude/domain-profile.md` if present in the project root

### Interactive Questions (if needed)

1. What is the research question?
2. What is the study design? (RCT / natural experiment / quasi-experimental)
3. What are the primary outcome variables?
4. What is the identification strategy?
5. What subgroup analyses are pre-specified?
6. What multiple testing concerns exist?

### Step 2: Draft PAP (Strategist Role)

Produce a full pre-analysis plan with all standard sections:

```
1. Study overview (question, design, treatment, control)
2. Outcomes (primary, secondary, mechanism — with measurement details)
3. Estimating equations (with notation)
4. Subgroup analyses (pre-specified, with justification)
5. Multiple testing correction (Bonferroni / BH / Romano-Wolf)
6. Power calculations (MDE, baseline stats, sample size)
7. Sample and exclusion rules (inclusion, attrition, outliers)
8. Data and analysis (sources, software, randomization)
9. Timeline
10. Deviations log (empty template)
```

Save to `correspondence/pre_analysis_plan_[topic]_[date].md`

### Step 3: Platform-Specific Adaptation

- **AEA RCT Registry:** Most structured. All fields required. Register before intervention.
- **OSF:** More flexible. Good for observational studies and natural experiments.
- **EGAP:** Development economics focused. Additional governance questions.

For **observational studies**: adapt template — identification strategy replaces
randomization, comparison group replaces control, add identification assumption discussion.

### Step 4: Econometrician Review (Optional)

If the PAP includes a complex identification strategy, review the plan with focus on:
- Identification assumptions
- Estimator choice
- Power calculation assumptions

Flag any specifications that might be problematic before registration.

### Step 5: Present to User

**CRITICAL:** Flag every ASSUMED item clearly. The researcher must review and approve
before registration. A registered PAP with errors is worse than no PAP.

---

## Principles

- **Pre-specification is the point.** Everything decided before seeing outcomes.
- **Be honest about what's exploratory.** Label subgroups and secondary outcomes clearly.
- **Power calculations require assumptions.** State every assumption. Show sensitivity.
- **This is a commitment device.** Make sure the researcher understands what they're committing to.
- **Strategist creates, Econometrician critiques** (optional but recommended for complex designs).
