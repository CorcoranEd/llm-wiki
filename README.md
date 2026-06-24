# Setting up this wiki (Mac)

This folder is a starter kit for a personal wiki that an AI helps you maintain. You drop in articles, PDFs, notes, whatever — and it gets filed, cross-referenced, and kept tidy for you. This guide assumes you've never used a terminal or installed developer tools before, and walks through everything needed to get it running.

## What you're installing and why

- **[Obsidian](https://obsidian.md)** — the app you'll actually use to read and write notes.
- **Claude Code** — the AI that does the filing and organizing.
- **uv** — a small helper tool Claude Code uses to convert PDFs and other documents into text.
- **Claudian** — an Obsidian plugin that connects Claude Code to your notes, so the AI can work right inside the app.

## 1. Run the setup script

Open **Terminal** (press `Cmd+Space`, type "Terminal", press Enter). This opens a window where you type commands instead of clicking — every command below is meant to be copy-pasted in, one at a time, followed by Enter.

In Terminal, move into this folder (replace the path if you put it somewhere other than Downloads):

```
cd ~/Downloads/llm-wiki-boilerplate
```

Then run the setup script:

```
bash setup.sh
```

It checks what you already have installed and asks before installing anything new — just press Enter to accept each default (yes). It installs, in order: Homebrew (Mac's standard tool installer), Node.js, the Claude Code CLI, and uv. This can take a few minutes, especially the first step.

## 2. Log into Claude Code

The script can install Claude Code but can't log you in. Once it's done, run:

```
claude
```

and follow the prompt to log in with your Anthropic account. Check it worked with:

```
claude --version
```

If that prints a version number, you're set.

## 3. Make this vault your own

Open `CLAUDE.md` (a plain text file in this folder) in any text editor and fill in the **Scope** line under "What this is" — whose life or work this wiki covers, and what's out of scope. You can also rename this folder to whatever you want to call your wiki.

## 4. Install Obsidian

The setup script should have already opened [obsidian.md](https://obsidian.md) in your browser. Download and install it like any other Mac app, then open it.

When Obsidian asks you to open a vault, choose **Open folder as vault** and select this folder.

## 5. Turn on the Claudian plugin

In Obsidian, go to **Settings → Community plugins** and turn on **Claudian**. It's already included in this folder — it's how Claude Code works inside your vault.

## 6. Try it out

Open the Claudian panel from Obsidian's sidebar and confirm it can see Claude Code. Then drop any file (a PDF, an article, a note) into the `_inbox` folder and ask Claude to file it — that's the wiki's normal way of taking in new material.

## If something goes wrong

- **"command not found" in Terminal** — close and reopen the Terminal window after an install finishes, then run `bash setup.sh` again. New tools sometimes don't show up until you start a fresh Terminal session.
- **Claudian doesn't see Claude Code** — run `claude --version` in Terminal first to confirm Claude Code works on its own. If that fails, re-run `bash setup.sh`.

## Going deeper

Once the basics are working, `wiki/3-Resources/Meta/llm-wiki.md`, `llm-wiki-v2.md`, and `llm-wiki-v3.md` explain the thinking behind how this wiki is organized — worth reading before you change how `CLAUDE.md` directs Claude's behavior.
