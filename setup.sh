#!/bin/bash
# One-liner install (no download needed):
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/CorcoranEd/llm-wiki/main/setup.sh)"
# Or from a downloaded copy: bash setup.sh  /  double-click Setup.command
set -u

# ─── Locate the vault (or download it if running via curl) ───────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-./}")" 2>/dev/null && pwd)"

if [ ! -f "$SCRIPT_DIR/CLAUDE.md" ] || [ ! -d "$SCRIPT_DIR/_inbox" ]; then
  # Running via curl — ask for a name and download directly to ~/Sites
  _SITES_DIR="$HOME/Sites"
  mkdir -p "$_SITES_DIR"
  read -r -p "What do you want to call this wiki's folder? [llm-wiki] " _CURL_NAME
  _CURL_NAME="${_CURL_NAME:-llm-wiki}"
  _DEST="$_SITES_DIR/$_CURL_NAME"
  if [ -e "$_DEST" ]; then
    echo "A folder named $_CURL_NAME already exists in ~/Sites."
    echo "Remove it or choose a different name, then re-run."
    exit 1
  fi
  echo "Downloading to $_DEST..."
  _TMPZIP="$(mktemp /tmp/llm-wiki-XXXXXX.zip)"
  _TMPDIR="$(mktemp -d /tmp/llm-wiki-XXXXXX)"
  curl -L -# https://github.com/CorcoranEd/llm-wiki/archive/refs/heads/main.zip -o "$_TMPZIP"
  unzip -q "$_TMPZIP" -d "$_TMPDIR"
  rm -f "$_TMPZIP"
  mv "$_TMPDIR/llm-wiki-main" "$_DEST"
  rm -rf "$_TMPDIR"
  SCRIPT_DIR="$_DEST"
  echo "✓ Downloaded to $_DEST"
  echo
fi

cd "$SCRIPT_DIR" || { echo "Couldn't find the vault directory. Aborting."; exit 1; }

# ─── Bring installed-but-not-yet-sourced tools onto PATH ─────────────────────
# Homebrew (Apple Silicon: /opt/homebrew; Intel: /usr/local)
if [ -x "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
# uv installs its binary here
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
# npm global bin (only query if npm is already available)
if command -v npm >/dev/null 2>&1; then
  _NPM_PREFIX="$(npm config get prefix 2>/dev/null)"
  [ -n "$_NPM_PREFIX" ] && export PATH="$_NPM_PREFIX/bin:$PATH"
fi

have() {
  command -v "$1" >/dev/null 2>&1
}

echo
echo "Setting up your wiki — this may take a few minutes."
echo

# ─── 0. Name and move to ~/Sites ─────────────────────────────────────────────
SITES_DIR="$HOME/Sites"
CURRENT_DIR="$SCRIPT_DIR"
CURRENT_NAME="$(basename "$CURRENT_DIR")"
SUGGESTED="llm-wiki"
TARGET_DIR="$CURRENT_DIR"

if [ "$(dirname "$CURRENT_DIR")" != "$SITES_DIR" ]; then
  read -r -p "What do you want to call this wiki's folder? [$SUGGESTED] " NEW_NAME
  NEW_NAME="${NEW_NAME:-$SUGGESTED}"
  PROPOSED_DIR="$SITES_DIR/$NEW_NAME"
  if [ -e "$PROPOSED_DIR" ]; then
    echo "$PROPOSED_DIR already exists — leaving this copy where it is."
  else
    mkdir -p "$SITES_DIR"
    mv "$CURRENT_DIR" "$PROPOSED_DIR"
    cd "$PROPOSED_DIR" || { echo "Couldn't move into $PROPOSED_DIR. Aborting."; exit 1; }
    TARGET_DIR="$PROPOSED_DIR"
    echo "✓ Moved to $TARGET_DIR"
  fi
  echo
fi

# ─── 1. Homebrew ─────────────────────────────────────────────────────────────
if have brew; then
  echo "✓ Homebrew already installed."
else
  echo "Installing Homebrew (Mac's standard developer tool installer)..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Source into the current shell immediately after install
  if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  if have brew; then
    echo "✓ Homebrew installed."
  else
    echo "Homebrew installation didn't finish. Open a new Terminal window and re-run: bash setup.sh"
    exit 1
  fi
fi

# ─── 2. Node.js ──────────────────────────────────────────────────────────────
if have node; then
  echo "✓ Node.js already installed."
elif have brew; then
  echo "Installing Node.js..."
  brew install node
  if have node; then
    echo "✓ Node.js installed."
  else
    echo "Node.js installation failed. Try running 'brew install node' manually, then re-run: bash setup.sh"
    exit 1
  fi
else
  echo "Skipping Node.js — Homebrew isn't available."
fi

# ─── 3. Claude Code CLI ──────────────────────────────────────────────────────
if have claude; then
  echo "✓ Claude Code already installed."
elif have node; then
  echo "Installing Claude Code..."
  npm install -g @anthropic-ai/claude-code
  # Refresh npm global bin on PATH after install
  _NPM_PREFIX="$(npm config get prefix 2>/dev/null)"
  [ -n "$_NPM_PREFIX" ] && export PATH="$_NPM_PREFIX/bin:$PATH"
  if have claude; then
    echo "✓ Claude Code installed."
  else
    echo "Claude Code installation failed. Try running 'npm install -g @anthropic-ai/claude-code' manually."
    exit 1
  fi
else
  echo "Skipping Claude Code — Node.js isn't installed."
fi

# ─── 4. uv ───────────────────────────────────────────────────────────────────
if have uv; then
  echo "✓ uv already installed."
else
  echo "Installing uv (document conversion helper)..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
  if have uv; then
    echo "✓ uv installed."
  else
    echo "uv installed but isn't on PATH yet — open a new Terminal window and re-run: bash setup.sh"
    exit 1
  fi
fi

# ─── 5. Python tooling for document conversion ───────────────────────────────
echo "Setting up document conversion tooling..."
(cd "$TARGET_DIR" && uv sync --quiet)
echo "✓ Document tooling ready."

# ─── 6. Obsidian ─────────────────────────────────────────────────────────────
if [ -d "/Applications/Obsidian.app" ]; then
  echo "✓ Obsidian already installed."
else
  echo "Downloading and installing Obsidian..."
  ARCH="$(uname -m)"
  if [ "$ARCH" = "arm64" ]; then
    DMG_URL=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest \
      | grep '"browser_download_url"' | grep 'arm64\.dmg' \
      | sed 's/.*"browser_download_url": "\([^"]*\)".*/\1/' | head -1)
  else
    DMG_URL=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest \
      | grep '"browser_download_url"' | grep '\.dmg' | grep -v 'arm64' \
      | sed 's/.*"browser_download_url": "\([^"]*\)".*/\1/' | head -1)
  fi
  if [ -z "$DMG_URL" ]; then
    echo "Couldn't fetch the Obsidian download URL. Install it manually from https://obsidian.md"
  else
    TMPFILE="$(mktemp /tmp/obsidian-XXXXXX.dmg)"
    curl -L -# -o "$TMPFILE" "$DMG_URL"
    hdiutil attach "$TMPFILE" -nobrowse 2>/dev/null
    APP_PATH="$(find /Volumes -maxdepth 2 -name "Obsidian.app" -type d 2>/dev/null | head -1)"
    if [ -n "$APP_PATH" ]; then
      VOLUME_PATH="$(dirname "$APP_PATH")"
      cp -R "$APP_PATH" /Applications/
      hdiutil detach "$VOLUME_PATH" -quiet 2>/dev/null || true
      echo "✓ Obsidian installed."
    else
      echo "Couldn't install Obsidian automatically. Install it manually from https://obsidian.md"
    fi
    rm -f "$TMPFILE"
  fi
