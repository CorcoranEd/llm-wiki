# Setting up this wiki (Mac)

This folder is a starter kit for a personal wiki that an AI helps you maintain. You drop in articles, PDFs, notes, whatever — and it gets filed, cross-referenced, and kept tidy for you. This guide assumes you've never used a terminal or installed developer tools before.

> **Downloaded from GitHub?** If the folder is named `llm-wiki-main`, that's normal — the setup script will offer to rename it.

## What you're installing and why

- **[Obsidian](https://obsidian.md)** — the app you'll use to read and write notes.
- **Claude Code** — the AI that does the filing and organizing.
- **uv** — a small helper Claude Code uses to convert PDFs and documents into text.
- **Claudian** — an Obsidian plugin that connects Claude Code to your vault.

## 1. Run the setup script

**Double-click `Setup.command`** in this folder. macOS will open a Terminal window and run the setup automatically.

> If macOS says it can't open the file because it's from an unidentified developer: right-click `Setup.command`, choose **Open**, then click **Open** again in the dialog.

The script asks one question — what to name your wiki folder — then handles everything else: moving it to `~/Sites`, installing all the tools, downloading Obsidian, and adding a shortcut to your Dock. It only installs what's missing, so it's safe to run again if something goes wrong.

**Prefer the terminal?** Open Terminal (`Cmd+Space`, type "Terminal", Enter), `cd` into this folder, and run `bash setup.sh`.

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

## 4. Clip web pages to your wiki

Install the **[Obsidian Web Clipper](https://obsidian.md/clipper)** browser extension. After installing:

1. Open the extension and go to its **Settings**.
2. Choose this vault.
3. Set the **save location** to `_inbox`.

Anything you clip will land in `_inbox` as markdown. Open the Claudian panel and ask Claude to file it — that's the normal ingest workflow.

## 5. Make this wiki yours

Open the Claudian panel from Obsidian's left sidebar and tell Claude what you want this wiki to cover — whose life or work it's for, and what's out of scope. Claude will fill in the scope section of `CLAUDE.md` for you.

## 6. Try it out

Drop any file (a PDF, an article, a photo, a note) into the `_inbox` folder — there's a shortcut to it in your Dock — and ask Claude in the Claudian panel to file it. That's the wiki's normal way of taking in new material.

## If something goes wrong

- **macOS blocks the script** — right-click `Setup.command`, choose Open, then Open again.
- **"command not found" after an install** — close and reopen Terminal, then run `bash setup.sh` again. New tools sometimes don't appear until you start a fresh session.
- **Claudian doesn't load** — you may have dismissed the trust dialog; go to **Settings → Community plugins** and enable Claudian from there.
- **Claudian doesn't see Claude Code** — run `claude --version` in Terminal. If that fails, re-run `bash setup.sh`.

## Keeping a history and backing up

This folder uses git to keep a history of every change, so you can undo mistakes or look back at earlier versions. To back it up to GitHub, just ask Claude — it can walk you through the setup.

## Going deeper

Once the basics are working, `wiki/3-Resources/Meta/llm-wiki.md` (and `llm-wiki-v2.md`, `llm-wiki-v3.md`) explain the thinking behind how this wiki is organized — worth reading before changing how `CLAUDE.md` directs Claude's behaviour.
