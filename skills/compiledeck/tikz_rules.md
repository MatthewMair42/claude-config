# TikZ Anti-Collision Rules

These rules prevent TikZ rendering errors — text on top of arrows, arrows crossing arrows, labels spilling over boxes. The compiler catches none of these. You must catch them yourself.

---

## THE WORKFLOW: Bézier First, Everything Else Second

Every time you create or edit TikZ in a deck, follow this order. Do not skip steps. Do not audit only the slide you just touched — audit the entire deck.

### Pass 0: Cross-slide consistency

Before checking geometry, check continuity. When the same diagram, cycle, or visual element appears on more than one slide:

1. **Colors must match.** If "Inspect" is Slate on slide 31, it must be Slate on slide 32. Grep for repeated node names or labels across frames.
2. **Layout must match.** Same nodes at same positions, same spacing, same font sizes.
3. **Deliberate changes must be the ONLY changes.** If slide 32 adds a red rectangle to highlight the bottleneck, that should be the only difference from slide 31. Nothing else moves, recolors, or resizes.

This catches continuity errors that are invisible when looking at one slide in isolation but obvious when flipping between consecutive slides.

```bash
# Find all frames that share the same node names
grep -n "node.*draft\|node.*compile\|node.*inspect" [file].tex
```

For each group of slides sharing elements, verify color and position consistency.

---

### Pass 1: Find and fix all Bézier curves

```bash
grep -n "bend" [file].tex
```

For EACH curved arrow found:

**Step 1.** Identify the two endpoints and the bend angle.

**Step 2.** Calculate max curve depth:
```
max_depth = (chord_length / 2) × tan(bend_angle / 2)
```

**Step 3.** Calculate safe distance:
```
safe_distance = max_depth + 0.5cm
```

**Step 4.** Check every label near the curve. Any label closer than `safe_distance` to the baseline (in the direction the curve bends) MUST be moved.

**Step 5.** Check every other arrow in the same figure. Does the curve cross any of them? If the curve bends downward and there's a vertical arrow in the middle of the diagram, they WILL cross. Fix: re-route the curve to bend the other direction (`bend right` instead of `bend left`, or vice versa).

### Common bend values for quick reference

| Bend angle | tan(angle/2) | Multiplier for half-chord |
|-----------|-------------|--------------------------|
| 20° | 0.176 | × 0.18 |
| 25° | 0.222 | × 0.22 |
| 30° | 0.268 | × 0.27 |
| 35° | 0.315 | × 0.32 |
| 40° | 0.364 | × 0.36 |
| 45° | 0.414 | × 0.41 |

Example: Arrow across 8.4cm with `bend left=35`:
- Half-chord = 4.2
- Depth = 4.2 × 0.315 = **1.32cm**
- Safe distance = 1.32 + 0.5 = **1.82cm**
- Any label must be at y ≤ -1.82 (not -1.2, not -1.5)

### Pass 2: Gap calculations for labels between nodes

For every label positioned between two nodes:

```
Available gap = (center-to-center distance) - (half-width of node A) - (half-width of node B)
Usable space  = Available gap - 0.6cm (0.3cm padding each side)
```

Estimate label width:

| Font size | Width per character |
|-----------|-------------------|
| `\scriptsize` | 0.10cm |
| `\footnotesize` | 0.12cm |
| `\small` | 0.15cm |
| `\normalsize` | 0.18cm |

Bold: +10%. Monospace: +15%.

If estimated label width > usable space: collision guaranteed. Move the label above/below or shorten it.

### Pass 3: Arrow label positioning

Every arrow label must have a positional keyword:

```latex
% GOOD
\draw[->] (A) -- (B) node[midway, above] {label};

% BAD — label sits ON the arrow
\draw[->] (A) -- (B) node[midway] {label};
```

Horizontal arrows: `above` or `below`.
Vertical arrows: `left` or `right`.
Diagonal: whichever side has more space.

### Pass 4: Everything else

- Multi-line nodes have `align=center`?
- No nodes clipped by slide edges (0.5cm margin)?
- If scaled: nodes scaled too, not just coordinates?
- Arrow colors and stealth sizes consistent?
- No two labels overlap?

### Pass 5: Open the PDF and visually confirm

---

## REFERENCE: The Individual Rules

### Rule 1: Gap Calculation (see Pass 2 above)

Worked example — the "via the terminal" problem:
- Two boxes: left at x=0 (5cm wide), right at x=6.5 (5cm wide)
- Edge-to-edge gap: 4.0 - 2.5 = 1.5cm
- Usable: 1.5 - 0.6 = 0.9cm
- Label "via the terminal" = 16 chars × 0.10 = 1.6cm
- 1.6 > 0.9: collision. Fix: move label above both boxes.

### Rule 2: Positional Keywords (see Pass 3 above)

### Rule 3: Minimum Spacing

| Between | Minimum |
|---------|---------|
| Node edge to node edge | 0.8cm |
| Label to any line/arrow | 0.15cm |
| Node edge to slide margin | 0.5cm |
| Stacked labels (vertically) | 0.3cm |

### Rule 4: Multi-line Nodes

`\\` in a node requires `align=center` (or `align=left`). Without it: "Not allowed in LR mode" error. Set `text width` 15% wider than your estimate.

### Rule 5: Scale Shrinks Coordinates But Not Text

`scale=0.8` makes a 2cm gap into 1.6cm, but text stays full size. Always use:
```latex
\begin{tikzpicture}[scale=0.8, every node/.style={scale=0.8}]
```
Or better: don't scale. Design at intended size.

### Rule 6: Staggering Crowded Labels

- Alternate `above`/`below` for consecutive arrow labels
- Use `pos=0.3` and `pos=0.7` instead of `midway` for parallel arrows
- `near start` and `near end` for very crowded diagrams

### Rule 7: Bézier Curves (see Pass 1 above)

The fundamental problem: Claude cannot eyeball where a curve passes. The formula is the only reliable method. DO NOT trust intuition on curved arrows.

### Rule 8: Arrows Crossing Arrows

A curved return arrow bending downward WILL cross any vertical arrow in the middle of the diagram. Fix: route the return arrow above (`bend right` instead of `bend left` when going right-to-left).

### Rule 9: Full-Deck Re-Audit

After ANY TikZ fix, re-audit EVERY TikZ figure in the deck. The same error pattern repeats across slides because the same code structure was reused. `grep -n "bend"` finds all curves. Check each one. This takes 2 minutes. Skipping it costs the user's trust.

---

## Common Collision Patterns

1. **Label between wide boxes**: Text exceeds gap. Fix: move above/below.
2. **Timeline with era labels**: Adjacent labels overlap. Fix: stagger above/below.
3. **Flow diagram with many arrows**: Labels pile up. Fix: label only non-obvious transitions.
4. **Node near slide edge**: Text extends past boundary. Fix: explicit `text width`, 0.5cm margin.
5. **Return arrow crossing vertical branch**: Curve passes through another arrow. Fix: bend the other direction.
6. **Label in curved arrow's path**: Label placed "below" the baseline but inside the curve's sweep. Fix: use the depth formula, add 0.5cm safety margin.
