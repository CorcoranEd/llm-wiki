# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

This is an LLM-maintained wiki: an Obsidian vault organized with the [PARA method](wiki/3-Resources/Meta/The%20PARA%20Method%20The%20Simple%20System%20for%20Organizing%20Your%20Digital%20Life%20in%20Seconds.md) (Projects / Areas / Resources / Archives), where Claude does the filing, cross-referencing, and synthesis, and the user curates sources and directs the work. The pattern is described in `wiki/3-Resources/Meta/llm-wiki.md`, `llm-wiki-v2.md`, and `llm-wiki-v3.md` — read these if asked to evolve this schema.

**Scope**: <fill in — whose life/domain does this vault cover, and what's out of scope?>

## Agents

Four subagents handle wiki operations. Invoke them via the Agent tool or by naming them in a request.

| Agent | Responsibility | When to use |
| --- | --- | --- |
| `wiki-ingestor` | Processes `_inbox/` into the wiki — converts files, decides PARA placement, creates/updates pages, files originals to `_raw/` | User drops new material in `_inbox/` and asks to ingest, file, or clip it |
| `wiki-librarian` | Answers questions from existing wiki content — read-only retrieval and synthesis | User asks a question about what is in the wiki |
| `wiki-linter` | Health-check pass — orphan pages, broken wikilinks, stale frontmatter, contradictions, retention review; updates `wiki/issues.md` | User asks for a lint or maintenance run |
| `wiki-curator` | Interactive resolution of open issues — links orphans, archives superseded pages, resolves contradictions, audits content coherence, merges duplicates | User asks to "work through issues" or "curate the wiki" |

## Structure

- `_inbox/` — drop zone. The user puts anything here (articles, PDFs, photos, scans, voice memos, web clips, raw notes) to be ingested. Should be empty between ingest sessions.
- `_raw/` — immutable archive of source material. Claude never edits files here after filing. Every wiki page that draws on a source links back to its file here (`[[_raw/filename]]`).
- `_raw/assets/` — images extracted from clippings or other sources.
- `wiki/1-Projects/` — active, short-term efforts with a defined goal and end state. Every project gets its own folder named after the project, containing a main page of the same name plus any supporting pages (drafts, correspondence, working notes).
- `wiki/2-Areas/` — ongoing responsibilities with no end date. Suggested starter Areas (rename/prune to fit the scope above — illustrative, not required): Health, Finance, Home, Career, Relationships, Learning, **People**. For work/research-scoped vaults, swap the scope-specific ones for domain-appropriate equivalents (e.g. Clients, Operations, Skill Areas) — see the example scopes in `README.md`. `People` is worth keeping in every scope: a place for pages about individuals referenced from other docs (family, colleagues, clients, interview subjects). It's filed as an Area, not a Resource, because maintaining a relationship is an ongoing responsibility with no end-state — `wiki/2-Areas/People/People.md` as its index page, each person a sub-topic folder below it (`wiki/2-Areas/People/Jane-Smith/Jane-Smith.md`).
- `wiki/3-Resources/` — reference material on topics of interest.
- `wiki/3-Resources/Meta/` — docs describing how this wiki itself works (the llm-wiki pattern docs, the PARA method article). Reference these when changing this schema.
- `wiki/4-Archives/` — completed projects, inactive areas, retired resources. Mirrors the structure of 1/2/3.
- `wiki/index.md` — catalog of every wiki page: link, one-line summary, tags, last updated. The first place to look when answering a query.
- `wiki/log.md` — append-only log of ingest/query/lint operations, newest entries on top. Each entry starts with `## [YYYY-MM-DD] <ingest|query|lint> | <title>` so it stays greppable.
- `wiki/issues.md` — persistent issues list maintained by the linter. Open items requiring human judgment: orphan pages, contradictions, missing pages, pages ready to archive, unreviewed content. The curator uses this as its work queue.

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

YAML frontmatter on every wiki page (Properties + Bases are enabled, so this drives views/filters):

