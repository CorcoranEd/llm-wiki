---
description: Run only wiki-curator's auto-fix pass — fixes mechanically-safe, high-confidence issues and leaves everything else queued. Never asks questions; safe for unattended /loop runs.
---

Invoke the `wiki-curator` agent in auto-fix-only mode (`.claude/agents/wiki-curator.md`'s "Auto-fix-only mode" section): read `wiki/issues.md`, apply only the low-risk/high-confidence fixes that are mechanically verifiable, git-reversible, and meaning-preserving, and leave everything else untouched in `issues.md` for the next interactive session. Never call `AskUserQuestion`.

Report a one-line summary: `"auto-fixed N, M queued for review."`

Designed to be run with `/loop` for periodic unattended passes (e.g. `/loop 1h /auto-fix`).
