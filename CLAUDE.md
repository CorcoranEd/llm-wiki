# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

This is an LLM-maintained wiki: an Obsidian vault organized with the [PARA method](wiki/3-Resources/Meta/The%20PARA%20Method%20The%20Simple%20System%20for%20Organizing%20Your%20Digital%20Life%20in%20Seconds.md) (Projects / Areas / Resources / Archives), where Claude does the filing, cross-referencing, and synthesis, and the user curates sources and directs the work. The pattern is described in `wiki/3-Resources/Meta/llm-wiki.md`, `llm-wiki-v2.md`, and `llm-wiki-v3.md` — read these if asked to evolve this schema.

**Scope**: <fill in — whose life/domain does this vault cover, and what's out of scope?>

## Agents

Four subagents handle wiki operations. Invoke them via the Agent tool or by naming them in a request.

| Agent            | Responsibility                                                                                                                                                                                                                                                      | When to use                                                                                                                        |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `wiki-ingestor`  | Processes `_inbox/` into the wiki — converts files, decides PARA placement, creates/updates pages, files originals to `_raw/`                                                                                                                                       | User drops new material in `_inbox/` and asks to ingest, file, or clip it                                                          |
| `wiki-librarian` | Answers questions from existing wiki content — read-only retrieval and synthesis                                                                                                                                                                                    | User asks a question about what is in the wiki                                                                                     |
| `wiki-linter`    | Health-check pass — orphan pages, broken wikilinks, skipped heading levels, duplicate content, stale frontmatter, contradictions, outdated template/schema, retention review; detection-only, updates `wiki/issues.md`                                              | User asks for a lint or maintenance run, or via `/triage`                                                                          |
| `wiki-curator`   | Interactive resolution of open issues — links orphans, archives superseded pages, resolves contradictions, audits content coherence, merges duplicates, syncs pages to the latest fileClass/template schema; auto-fixes low-risk issues, reviews human-edited pages | User asks to "work through issues", "curate the wiki", or "review my edits to X", or via `/review`, `/auto-fix`, `/sync-templates` |

## Structure

- `_inbox/` — drop zone. The user puts anything here (articles, PDFs, photos, scans, voice memos, web clips, raw notes) to be ingested. Should be empty between ingest sessions. If the user instead shares a file directly in the chat (an attachment, pasted content, or a file path) and asks to ingest it, first copy the exact original file into `_inbox/` unmodified (preserve the original filename; disambiguate on collision, e.g. append `-2`), then proceed with the normal ingest procedure via `wiki-ingestor`. Never ingest directly from the chat attachment's original location — always stage it through `_inbox/` first so `_raw/` provenance stays consistent.
- `_raw/` — immutable archive of source material. Claude never edits files here after filing. Every wiki page that draws on a source links back to its file here (`[[_raw/filename]]`).
- `_raw/assets/` — images extracted from clippings or other sources.
- `_config/` — admin/schema folder, not vault content: `_config/templates/` (Templater templates, see Conventions) and `_config/fileclasses/` (Metadata Menu fileClass definitions, see Conventions).
- `wiki/1-Projects/` — active, short-term efforts with a defined goal and end state. Every project gets its own folder named after the project, containing a main page of the same name plus any supporting pages (drafts, correspondence, working notes).
- `wiki/2-Areas/` — ongoing responsibilities with no end date. Suggested starter Areas (rename/prune to fit the scope above — illustrative, not required): Health, Finance, Home, Career, Relationships, Learning, **People**. For work/research-scoped vaults, swap the scope-specific ones for domain-appropriate equivalents (e.g. Clients, Operations, Skill Areas) — see the example scopes in `README.md`. `People` is worth keeping in every scope: a place for pages about individuals referenced from other docs (family, colleagues, clients, interview subjects). It's filed as an Area, not a Resource, because maintaining a relationship is an ongoing responsibility with no end-state — `wiki/2-Areas/People/People.md` as its index page, each person a sub-topic folder below it (`wiki/2-Areas/People/Jane-Smith/Jane-Smith.md`).
- `wiki/3-Resources/` — reference material on topics of interest.
- `wiki/3-Resources/Meta/` — docs describing how this wiki itself works (the llm-wiki pattern docs, the PARA method article). Reference these when changing this schema.
- `wiki/4-Archives/` — completed projects, inactive areas, retired resources. Mirrors the structure of 1/2/3.
- `wiki/index.md` — catalog of every wiki page: link, one-line summary, tags, last updated. Opens with a `## Status Board` of live Dataview queries (up-next tasks, active projects, backlog, unreviewed content), followed by the hand-maintained catalog. The first place to look when answering a query.
- `wiki/log.md` — append-only log of ingest/query/lint operations, newest entries on top. Each entry starts with `## [YYYY-MM-DD] <ingest|query|lint> | <title>` so it stays greppable.
- `wiki/issues.md` — persistent issues list maintained by the linter. Open items requiring human judgment: orphan pages, broken wikilinks, contradictions, missing pages, pages ready to archive, unreviewed content, skipped heading levels, duplicate content, outdated template/schema, out-of-enum status values. The curator uses this as its work queue — auto-fixing low-risk/high-confidence entries itself, and surfacing the rest for interactive resolution.