```yaml
---
tags: [tag1, tag2]
created: 2026-06-12
updated: 2026-06-12
status: active         # for 1-Projects: active | someday | done
sources: ["[[_raw/some-file.pdf]]"]
confidence: high       # high | medium | low | unreviewed (default: unreviewed)
reviewed: 2026-06-12   # date of last deliberate review; linter flags if >6 months stale
superseded_by: ""      # wikilink to newer page if this one is replaced
supersedes: []         # wikilinks to pages this one replaces
---
```

**Field semantics:**

- `confidence`: how well-supported is the content — `high` (multiple corroborating sources), `medium` (single source or partially verified), `low` (speculative or second-hand), `unreviewed` (not yet assessed). Set by the ingestor on creation. Linter flags `unreviewed` pages older than 30 days.
- `reviewed`: date the page was last deliberately checked for accuracy. Linter flags pages where `reviewed` is more than 6 months ago.
- `superseded_by` / `supersedes`: links two related pages when one replaces another. Superseded pages get archived — once `superseded_by` is set, the old page moves to `wiki/4-Archives/` mirroring its original path. Only frontmatter changes on archive. Wikilinks in `supersedes:` still resolve after archiving since Obsidian links are vault-wide.

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

Use `[[wikilinks]]` for all cross-references between pages. New pages start from `_templates/note.md`.

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

- **apple-mail-mcp** — MCP server for pulling emails directly into an ingest session without manual export. Install: `claude plugin marketplace add patrickfreyer/apple-mail-mcp`. Requires Mail.app automation permission in System Settings.

- **transcriptor-mcp** — MCP server for YouTube, podcast, and video transcription via yt-dlp and local Whisper. Add to `~/.claude/settings.json` when video/podcast content is a regular ingest source. See github.com/samson-art/transcriptor-mcp.

- **Obsidian Web Clipper** — official Obsidian browser extension for quick web capture outside Claude sessions. Set the destination folder to `_inbox/`. Complements Defuddle (Defuddle is used inside Claude sessions; Web Clipper is for browser-side quick capture).

- **Hazel / Shortcuts** — macOS automation for auto-populating `_inbox/`. Hazel can watch `~/Downloads` and route PDFs, audio files, and exports automatically. Shortcuts handles simpler one-off triggers (share-sheet → `_inbox/`).

### Search

Search scales with vault size:

- **Tier 1 — current (under ~100 pages)**: grep + `wiki/index.md`. Fast, zero setup, already in place. Weaknesses: no synonym matching, no concept-level retrieval.

- **Tier 2 — semantic scaffold (install now, activate when needed)**: Smart Connections Obsidian plugin builds local embeddings passively as you write. No API key, no model download — uses a bundled `bge-micro-v2` model. When MCP-accessible semantic search is needed, add the `smart-connections-mcp` bridge to `~/.claude/settings.json`. Install via Obsidian Community Plugins.

- **Tier 3 — full hybrid search (100–200+ pages)**: qmd (`@tobilu/qmd` on npm) runs BM25 + vector + LLM re-ranking entirely on-device and exposes an MCP server Claude Code queries natively via `qmd_deep_search`. Install: `npm install -g @tobilu/qmd`, then `qmd collection add <vault-path> --name wiki && qmd embed`. Requires ~2GB model download on first run; reindex after bulk ingests with `qmd embed`.

### Obsidian skills

`obsidian-skills` (`.claude/skills/`) — use for correct Obsidian-flavored markdown (wikilinks, callouts, properties, canvas) and for clipping web pages cleanly via Defuddle.

## Setup on a new machine

If you move or copy this vault to a new machine, `.venv/` (Python virtualenv, dotfolder) should not travel with it — it's large and platform-specific. `pyproject.toml`, `uv.lock`, and `.python-version` do travel (they're plain files) and fully describe the environment.

After the vault is on a new machine:

1. Install `uv` if not already present: `curl -LsSf https://astral.sh/uv/install.sh | sh`
2. From the vault root, run `uv sync` once to materialize `.venv` locally.
3. Optionally install whisper.cpp for local audio transcription: `brew install whisper.cpp ffmpeg`
4. Optionally install PDF tools for complex documents: `uv add pymupdf4llm marker-pdf`

No other setup should be required for the ingest workflow.
