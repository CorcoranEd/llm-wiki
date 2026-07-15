---
description: Sync existing wiki pages to the latest fileClass/template schema — useful right after running update.sh on an older vault. Adds missing frontmatter fields and structure additively; never overwrites existing values or removes content.
---

Invoke the `wiki-curator` agent's "Sync pages to latest templates" capability (`.claude/agents/wiki-curator.md`):

1. Backfill `fileClass:` on any folder's main page missing it, deterministically from its folder path.
2. Diff every now-typed page's frontmatter and structure against its current fileClass/template definition, and add anything missing (frontmatter keys with safe defaults, `## Tasks`/`## Outcomes` sections).

All fixes here are additive and auto-applied without confirmation — never overwrites an existing value or removes existing content.

Report a punch list of pages updated and exactly what was added to each.

This is the natural thing to run right after `update.sh` brings `_config/fileclasses/` and `_config/templates/` up to date — it catches your existing pages up to match.