fi

# ─── 7. Register vault in Obsidian ───────────────────────────────────────────
OBSIDIAN_CONFIG="$HOME/Library/Application Support/obsidian/obsidian.json"
if [ -d "/Applications/Obsidian.app" ]; then
  python3 - "$TARGET_DIR" "$OBSIDIAN_CONFIG" <<'PYEOF'
import json, os, sys, time, random

vault_path = sys.argv[1]
config_path = sys.argv[2]

if os.path.exists(config_path):
    with open(config_path) as f:
        config = json.load(f)
else:
    os.makedirs(os.path.dirname(config_path), exist_ok=True)
    config = {}

config.setdefault("vaults", {})

# Skip if already registered
if any(v.get("path") == vault_path for v in config["vaults"].values()):
    print("already registered")
    sys.exit(0)

vault_id = "%016x" % random.getrandbits(64)
config["vaults"][vault_id] = {"path": vault_path, "ts": int(time.time() * 1000)}

with open(config_path, "w") as f:
    json.dump(config, f, indent=2)
print("registered")
PYEOF
  echo "✓ Vault registered in Obsidian."
fi

# ─── 8. git ─────────────────────────────────────────────────────────────────
if ! have git && have brew; then
  echo "Installing git..."
  brew install git
fi

if have git; then
  if [ ! -d "$TARGET_DIR/.git" ]; then
    echo "Initializing local git repository..."
    (cd "$TARGET_DIR" && git init -q && git add -A && \
      git commit -q -m 'chore: initial local repository setup' 2>/dev/null || true)
    echo "✓ Git repository initialized."
  else
    echo "✓ Git repository already set up."
  fi
fi

# ─── 9. Finder sidebar + Dock shortcut ───────────────────────────────────────
sfltool add-bookmark "file://$TARGET_DIR" 2>/dev/null || true
INBOX_DIR="$TARGET_DIR/_inbox"
defaults write com.apple.dock persistent-others -array-add \
  "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$INBOX_DIR</string><key>_CFURLStringType</key><integer>0</integer></dict></dict><key>tile-type</key><string>directory-tile</string></dict>" \
  2>/dev/null || true
killall Dock 2>/dev/null || true
echo "✓ Wiki folder added to Finder sidebar; _inbox added to Dock."

# ─── Done — next steps and auth ──────────────────────────────────────────────
echo
echo "════════════════════════════════════════════════════════"
echo "  Installation complete!"
echo "════════════════════════════════════════════════════════"
echo
echo "  OPEN OBSIDIAN"
echo "    1. Launch Obsidian from Applications"
echo "    2. Choose 'Open folder as vault'"
echo "    3. Select: $TARGET_DIR"
echo "    4. When asked to trust the vault, click:"
echo "       'Trust author and enable plugins'"
echo "       (Claudian won't work without this)"
echo
echo "  WEB CLIPPER (save web pages to your wiki)"
echo "    Install the browser extension: https://obsidian.md/clipper"
echo "    In its settings, choose this vault and set the"
echo "    save location to:  _inbox"
echo
echo "════════════════════════════════════════════════════════"
echo "  ⚠  LOG IN TO CLAUDE CODE (required)"
echo "════════════════════════════════════════════════════════"
echo
echo "  The wiki won't work until you're logged in."
echo "  Opening a new Terminal window to log you in now..."
echo
if have claude; then
  osascript -e 'tell application "Terminal" to do script "claude"'
else
  echo "  Claude Code isn't on PATH right now."
  echo "  Open a new Terminal window and run:  claude"
fi