### Folder rules

- **No flat pages, ever**: every topic in `1-Projects/`, `2-Areas/`, or `3-Resources/` gets its own folder from the moment it's created — never a bare `.md` file directly inside the PARA folder.
- **Required structure**: every topic folder (and sub-topic folder) contains a main page with the exact same name as the folder, even with zero supporting pages yet (`wiki/2-Areas/Health/Health.md`, not `wiki/2-Areas/Health.md`). Every topic folder is linked from `wiki/index.md` under its parent PARA section.
- **Nesting limit — up to two layers of subfolders**: a topic folder like `wiki/2-Areas/Health/` may contain pages directly, or one further layer of sub-topic folders (e.g. `wiki/2-Areas/Health/Workouts/Workouts.md`, `wiki/2-Areas/Health/Workouts/Workout-1.md`), each following the same main-page-matches-folder-name rule. A sub-topic folder may not itself contain another folder. If a sub-topic needs deeper nesting still, split it into sibling sub-topic folders instead, related via `[[wikilinks]]`.
- **Naming**: Title Case, folder name matches main page name exactly, no abbreviations.

### Deciding Project vs Area vs Resource

- **Project**: has a defined end-state/completion criteria. Test: "does this end?" → yes → Project. When something feels like an Area but has a clear finish line, make it a Project instead.
- **Area**: ongoing responsibility maintained indefinitely, no finish line. Areas can exist without any active Project under them — that is fine. An Area without current Projects is still a standing responsibility, not a candidate for Archives.
- **Resource**: reference material on a topic of interest — informational, not an active duty. Test: if you're tracking status/progress/next-actions on it, it's actually an Area or Project, not a Resource.
- **Archives**: when a Project completes, an Area goes inactive, or a Resource is retired, move its folder as-is into `wiki/4-Archives/`, mirroring the exact original structure — only `status`/`updated` frontmatter changes. Never restructure on archive.

### Worked example: client work, contacts, and reusable skills

- A bounded client engagement → `1-Projects/<Project>/` while active (has a real end-state); moves wholesale to `4-Archives/1-Projects/<Project>/` on completion, same structure, only frontmatter changes.
- The client relationship/account itself (outlives any one project) → `2-Areas/Clients/<Client>/<Client>.md`; only archived once the relationship itself ends, not when one project for them finishes. Its main page can roster every project done for that client, active and archived.
- People (individual contacts) → `2-Areas/People/<Name>/`, separate from the client's business entity; generally stay live even after a project or client relationship archives, since a person typically outlasts both.
- Reusable skills/templates/artifacts produced or used across projects → `3-Resources/<Topic>/`; reference material, never auto-archived just because the project that produced it archives.
- Cross-linking: Project pages link to their Client's Area page, the People involved, and any Resource/skill pages used; the Client's Area page becomes that client's project roster; `wiki/index.md` remains the master catalog across all of it.

## Conventions

Frontmatter is typed via Metadata Menu **fileClasses**, defined in `_config/fileclasses/` (`Project`, `Area`, `Resource`, `Person`), each extending a shared `Base` fileClass rather than one flat schema applying to every page. Non-typed pages (`wiki/index.md`, `wiki/log.md`, `README.md`, `3-Resources/Meta/*`, correspondence sub-pages) fall back to Metadata Menu's global preset fields, which mirror `Base`'s fields.

