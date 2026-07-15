---
description: Surface open wiki tasks and questions worth your attention — inbox items, open issues, unreviewed content, and stale pages. Does not file or modify anything.
---

You are doing a quick wiki status pass. Report only — do not ingest, lint, or modify any files.

**1. Inbox**

List files currently in `_inbox/` (ignore `README.md` and dotfiles).
- If empty: "Inbox clear."
- If not empty: list count and filenames.

**2. Open issues**

Read `wiki/issues.md`. For each non-empty section, summarise the count and the most actionable items (up to 3 per section). Skip sections with no items.

**3. Unreviewed content**

Grep frontmatter across `wiki/` for `confidence: unreviewed`. List pages found, ordered by `created` date (oldest first, up to 5). These are pages that have never been assessed for reliability.

**4. Stale reviews**

Grep for `reviewed:` dates older than 6 months from today. List up to 5 oldest. These are pages that may contain outdated information.

**5. Suggested next action**

Based on the above, name the single most valuable thing to do next:
- If inbox is non-empty → "Run wiki-ingestor to process N items."
- If there are ready-to-archive pages → "Run /review to archive superseded pages."
- If there are many unreviewed pages → "Run /review to upgrade confidence ratings."
- If issues.md is long → "Run /review to work through open issues."
- If everything is clear → "Nothing urgent — consider running /triage to check for drift."

Keep the whole report under 20 lines. This command is designed to be run with `/loop` for periodic check-ins.
