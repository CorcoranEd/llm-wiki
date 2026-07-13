# LLM Wiki

This is a starter kit for a personal wiki that an LLM helps you maintain — drop in articles, PDFs, notes, whatever, and Claude takes it from there.

Most personal wikis and note piles die the same way: keeping them organized is manual work, so the upkeep quietly stops after a few weeks and the notes stop being useful. This one is built so that doesn't happen — an LLM does the tending, which means the payoff compounds instead of decaying. The longer you use it, the more useful it gets.

- **It organizes everything for you** — drop a file in and it gets filed, cross-referenced, and tidied up automatically.
- **It makes connections you might not** — ask a question and get an answer that draws on everything you've filed, surfacing links between notes you hadn't thought to make yourself.
- **It checks itself** — ask for a lint pass and it flags what needs attention before problems pile up silently.
- **It cleans up after itself** — ask to "curate the wiki" or "work through issues" and it archives finished projects, merges duplicates, and resolves contradictions.

## Setting up this wiki (Mac)

This guide assumes you've never used a terminal or installed developer tools before so dont stress.

### What you're installing and why

- **[Obsidian](https://obsidian.md)** — the app you'll use to read and write notes.
- **Claude Code** — the AI that does the filing and organizing.
- **uv** — a small helper Claude Code uses to convert PDFs and documents into text.
- **Claudian** — an Obsidian plugin that connects Claude Code to your vault.
- **Templater + Metadata Menu** — typed page templates: new pages auto-fill their date fields and title, and get a proper dropdown/date-picker UI for fields like status and priority instead of plain text.
- **Dataview, Tasks, Homepage, Excalidraw** — behind-the-scenes plugins that power the wiki's live status dashboard, task tracking, startup behavior, and freeform diagrams. You won't need to configure any of these yourself.

All of the above ship bundled with this repo — nothing extra to install.

### 1. Run the setup script and log in

Open **Terminal** (press `Cmd+Space`, type "Terminal", hit Enter) and paste this one command:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/CorcoranEd/llm-wiki/main/setup.sh)"
```

That's it — no download needed first. The script fetches everything itself, asks what to name your wiki folder, and handles the rest: installing all the tools, downloading Obsidian, and adding a shortcut to your Dock. It only installs what's missing, so it's safe to run again if something goes wrong.

**Already downloaded this folder?** `cd` into it in Terminal and run `bash setup.sh`.

At the end, the script opens a new Terminal window and prompts you to log in to Claude Code — follow the prompts to create or sign in to your Anthropic account. **The wiki won't work until this is done.**

If you need to log in later, open Terminal and run:

```sh
claude
```

### 2. Make it yours

Obsidian should already be open with this README showing and the Claudian panel ready in the right sidebar (if not, launch Obsidian from Applications — your wiki will already be in the vault list).

1. When Obsidian shows a notice asking if you trust the vault, click **Trust author and enable plugins** — the Claudian plugin won't load without this.
2. In the Claudian panel, tell Claude what you want this wiki to cover — whose life or work it's for, and what's out of scope. Claude will fill in the scope section of `CLAUDE.md` for you.

For example:

- _"This is a personal wiki for my life as a freelance photographer. Cover client projects, gear research, business admin, and creative inspiration. Out of scope: anything work-related to my day job."_
- _"This is a research wiki for my PhD on climate policy. Cover academic papers, notes from conferences, draft arguments, and reading lists. Out of scope: personal life stuff."_
- _"This is a work wiki for a digital product studio. Cover active client projects, proposals, retrospectives, and client relationships, plus skill areas like design, frontend, and strategy. Out of scope: personal finances and anything unrelated to the studio."_
- _"This is a personal life wiki. Cover finances and budgeting, health and fitness, home, travel plans, and things I'm learning. Out of scope: work projects — those live in a separate vault."_

The more specific you are, the better Claude's filing decisions will be. You can always update the scope later by asking Claude to revise it. (If you skip this step, Claude will ask automatically the next time you open a chat, until you answer.)

### 3. Try it out

Setup added an `_inbox` folder icon to your Dock, sitting next to your Downloads/Trash — drag any file onto it (a PDF, an article, a photo, a note) to drop it in, then ask Claude in the Claudian panel to file it. That's the wiki's normal way of taking in new material.

From now on, each time you open a new chat, Claude briefly checks in with what's waiting for you — new inbox items, open issues, anything it auto-fixed since last time. It skips this if there's nothing to report, or if you're just continuing an earlier conversation.

### If something goes wrong

- **Claudian doesn't load** — you may have dismissed the trust dialog; go to **Settings → Community plugins** and enable Claudian from there.
- **Claudian doesn't see Claude Code** — run `claude --version` in Terminal. If that fails, re-run `bash setup.sh`.

## Optional extras

**Web Clipper** — Install the [Obsidian Web Clipper](https://obsidian.md/clipper) browser extension to save web pages directly to your `_inbox`. In the extension settings, choose this vault and set the save location to `_inbox` — clipped pages land there as markdown, ready to file.

**Backup to GitHub** — This folder uses git to keep a history of every change, so you can undo mistakes or look back at earlier versions. To back it up to GitHub, just ask Claude — it can walk you through the setup.

**Get notified about new inbox items** — instead of remembering to check `_inbox` yourself, ask Claude in the Claudian panel to "loop checking my inbox every 15 minutes" (or similar). It'll let you know when something new lands, without filing it automatically — you still review and file it yourself. This only runs while that Claudian session stays open.

**Get a status report** — ask Claude to "/review" for a quick read-only summary: what's waiting in your inbox, open issues worth your attention, notes that haven't been checked for accuracy yet, and a suggestion for what to do next. Pairs well with the loop trick above if you want it repeated automatically.

**Run health checks automatically** — ask Claude to "loop running a lint pass every hour" to keep `wiki/issues.md` current in the background, safe to leave running unattended since it never edits your notes, only flags things.

**Auto-fix the safe stuff** — ask Claude to "loop running the curator in auto-triage mode every hour" to have it quietly fix only the low-risk, high-confidence issues it finds (like an obviously-broken link with one clear match) and leave everything else queued for you to review later — never asks you anything while running this way.

**Connect other apps** — Granola, Google Calendar, Gmail, Google Drive, Slack, and Figma can all be connected so Claude can pull context from them directly. None of these are set up by default — just ask Claude to connect one (e.g. "can you connect my Google Calendar?") and it'll walk you through it. Each is read-only: Claude can look things up but can't send, create, or edit anything through them.

## Updating an existing wiki

If you set up this wiki a while ago, `update.sh` brings it up to date with the current schema — new plugins, page templates, field definitions, `CLAUDE.md`, agent instructions, skills, and hooks — without touching your actual notes or content.

From your wiki folder, run:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/CorcoranEd/llm-wiki/main/update.sh)"
```

Or, if you already have this folder downloaded: `bash update.sh`.

Add `--dry-run` first to see exactly what would change before anything is written, and `--verbose` for full details:

```sh
bash update.sh --dry-run --verbose
```

Every file it changes is backed up first, to `.update-backup/<timestamp>/` in your wiki folder — nothing is overwritten without a copy saved. The one structural change it makes automatically: if your wiki still has `_templates/note.md`, it gets moved to `_config/templates/note.md` as part of this update — that's expected, not an error.

## Going deeper

Once the basics are working, `wiki/3-Resources/Meta/llm-wiki.md` (and `llm-wiki-v2.md`, `llm-wiki-v3.md`) explain the thinking behind how this wiki is organized — worth reading before changing how `CLAUDE.md` directs Claude's behaviour.

The folder structure follows the **PARA method** (Projects, Areas, Resources, Archives) — a simple system for organizing everything in one place. There's a full overview at `wiki/3-Resources/Meta/The PARA Method…` inside the vault, or at [fortelabs.com/blog/para](https://fortelabs.com/blog/para). See `CLAUDE.md`'s Structure section for the folder rules and a worked example of how client work, contacts, and reusable skills map onto these folders.