YAML frontmatter on every typed wiki page (Properties + Bases are enabled, so this drives views/filters):

```yaml
---
fileClass: Project # Project | Area | Resource | Person — matches _config/fileclasses/
tags: [tag1, tag2]
created: 2026-06-12
updated: 2026-06-12
status: active # for Project: active | on-hold | someday | done; Area: active | inactive; Resource: active | retired; Person: no status field
priority: medium # high | medium | low — page-level importance/urgency, see below
sources: ["[[_raw/some-file.pdf]]"]
confidence: high # high | medium | low | unreviewed (default: unreviewed)
reviewed: 2026-06-12 # date of last deliberate review; linter flags if >6 months stale
superseded_by: "" # wikilink to newer page if this one is replaced
supersedes: [] # wikilinks to pages this one replaces
---
```

**Field semantics:**

- `confidence`: how well-supported is the content — `high` (multiple corroborating sources), `medium` (single source or partially verified), `low` (speculative or second-hand), `unreviewed` (not yet assessed). Set by the ingestor on creation. Linter flags `unreviewed` pages older than 30 days.
- `reviewed`: date the page was last deliberately checked for accuracy. Linter flags pages where `reviewed` is more than 6 months ago.
- `status` semantics for Project: `active` = currently in motion; `on-hold` = intent exists but blocked by an external dependency or condition (not the same as someday — the project will resume when the blocker clears); `someday` = low-commitment, may never happen; `done` = complete, ready to archive. Area: `active` = standing responsibility currently maintained; `inactive` = no longer maintained (candidate for archiving). Resource: `active` = current reference material; `retired` = superseded or no longer relevant. Person: no `status` field — a person doesn't have a completion/activity state.
- `priority`: a pure importance/urgency rating, independent of `status`'s lifecycle meaning — a `someday` Project can still be `high` priority (important whenever it resumes), and an `active` one can be `low` priority (in motion but not urgent). Deliberately avoids time-window language like "later," since that would duplicate `status: someday` for Projects. Separate from the `## Tasks` section's per-item priority emoji (🔺⏫🔼🔽, see below), which triages individual checklist items rather than the page as a whole.
- `superseded_by` / `supersedes`: links two related pages when one replaces another. Superseded pages get archived — once `superseded_by` is set, the old page moves to `wiki/4-Archives/` mirroring its original path. Only frontmatter changes on archive. Wikilinks in `supersedes:` still resolve after archiving since Obsidian links are vault-wide.

**Tasks and Outcomes:**

Page bodies use a `## Tasks` / `## Outcomes` pattern instead of freeform to-dos: `## Tasks` holds checkbox items (`- [ ] Task description`), optionally tagged with a priority emoji (🔺 highest/blocking, ⏫ high, 🔼 medium, no emoji for routine, 🔽 low) assigned by the ingestor or curator based on impact. When a task is checked off, `wiki-curator` confirms completion with the user via `AskUserQuestion`, removes it from `## Tasks`, and appends a one-line result to `## Outcomes` (`- **Task name:** outcome or answer`).

**Typed relationships:**

When a page has significant relationships to other pages beyond simple wikilinks, add a `## Relationships` section near the top of the page body using these relationship types:

```markdown
## Relationships

- uses: [[Tool Name]]
- depends on: [[Dependency]]
- contradicts: [[Conflicting Page]]
- supersedes: [[Old Page]]
- related to: [[Adjacent Topic]]
```

These are prose but machine-readable enough for the linter to detect contradictions and the librarian to surface them in queries.

Use `[[wikilinks]]` for all cross-references between pages. New pages start from the fileClass-matched template under `_config/templates/` (`Project.md`/`Area.md`/`Resource.md`/`Person.md`), auto-inserted by Templater based on the folder a note is created in; `_config/templates/note.md` remains the fallback for non-PARA pages.

## Version control

This repository is intended to be downloaded and set up locally, so each user should use git on their own copy as a local safety net.

- Keep the repo initialized with a local git repository after cloning.
- Use git to commit meaningful checkpoints, especially when the vault structure or content changes.
- Commit message style should be clear and consistent, for example:
  - `chore: add .gitignore`
  - `docs: update CLAUDE.md`
  - `fix: clean ignored macOS artifacts`
