# Git


When removing files from git tracking, default to `git rm --cached` to untrack while preserving local copies. Only use `git rm` without `--cached` when the user explicitly requests on-disk deletion.

