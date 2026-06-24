#!/bin/bash
# Sets up the tools this vault needs: Homebrew, Node.js, the Claude Code CLI, and uv.
# Run it with: bash setup.sh
set -u

have() {
  command -v "$1" >/dev/null 2>&1
}

confirm() {
  local prompt="$1 [Y/n] "
  local answer
  read -r -p "$prompt" answer
  case "$answer" in
    [nN]|[nN][oO]) return 1 ;;
    *) return 0 ;;
  esac
}

echo "This will check for the tools this vault needs, and offer to install anything missing."
echo "Just press Enter to accept the default (yes) at each prompt."
echo

# 1. Homebrew
if have brew; then
  echo "✓ Homebrew is already installed."
else
  echo
  echo "Homebrew is the standard way to install developer tools on a Mac."
  if confirm "Install Homebrew now?"; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if have brew; then
      echo "✓ Homebrew installed."
    else
      echo "Homebrew installed something, but the 'brew' command isn't on your PATH yet."
      echo "It likely printed a couple of lines for you to run — copy/paste those into this Terminal, then re-run: bash setup.sh"
      exit 1
    fi
  else
    echo "Skipping Homebrew means Node.js, and therefore Claude Code, can't be installed by this script."
  fi
fi

# 2. Node.js (needed to install the Claude Code CLI via npm)
if have node; then
  echo "✓ Node.js is already installed."
elif have brew; then
  echo
  echo "Node.js is needed to install the Claude Code CLI."
  if confirm "Install Node.js now?"; then
    brew install node
    if have node; then
      echo "✓ Node.js installed."
    else
      echo "Node.js install didn't finish correctly. Try running 'brew install node' yourself, then re-run: bash setup.sh"
    fi
  else
    echo "Skipping Node.js means Claude Code can't be installed by this script."
  fi
else
  echo "Skipping Node.js — Homebrew isn't installed."
fi

# 3. Claude Code CLI
if have claude; then
  echo "✓ Claude Code is already installed."
elif have node; then
  echo
  echo "Claude Code is the AI that does the filing and organizing in this wiki."
  if confirm "Install Claude Code now?"; then
    npm install -g @anthropic-ai/claude-code
    if have claude; then
      echo "✓ Claude Code installed. Run 'claude' and log in with your Anthropic account when you're ready."
    else
      echo "Claude Code install didn't finish correctly. Try running 'npm install -g @anthropic-ai/claude-code' yourself, then re-run: bash setup.sh"
    fi
  else
    echo "Skipping Claude Code — you can install it later by running this script again."
  fi
else
  echo "Skipping Claude Code — Node.js isn't installed."
fi

# 4. uv (Python tool, used by markitdown to convert PDFs/docs during ingest)
if have uv; then
  echo "✓ uv is already installed."
else
  echo
  echo "uv is a small tool Claude Code uses to convert PDFs and other documents to text."
  if confirm "Install uv now?"; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    if have uv; then
      echo "✓ uv installed."
    else
      echo "uv installed but isn't on your PATH yet in this Terminal session. Close and reopen Terminal, then re-run: bash setup.sh"
    fi
  else
    echo "Skipping uv means the document-conversion tooling won't be set up."
  fi
fi

# 5. Python tooling for this vault
if have uv; then
  echo
  echo "Setting up this vault's Python tooling..."
  uv sync
  echo "✓ Python tooling ready."
fi

# 6. Initialize local git repository for this copy
if have git; then
  if [ ! -d .git ]; then
    echo
    echo "Initializing a local git repository for this copy of the vault..."
    git init
    if git config --get user.name >/dev/null 2>&1 && git config --get user.email >/dev/null 2>&1; then
      git add -A
      git commit -m 'chore: initial local repository setup' >/dev/null 2>&1 || true
      echo "✓ Local git repository initialized."
    else
      echo "✓ Local git repository initialized."
      echo "  Note: configure git user.name and user.email to make commits:"
      echo "    git config --global user.name \"Your Name\""
      echo "    git config --global user.email \"you@example.com\""
    fi
  else
    echo
    echo "✓ This folder is already a git repository."
  fi
else
  echo
  echo "Note: git is not installed or not available in PATH. If you want local version control, install git and re-run this script."
fi

echo
echo "Terminal setup done. Next steps:"
echo "  1. If you just installed Claude Code, run 'claude' and log in."
echo "  2. Install Obsidian — opening the download page for you now."
echo "  3. See README.md for the remaining steps (opening this folder as a vault, enabling plugins)."
open "https://obsidian.md" >/dev/null 2>&1 || true
