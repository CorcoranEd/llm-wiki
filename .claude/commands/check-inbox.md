---
description: Report whether new files are waiting in _inbox/, without filing anything.
---

List the files currently in `_inbox/` (ignore `README.md` and any dotfiles).

- If empty: report "_inbox is empty" in one line and stop.
- If not empty: report the count and filenames, and remind that filing happens in an interactive Ingest session (per CLAUDE.md's Ingest workflow) — discussing non-trivial sources with the user first.

Do not read, convert, move, or file any of the listed files. This command only reports state.
