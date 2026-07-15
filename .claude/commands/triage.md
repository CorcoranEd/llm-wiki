---
description: Run a full wiki-linter health-check pass — scans the vault, auto-fixes purely mechanical issues, flags everything else into wiki/issues.md. Never asks questions; safe for unattended /loop runs.
---

Invoke the `wiki-linter` agent (`.claude/agents/wiki-linter.md`) for a full vault-wide health-check pass: work through every item in its Procedure section, auto-fixing anything its Role Boundaries allow directly, and flag everything else into `wiki/issues.md` — adding new findings under the right section, removing resolved ones, updating the "Last updated" date.

Append a lint entry to `wiki/log.md` per `wiki-linter.md`'s "After the pass" format.

Report a short punch list — what was fixed automatically vs. what was flagged — per `wiki-linter.md`'s Report format.

This command never calls `AskUserQuestion` and never edits page content beyond mechanical frontmatter fixes, so it's safe to run unattended with `/loop` (e.g. `/loop 1h /triage`).
