# Setting up this wiki (Mac)

This folder is a starter kit for a personal wiki that an AI helps you maintain. You drop in articles, PDFs, notes, whatever — and it gets filed, cross-referenced, and kept tidy for you. This guide assumes you've never used a terminal or installed developer tools before.

## What you're installing and why

- **[Obsidian](https://obsidian.md)** — the app you'll use to read and write notes.
- **Claude Code** — the AI that does the filing and organizing.
- **uv** — a small helper Claude Code uses to convert PDFs and documents into text.
- **Claudian** — an Obsidian plugin that connects Claude Code to your vault.

## 1. Run the setup script

Open **Terminal** (press `Cmd+Space`, type "Terminal", hit Enter) and paste this one command:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/CorcoranEd/llm-wiki/main/setup.sh)"
```

That's it — no download needed first. The script fetches everything itself, asks what to name your wiki folder, and handles the rest: installing all the tools, downloading Obsidian, and adding a shortcut to your Dock. It only installs what's missing, so it's safe to run again if something goes wrong.

**Already downloaded this folder?** `cd` into it in Terminal and run `bash setup.sh`.

## 2. Log in to Claude Code

The script will launch Claude Code at the end and prompt you to log in. Follow the prompts to create or sign in to your Anthropic account. **The wiki won't work until this is done.**

If you need to log in later, open Terminal and run:

```sh
claude
```

## 3. Open the vault in Obsidian

1. Launch **Obsidian** from your Applications folder — your wiki will already be in the vault list.
2. Click on it to open it.
3. When Obsidian shows a notice asking if you trust the vault, click **Trust author and enable plugins** — the Claudian plugin won't load without this.

## 4. Make this wiki yours

Open the Claudian panel from Obsidian's left sidebar and tell Claude what you want this wiki to cover — whose life or work it's for, and what's out of scope. Claude will fill in the scope section of `CLAUDE.md` for you.

For example:

- *"This is a personal wiki for my life as a freelance photographer. Cover client projects, gear research, business admin, and creative inspiration. Out of scope: anything work-related to my day job."*
- *"This is a research wiki for my PhD on climate policy. Cover academic papers, notes from conferences, draft arguments, and reading lists. Out of scope: personal life stuff."*
- *"This is a work wiki for a digital product studio. Cover active client projects, proposals, retrospectives, and client relationships, plus skill areas like design, frontend, and strategy. Out of scope: personal finances and anything unrelated to the studio."*
- *"This is a personal life wiki. Cover finances and budgeting, health and fitness, home, travel plans, and things I'm learning. Out of scope: work projects — those live in a separate vault."*

The more specific you are, the better Claude's filing decisions will be. You can always update the scope later by asking Claude to revise it.

## 5. Try it out

Drop any file (a PDF, an article, a photo, a note) into the `_inbox` folder — there's a shortcut to it in your Dock — and ask Claude in the Claudian panel to file it. That's the wiki's normal way of taking in new material.

## If something goes wrong

- **macOS blocks the script** — right-click `Setup.command`, choose Open, then Open again.
- **Claudian doesn't load** — you may have dismissed the trust dialog; go to **Settings → Community plugins** and enable Claudian from there.
- **Claudian doesn't see Claude Code** — run `claude --version` in Terminal. If that fails, re-run `bash setup.sh`.

## Optional extras

**Web Clipper** — Install the [Obsidian Web Clipper](https://obsidian.md/clipper) browser extension to save web pages directly to your `_inbox`. In the extension settings, choose this vault and set the save location to `_inbox` — clipped pages land there as markdown, ready to file.

**Backup to GitHub** — This folder uses git to keep a history of every change, so you can undo mistakes or look back at earlier versions. To back it up to GitHub, just ask Claude — it can walk you through the setup.

## Going deeper

Once the basics are working, `wiki/3-Resources/Meta/llm-wiki.md` (and `llm-wiki-v2.md`, `llm-wiki-v3.md`) explain the thinking behind how this wiki is organized — worth reading before changing how `CLAUDE.md` directs Claude's behaviour.

The folder structure follows the **PARA method** (Projects, Areas, Resources, Archives) — a simple system for organizing everything in one place. There's a full overview at `wiki/3-Resources/Meta/The PARA Method…` inside the vault, or at [fortelabs.com/blog/para](https://fortelabs.com/blog/para). See `CLAUDE.md`'s Structure section for the folder rules and a worked example of how client work, contacts, and reusable skills map onto these folders.
