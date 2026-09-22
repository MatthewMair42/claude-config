# Projects Index

Quick-reference map of all active research projects. Update manually after each session, or when `/wrapup` reminds you.

| Project | Path | Status | Open Items | Last Session |
|---|---|---|---|---|
| example-project | `{cloud}/path/to/project` | Active — framing stage | 0 | YYYY-MM-DD |
| another-project | `{local}/path/to/project` | Early stage | 0 | YYYY-MM-DD |

### Paths

Each path begins with a **root token** — `{cloud}`, `{local}`, or whatever names
you choose. The token is defined in `machine.md` under `## Research roots`:

```markdown
## Research roots
- **cloud:** `C:\Users\you\OneDrive - Your University`
- **local:** `C:\Research`
```

This file is synced across your machines; `machine.md` is not. So the same row
resolves correctly everywhere, as long as each machine defines the same names.
Use as many roots as you have separate trees — one is fine.

A path with no token, or one naming a root this machine doesn't define, is
reported as an error rather than guessed at.

## Status Key
- **Active — pre-submission**: paper near ready; priority is polish and robustness
- **Active — R&R**: under revision for a journal
- **Active — framing stage**: empirics run, paper framing in progress
- **Early stage**: data collection / ID strategy not yet locked
- **Waiting**: blocked on external input (advisor, data, journal decision)

## Notes
- Copy this file to `PROJECTS.md` and fill in your projects
- This file is manually maintained — it may lag real project state by a session or two
- Add new projects here when running `/newproject`
- `/wrapup` will remind you to update this file at the end of each session