- Do not rely on a shared remote for local workflow correctness; the main goal is to preserve history and enable recovery on the local machine.
- Pushing to a remote is optional and only for personal backups or collaboration; the workflow is designed to work fully locally.

## Tooling

### Core ingest tools

- **markitdown** — CLI for converting non-markdown sources (Word, Excel, HTML, images with OCR) to markdown during ingest. Run via `uv run markitdown <file>`. Default for most formats. Note: markitdown's audio support calls the OpenAI Whisper API remotely — use whisper.cpp instead for private or offline transcription.

- **whisper.cpp** — local audio transcription on Apple Silicon (no API key, no remote calls). Install: `brew install whisper.cpp ffmpeg`. Use: `whisper-cpp --model base <file.m4a> --output-txt`. Drop the resulting `.txt` in `_inbox/`. Recommended for Voice Memos, interview recordings, podcast clips.

- **pymupdf4llm + marker-pdf** — tiered PDF upgrade beyond markitdown's basic extraction:
  - `pymupdf4llm`: fastest for native PDFs with embedded text (`uv add pymupdf4llm`)
  - `marker_single`: handles scanned PDFs and complex layouts; uses Apple MPS GPU on Apple Silicon (`uv add marker-pdf`)
  - markitdown remains the default; escalate to these only when extraction quality is poor

- **Image handling** — markitdown extracts images from clipped content; those land in `_raw/assets/` and should be referenced in wiki pages with `![[_raw/assets/image.png]]`.

- **Sensitive data** — never file content containing API keys, credentials, tokens, or passwords. Redact before filing, or ask the user whether to omit.

### Optional ingest sources

- **Obsidian Web Clipper** — official Obsidian browser extension for quick web capture outside Claude sessions. Set the destination folder to `_inbox/`. Complements Defuddle (Defuddle is used inside Claude sessions; Web Clipper is for browser-side quick capture).

