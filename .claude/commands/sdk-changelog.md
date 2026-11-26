---
description: Collect the Enterprise SDK changelog for a revision and open a draft PR
argument-hint: <revision, e.g. r712> [--from r710]
allowed-tools: Bash(python3 tools/sdk_changelog/collect.py:*), Bash(gh auth status:*)
---

Collect the Enterprise SDK changelog draft for `$ARGUMENTS` and open a draft PR into `2.11`.
Setup and details: `tools/sdk_changelog/README.md`.

1. Check prerequisites; if one fails, stop and point the user to the "Настройка" section of the README:
   - `gh auth status` succeeds;
   - `GITLAB_URL` and `GITLAB_TOKEN` are set (check only that they are non-empty, never print them).
2. Run `python3 tools/sdk_changelog/collect.py $ARGUMENTS --pr`.
3. Reply in Russian with the PR link and the components marked TODO in the PR description (they need manual input).
