# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

This is an LLM-maintained wiki: an Obsidian vault organized with the [PARA method](wiki/3-Resources/Meta/The%20PARA%20Method%20The%20Simple%20System%20for%20Organizing%20Your%20Digital%20Life%20in%20Seconds.md) (Projects / Areas / Resources / Archives), where Claude does the filing, cross-referencing, and synthesis, and the user curates sources and directs the work. The pattern is described in `wiki/3-Resources/Meta/llm-wiki.md`, `llm-wiki-v2.md`, and `llm-wiki-v3.md` — read these if asked to evolve this schema.

**Scope**: <fill in — whose life/domain does this vault cover, and what's out of scope?>

## Structure

- `_inbox/` — drop zone. The user puts anything here (articles, PDFs, photos, scans, voice memos, web clips, raw notes) to be ingested. Should be empty between ingest sessions.
- `_raw/` — immutable archive of source material. Claude never edits files here after filing. Every wiki page that draws on a source links back to its file here (`[[_raw/filename]]`).
- `_raw/assets/` — images extracted from clippings or other sources.
- `wiki/1-Projects/` — active, short-term efforts with a defined goal and end state. Every project gets its own folder named after the project, containing a main page of the same name plus any supporting pages (drafts, correspondence, working notes).
- `wiki/2-Areas/` — ongoing responsibilities with no end date. Subfolders are created as needed.
- `wiki/3-Resources/` — reference material on topics of interest. Subfolders are created as needed.
- `wiki/3-Resources/Meta/` — docs describing how this wiki itself works (the llm-wiki pattern docs, the PARA method article). Reference these when changing this schema.
- `wiki/4-Archives/` — completed projects, inactive areas, retired resources. Mirrors the structure of 1/2/3.
- `wiki/index.md` — catalog of every wiki page: link, one-line summary, tags, last updated. The first place to look when answering a query.
- `wiki/log.md` — append-only log of ingest/query/lint operations, newest entries on top. Each entry starts with `## [YYYY-MM-DD] <ingest|query|lint> | <title>` so it stays greppable.

## Conventions

YAML frontmatter on every wiki page (Properties + Bases are enabled, so this drives views/filters):

```yaml
---
tags: [tag1, tag2]
created: 2026-06-12
updated: 2026-06-12
status: active # for 1-Projects: active | someday | done
sources: ["[[_raw/some-file.pdf]]"]
---
```

Use `[[wikilinks]]` for all cross-references between pages. New pages start from `_templates/note.md`.

## Workflows

### Ingest

1. List files in `_inbox/`.
2. For each file:
   - If it's not markdown (PDF, image, audio, docx, etc.), convert it first: `uv run markitdown <file> > _inbox/<file>.md`.
   - Read it. For non-trivial sources, discuss the key takeaways with the user before filing.
   - Decide PARA placement and create/update the relevant wiki page(s) — update cross-references in related pages too.
   - Update `wiki/index.md`.
   - Append an entry to `wiki/log.md`.
   - Move the original file (plus any markitdown conversion and extracted images) from `_inbox/` to `_raw/` (images go in `_raw/assets/`).
3. `_inbox/` should be empty when done.

### Query

1. Read `wiki/index.md` to find candidate pages.
2. Read those pages, following `[[wikilinks]]` as needed.
3. Answer with citations back to `_raw/` sources where relevant.
4. If the answer is worth keeping (a synthesis, comparison, plan), offer to file it as a new page and update `wiki/index.md` / `wiki/log.md`.

### Lint

On request, check for:
- Orphan pages with no inbound links.
- Contradictions between pages (flag and ask the user, or resolve by source recency).
- Concepts referenced but with no page of their own.
- Stale `status`/`updated` frontmatter.
- Anything left unprocessed in `_inbox/`.

Log the lint run in `wiki/log.md` with what was found/fixed.

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

- **markitdown** — CLI for converting non-markdown sources (PDF, Word, Excel, images with OCR, audio transcripts, HTML) to markdown during ingest. Run via `uv run markitdown <file>` (a project-local `.venv`, defined by `pyproject.toml`/`uv.lock`, keeps this reproducible across machines — see "Setup on a new machine" below).
- **obsidian-skills** (`.claude/skills/`) — use for correct Obsidian-flavored markdown (wikilinks, callouts, properties, canvas) and for clipping web pages cleanly via Defuddle.
- Search: at this scale, `wiki/index.md` plus `grep`/`Glob` is sufficient. Revisit `qmd` (hybrid BM25/vector/MCP search) only if the wiki grows past ~100-200 pages and `wiki/index.md` becomes unwieldy.

## Setup on a new machine

If you move or copy this vault to a new machine, `.venv/` (Python virtualenv, dotfolder) should not travel with it — it's large and platform-specific. `pyproject.toml`, `uv.lock`, and `.python-version` do travel (they're plain files) and fully describe the environment.

After the vault is on a new machine:
1. Install `uv` if not already present: `curl -LsSf https://astral.sh/uv/install.sh | sh`
2. From the vault root, run `uv sync` once to materialize `.venv` locally.

No other setup should be required for the ingest workflow.