- **Inbox monitoring** — from Claudian (Obsidian's embedded Claude Code panel), run `/loop /check-inbox` (self-paced) or `/loop 15m /check-inbox` (fixed interval) to get periodic notifications when new files land in `_inbox/`. Tied to that session's lifecycle, so it stops automatically when Obsidian closes. Notifies only — it doesn't file anything.

- **`/status`** — a broader read-only status check than `/check-inbox`: inbox count, a summary of open `wiki/issues.md` sections, pages with `confidence: unreviewed`, pages with stale `reviewed:` dates, and one suggested next action. Capped at 20 lines. Also pairs with `/loop` for periodic check-ins when a fuller picture than inbox-only is wanted.

- **Auto linting** — `/loop 1h /triage` (or self-paced, no interval; equivalently, "run wiki-linter for a full health-check pass"). Safe fully unattended: `wiki-linter` only writes to `wiki/issues.md`, never edits page content beyond mechanical frontmatter fixes, and never calls `AskUserQuestion` — every iteration completes without a human present.

- **Low-risk auto-fix curator** — `/loop 1h /auto-fix` (equivalently, "run wiki-curator in auto-fix-only mode"). In this mode `wiki-curator` applies only its low-risk/high-confidence fixes (see the agent table above) and never calls `AskUserQuestion`; everything else it finds stays queued in `wiki/issues.md` untouched. Each iteration reports a one-line summary (`"auto-fixed N, M queued for review"`) so the queue's growth is visible without interrupting you. This is a distinct mode from the normal interactive "work through issues" / "curate the wiki" request (`/review`), which still asks for confirmation on anything not auto-actionable.

### Search

Search scales with vault size:

- **Tier 1 — current (under ~100 pages)**: grep + `wiki/index.md`. Fast, zero setup, already in place. Weaknesses: no synonym matching, no concept-level retrieval.

- **Tier 2 — semantic scaffold (install when needed)**: Smart Connections Obsidian plugin builds local embeddings passively as you write. No API key, no model download — uses a bundled `bge-micro-v2` model. When MCP-accessible semantic search is needed, add the `smart-connections-mcp` bridge to `~/.claude/settings.json`. Install via Obsidian Community Plugins.

- **Tier 3 — full hybrid search (100–200+ pages)**: qmd (`@tobilu/qmd` on npm) runs BM25 + vector + LLM re-ranking entirely on-device and exposes an MCP server Claude Code queries natively via `qmd_deep_search`. Install: `npm install -g @tobilu/qmd`, then `qmd collection add <vault-path> --name wiki && qmd embed`. Requires ~2GB model download on first run; reindex after bulk ingests with `qmd embed`.

### Obsidian skills

`obsidian-skills` (`.claude/skills/`) — use for correct Obsidian-flavored markdown (wikilinks, callouts, properties, canvas) and for clipping web pages cleanly via Defuddle.

### Obsidian plugins

- **Templater** — inserts the fileClass-matched template automatically when a new note is created under `1-Projects/`, `2-Areas/`, or `3-Resources/` (folder→template mapping in its settings).
- **Metadata Menu** — provides the typed frontmatter fields described above, driven by the fileClass definitions in `_config/fileclasses/`.
- **obsidian-tasks-plugin** — powers querying/dashboards over the `## Tasks` checkbox convention described above, including the Status Board's "Up Next" query.
- **obsidian-excalidraw-plugin** — for freeform diagrams/drawings, configured to save into an `Excalidraw/` folder at vault root.
- **homepage** — opens the vault to `wiki/index.md` on startup.
- **Dataview** — powers `wiki/index.md`'s Status Board queries.
- **Never paste real AI-provider API keys into Excalidraw's settings panel.** Its `data.json` is git-tracked and has a dormant AI-assistant feature with an API key field — populating it would commit the key in plaintext.

### claude.ai connectors

Connectors configured on claude.ai (Settings → Connectors) are automatically available as tools in Claude Code sessions too — no local `.mcp.json` or per-repo OAuth setup needed. They show up as deferred tools named `mcp__claude_ai_<ServerName>__*` (e.g. `mcp__claude_ai_Granola__get_meetings`); use ToolSearch to discover and load one when a task calls for it. Availability depends on the user's claude.ai account, not anything in this repo, so don't assume a fixed list — check when needed.

Categories typically useful for this vault's ingest/research workflows, if connected: meeting-notes tools (e.g. Granola) for Projects/People ingestion, calendar/email/drive tools for correspondence and source documents, chat tools (e.g. Slack) for conversation context, design tools (e.g. Figma) for Resource pages.

Default to read-only use of any connector in the vault workflow — read, don't send/create/write via a connector — even if it exposes write tools, unless the user explicitly asks for a write action. This is a behavioral guideline, not a technical restriction: permission/scope enforcement now lives in the connector's claude.ai configuration, not in this repo.

When the user asks to connect a new service, check whether claude.ai already has (or offers) a connector for it — via ToolSearch for an already-connected `mcp__claude_ai_*` match, or by pointing the user to Settings → Connectors on claude.ai to add one — and direct them to configure it there rather than setting up a local MCP server in this repo.

## Setup on a new machine

If you move or copy this vault to a new machine, `.venv/` (Python virtualenv, dotfolder) should not travel with it — it's large and platform-specific. `pyproject.toml`, `uv.lock`, and `.python-version` do travel (they're plain files) and fully describe the environment.

After the vault is on a new machine:

1. Install `uv` if not already present: `curl -LsSf https://astral.sh/uv/install.sh | sh`
2. From the vault root, run `uv sync` once to materialize `.venv` locally.
3. Optionally install whisper.cpp for local audio transcription: `brew install whisper.cpp ffmpeg`
4. Optionally install PDF tools for complex documents: `uv add pymupdf4llm marker-pdf`

No other setup should be required for the ingest workflow. Three `SessionStart` hooks (wired via `.claude/settings.json`) require `jq` (`brew install jq`), commonly preinstalled — if missing, they fail silently and are simply skipped: the session-start greeting (`.claude/hooks/session-start-greeting.sh`), a nudge to fill in the Scope line above if it's still the template placeholder (`.claude/hooks/scope-setup-check.sh`, becomes a permanent no-op the moment Scope is set), and a nudge to run `/sync-templates` after `update.sh` has rolled the schema forward (`.claude/hooks/update-sync-check.sh`, fires once per `update.sh` run).

All Obsidian plugin code (`main.js`/`manifest.json`/`styles.css`/`data.json` for Claudian, Templater, Metadata Menu, Tasks, Excalidraw, Homepage, and Dataview) is committed to git and travels with the repo, so a fresh clone works with no separate Community Plugins install step — Obsidian just needs the vault trusted and plugins enabled on first open.
