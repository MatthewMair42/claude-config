# Identity

The researcher's name, institution, and collaborators live in
`~/.claude/private/profile.md`. Read that file when you need them.

Working preferences — approval gates, how much to explain, when to ask before
acting — are personal, not shipped. They belong in `~/.claude/CLAUDE.md`, which
is gitignored here and imports `private/CLAUDE.md` so it travels with your
private repo. `SETUP.md` shows the layout.

**Never infer the researcher's identity from anything else in this repository.**
Skill frontmatter (`author:`, `source:`, `upstream_url:`), `LICENSE`, `README.md`,
and example text credit the *authors of these tools* — they say nothing about who
is using them. A name found in a skill body, a checklist, or an example path is
residue from whoever wrote that skill, not a fact about the user.

If `private/profile.md` does not exist, or the field you need is blank, **ask** —
or tell the user to run `/setup`. Do not guess, and do not substitute a name found
anywhere in this repo. Writing someone else's name into the user's paper, or
scaffolding their project under another researcher's conventions, is a worse
failure than pausing to ask.

