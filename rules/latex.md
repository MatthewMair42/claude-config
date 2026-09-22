# LaTeX


After any batch of `.tex` edits, run `/compiletex` and resolve all warnings before considering the task done. The goal is a clean compile with zero warnings — not "mostly clean".

Do not use the `[plain]` Beamer frame option unless explicitly requested — it silently removes the title bar.

Never apply a document class, template, or layout for a journal submission without first checking the target journal's actual author instructions (check `.claude/domain-profile.md` for the journal target, then fetch or ask for the journal's formatting guidelines). Do not assume a publisher-level template applies — e.g., JSE is SAGE-published but uses standard article format, not the `sagej.cls` two-column layout. Confirm the correct class with the user before restyling.

