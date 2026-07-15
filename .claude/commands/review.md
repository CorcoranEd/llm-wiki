---
description: Work through open wiki/issues.md interactively and run proactive curation — archiving, merging, resolving contradictions, upgrading confidence, syncing outdated pages. Asks for confirmation on anything not mechanically safe — not recommended for unattended /loop use, see /auto-fix for that.
---

Invoke the `wiki-curator` agent (`.claude/agents/wiki-curator.md`) for its full "work through issues"/proactive-curation pass:

1. Auto-fix pass first — mechanically-safe fixes only, no confirmation needed.
2. Work through everything remaining in `wiki/issues.md`, section by section.
3. Proactive curation: task priority assessment, completed-task resolution, confidence upgrades, duplicate merges, cross-link enrichment, sources audit, PARA reclassification, cluster synthesis offers, relationship graph completion, content coherence audit.

This calls `AskUserQuestion` for anything requiring judgment, so it is **not** safe for unattended `/loop` runs. For an unattended-safe subset that never asks questions, use `/auto-fix` instead.

Report a summary per `wiki-curator.md`'s "After a session" format: how many issues auto-fixed, resolved interactively, deferred, and any human-edited pages reviewed.

Note: this is the full vault-wide pass. To review one specific page you just edited yourself, just ask directly (e.g. "review my edits to X") rather than running this command — that's a separate, narrower capability described in `wiki-curator.md`'s "Human-edited page review" section.
