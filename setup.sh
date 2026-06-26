#!/bin/bash
# One-liner install (no download needed):
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/CorcoranEd/llm-wiki/main/setup.sh)"
# Or from a downloaded copy: bash setup.sh  /  double-click Setup.command
#
# Flags (downloaded copy):  bash setup.sh --dry-run --verbose
# Flags (via curl):         /bin/bash -c "$(curl -fsSL .../setup.sh)" -- --dry-run --verbose
#   -n, --dry-run   Don't install/move/write anything — print what each step would do.
#   -v, --verbose   Print extra diagnostic detail (paths, detected values, command results).
#   -h, --help      Show this help and exit.
set -u

DRY_RUN=0
VERBOSE=0
for arg in "$@"; do
  case "$arg" in
    -n|--dry-run) DRY_RUN=1 ;;
    -v|--verbose) VERBOSE=1 ;;
    -h|--help)
      sed -n '2,10p' "${BASH_SOURCE[0]:-$0}"
      exit 0
      ;;
    *)
      echo "Unknown flag: $arg (use --help for usage)"
      exit 1
      ;;
  esac
done

log_verbose() { [ "$VERBOSE" = 1 ] && echo "  [verbose] $*"; }
dry() { [ "$DRY_RUN" = 1 ] && echo "  [dry-run] $*"; }

if [ "$DRY_RUN" = 1 ]; then
  echo "Running in --dry-run mode: no files will be moved/written, nothing will be installed."
  echo
fi

# ─── Locate the vault (or download it if running via curl) ───────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-./}")" 2>/dev/null && pwd)"

if [ ! -f "$SCRIPT_DIR/CLAUDE.md" ] || [ ! -d "$SCRIPT_DIR/_inbox" ]; then
  # Running via curl — ask for a name and download directly to ~/Sites
  if [ "$DRY_RUN" = 1 ]; then
    _SITES_DIR="$HOME/Downloads"
    _CURL_NAME="llm-wiki-dry-run-test"
    dry "would prompt for a folder name and download the repo into ~/Sites — testing the download/unzip pipeline into $_SITES_DIR/$_CURL_NAME instead"
  else
    _SITES_DIR="$HOME/Sites"
    read -r -p "What do you want to call this wiki's folder? [llm-wiki] " _CURL_NAME
    _CURL_NAME="${_CURL_NAME:-llm-wiki}"
  fi
  mkdir -p "$_SITES_DIR"
  _DEST="$_SITES_DIR/$_CURL_NAME"
  if [ -e "$_DEST" ]; then
    if [ "$DRY_RUN" = 1 ]; then
      rm -rf "$_DEST"
    else
      echo "A folder named $_CURL_NAME already exists in ~/Sites."
      echo "Remove it or choose a different name, then re-run."
      exit 1
    fi
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
  if [ "$DRY_RUN" = 1 ]; then
    if [ -f "$SCRIPT_DIR/CLAUDE.md" ] && [ -d "$SCRIPT_DIR/_inbox" ]; then
      echo "✓ [dry-run] Downloaded and unzipped repo to $_DEST — pipeline works. Continuing the dry run against this test copy. (Left there for inspection — delete manually when done.)"
    else
      echo "✗ [dry-run] Downloaded to $_DEST but it doesn't look like a valid vault — check it manually."
    fi
  else
    echo "✓ Downloaded to $_DEST"
  fi
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
  log_verbose "current dir: $CURRENT_DIR, proposed target: $PROPOSED_DIR"
  if [ -e "$PROPOSED_DIR" ]; then
    echo "$PROPOSED_DIR already exists — leaving this copy where it is."
  elif [ "$DRY_RUN" = 1 ]; then
    dry "would mkdir -p $SITES_DIR and move $CURRENT_DIR -> $PROPOSED_DIR"
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
log_verbose "command -v brew: $(command -v brew 2>/dev/null || echo not found)"
if have brew; then
  echo "✓ Homebrew already installed."
elif [ "$DRY_RUN" = 1 ]; then
  dry "would install Homebrew"
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
log_verbose "command -v node: $(command -v node 2>/dev/null || echo not found)"
if have node; then
  echo "✓ Node.js already installed."
elif [ "$DRY_RUN" = 1 ]; then
  dry "would install Node.js"
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
log_verbose "command -v claude: $(command -v claude 2>/dev/null || echo not found)"
if have claude; then
  echo "✓ Claude Code already installed."
elif [ "$DRY_RUN" = 1 ]; then
  dry "would install Claude Code CLI"
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
log_verbose "command -v uv: $(command -v uv 2>/dev/null || echo not found)"
if have uv; then
  echo "✓ uv already installed."
elif [ "$DRY_RUN" = 1 ]; then
  dry "would install uv"
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

# ─── 4.5. jq (needed to safely register the vault in Obsidian's config) ──────
log_verbose "command -v jq: $(command -v jq 2>/dev/null || echo not found)"
if have jq; then
  echo "✓ jq already installed."
elif [ "$DRY_RUN" = 1 ]; then
  dry "would install jq"
elif have brew; then
  echo "Installing jq..."
  brew install jq
  if have jq; then
    echo "✓ jq installed."
  else
    echo "jq installation failed. Vault won't be auto-registered in Obsidian — add it manually after install."
  fi
else
  echo "Skipping jq — Homebrew isn't available. Vault won't be auto-registered in Obsidian."
fi

# ─── 5. Python tooling for document conversion ───────────────────────────────
echo "Setting up document conversion tooling..."
if [ "$DRY_RUN" = 1 ]; then
  dry "would run: uv sync --quiet in $TARGET_DIR"
else
  (cd "$TARGET_DIR" && uv sync --quiet)
  echo "✓ Document tooling ready."
fi

# ─── 6. Obsidian ─────────────────────────────────────────────────────────────
if [ -d "/Applications/Obsidian.app" ] && [ "$DRY_RUN" != 1 ]; then
  echo "✓ Obsidian already installed."
else
  if [ "$DRY_RUN" = 1 ]; then
    DEST_DIR="$HOME/Downloads"
    dry "downloading/mounting Obsidian for real, copying to $DEST_DIR instead of /Applications (to verify the pipeline without touching your real install)"
  else
    DEST_DIR="/Applications"
    echo "Downloading and installing Obsidian..."
  fi
  ARCH="$(uname -m)"
  log_verbose "ARCH: $ARCH"
  RELEASE_JSON="$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest)"
  if [ "$ARCH" = "arm64" ]; then
    DMG_URL=$(echo "$RELEASE_JSON" | grep '"browser_download_url"' | grep 'arm64\.dmg' \
      | sed 's/.*"browser_download_url": "\([^"]*\)".*/\1/' | head -1)
  else
    DMG_URL=$(echo "$RELEASE_JSON" | grep '"browser_download_url"' | grep '\.dmg"' | grep -v 'arm64' \
      | sed 's/.*"browser_download_url": "\([^"]*\)".*/\1/' | head -1)
  fi
  if [ -z "$DMG_URL" ]; then
    # Obsidian currently ships a single universal .dmg (no arch split) — fall back to it.
    DMG_URL=$(echo "$RELEASE_JSON" | grep '"browser_download_url"' | grep '\.dmg"' \
      | sed 's/.*"browser_download_url": "\([^"]*\)".*/\1/' | head -1)
  fi
  log_verbose "DMG_URL: $DMG_URL"
  if [ -z "$DMG_URL" ]; then
    echo "Couldn't fetch the Obsidian download URL. Install it manually from https://obsidian.md"
  else
    TMPFILE="$(mktemp /tmp/obsidian-XXXXXX.dmg)"
    curl -L -# -o "$TMPFILE" "$DMG_URL"
    hdiutil attach "$TMPFILE" -nobrowse 2>/dev/null
    APP_PATH="$(find /Volumes -maxdepth 2 -name "Obsidian.app" -type d 2>/dev/null | head -1)"
    if [ -n "$APP_PATH" ]; then
      VOLUME_PATH="$(dirname "$APP_PATH")"
      cp -R "$APP_PATH" "$DEST_DIR/"
      hdiutil detach "$VOLUME_PATH" -quiet 2>/dev/null || true
      if [ -f "$DEST_DIR/Obsidian.app/Contents/Info.plist" ]; then
        if [ "$DRY_RUN" = 1 ]; then
          echo "✓ [dry-run] Downloaded, mounted, and copied Obsidian.app to $DEST_DIR — pipeline works. (Left there for inspection — delete manually when done.)"
        else
          # A raw cp -R bypasses the normal install paths that trigger Launch Services
          # to index a new app — without this, the Dock icon can show as "?" and
          # open/obsidian:// can fail to resolve the app until LS catches up on its own.
          LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister"
          [ -x "$LSREGISTER" ] && "$LSREGISTER" -f "$DEST_DIR/Obsidian.app" 2>/dev/null
          echo "✓ Obsidian installed."
        fi
      else
        echo "Copied Obsidian.app to $DEST_DIR but couldn't verify it — check it manually."
      fi
    else
      echo "Couldn't install Obsidian automatically. Install it manually from https://obsidian.md"
    fi
    rm -f "$TMPFILE"
  fi
fi

# ─── 7. Register vault in Obsidian ───────────────────────────────────────────
OBSIDIAN_CONFIG="$HOME/Library/Application Support/obsidian/obsidian.json"
log_verbose "Obsidian config path: $OBSIDIAN_CONFIG"
log_verbose "Vault path to register: $TARGET_DIR"

# Adds $TARGET_DIR to a vaults config at path $1, in place. Prints ✓/✗ with $2 as a label.
# Returns non-zero if jq is missing or the write failed.
register_vault_in_config() {
  local config_path="$1" label="$2"
  if jq -e --arg p "$TARGET_DIR" 'any(.vaults[]?; .path == $p)' "$config_path" >/dev/null 2>&1; then
    log_verbose "$label: vault already present"
    echo "✓ ($label) vault already registered."
    return 0
  fi
  local vault_id ts
  vault_id="$(od -An -N8 -tx1 /dev/urandom | tr -d ' \n')"
  ts="$(($(date +%s) * 1000))"
  if jq --arg id "$vault_id" --arg path "$TARGET_DIR" --argjson ts "$ts" \
      '.vaults[$id] = {path: $path, ts: $ts}' "$config_path" > "$config_path.tmp" \
      && mv "$config_path.tmp" "$config_path"; then
    if jq -e --arg p "$TARGET_DIR" 'any(.vaults[]?; .path == $p)' "$config_path" >/dev/null 2>&1; then
      echo "✓ ($label) vault registered and verified in $config_path."
      return 0
    fi
    echo "✗ ($label) jq ran but the vault wasn't found afterward — check $config_path"
    return 1
  fi
  rm -f "$config_path.tmp"
  echo "✗ ($label) jq/write failed — check $config_path"
  return 1
}

if [ -d "/Applications/Obsidian.app" ]; then
  if [ "$DRY_RUN" = 1 ]; then
    if ! have jq; then
      dry "would register vault $TARGET_DIR in $OBSIDIAN_CONFIG, but jq isn't installed to test with"
    else
      dry "testing the jq registration logic against copies in $HOME/Downloads — not touching $OBSIDIAN_CONFIG"
      if [ -f "$OBSIDIAN_CONFIG" ]; then
        EXISTING_TEST="$HOME/Downloads/obsidian-dry-run-existing.json"
        cp "$OBSIDIAN_CONFIG" "$EXISTING_TEST"
        register_vault_in_config "$EXISTING_TEST" "existing config copy"
        log_verbose "existing-config test file: $EXISTING_TEST"
      else
        echo "  [dry-run] no existing obsidian.json to copy — skipping that case"
      fi
      FRESH_TEST="$HOME/Downloads/obsidian-dry-run-fresh.json"
      echo '{}' > "$FRESH_TEST"
      register_vault_in_config "$FRESH_TEST" "fresh config"
      log_verbose "fresh-config test file: $FRESH_TEST"
      echo "  [dry-run] test files left in $HOME/Downloads for inspection — delete manually when done."
    fi
  elif ! have jq; then
    echo "Couldn't register the vault automatically — jq not found. Open Obsidian and add this vault manually: $TARGET_DIR"
  else
    if [ ! -f "$OBSIDIAN_CONFIG" ]; then
      mkdir -p "$(dirname "$OBSIDIAN_CONFIG")"
      echo '{}' > "$OBSIDIAN_CONFIG"
    fi
    if ! register_vault_in_config "$OBSIDIAN_CONFIG" "Obsidian"; then
      echo "Open Obsidian and add this vault manually: $TARGET_DIR"
    fi
  fi
fi

# ─── 8. git ─────────────────────────────────────────────────────────────────
if ! have git && have brew; then
  if [ "$DRY_RUN" = 1 ]; then
    dry "would install git"
  else
    echo "Installing git..."
    brew install git
  fi
fi

if have git; then
  if [ ! -d "$TARGET_DIR/.git" ]; then
    if [ "$DRY_RUN" = 1 ]; then
      dry "would git init and commit in $TARGET_DIR"
    else
      echo "Initializing local git repository..."
      (cd "$TARGET_DIR" && git init -q && git add -A && \
        git commit -q -m 'chore: initial local repository setup' 2>/dev/null || true)
      echo "✓ Git repository initialized."
    fi
  else
    echo "✓ Git repository already set up."
  fi
fi

# ─── 8.5. dockutil (needed to pin Dock items correctly) ──────────────────────
log_verbose "command -v dockutil: $(command -v dockutil 2>/dev/null || echo not found)"
if have dockutil; then
  echo "✓ dockutil already installed."
elif [ "$DRY_RUN" = 1 ]; then
  dry "would install dockutil"
elif have brew; then
  echo "Installing dockutil..."
  brew install dockutil
  if have dockutil; then
    echo "✓ dockutil installed."
  else
    echo "dockutil installation failed. Obsidian and _inbox won't be pinned to the Dock — add them manually."
  fi
else
  echo "Skipping dockutil — Homebrew isn't available. Obsidian and _inbox won't be pinned to the Dock."
fi

# ─── 9. Dock shortcuts ────────────────────────────────────────────────────────
# Hand-rolled `defaults write ... persistent-apps` entries render as a "?" Dock
# icon — real app tiles carry a binary NSURL bookmark (`book` field) that can't
# be constructed via plain plist XML. dockutil builds correct entries for both
# apps and folders, so it's used for both tiles here instead of two mechanisms.
INBOX_DIR="$TARGET_DIR/_inbox"
if [ "$DRY_RUN" = 1 ]; then
  dry "would pin $INBOX_DIR and Obsidian to the Dock via dockutil"
elif have dockutil; then
  dockutil --list 2>/dev/null | grep -qF "$INBOX_DIR" || dockutil --add "$INBOX_DIR" --no-restart 2>/dev/null
  if [ -d "/Applications/Obsidian.app" ]; then
    dockutil --list 2>/dev/null | grep -q "Obsidian" || dockutil --add "/Applications/Obsidian.app" --no-restart 2>/dev/null
  fi
  killall Dock 2>/dev/null || true
  echo "✓ _inbox and Obsidian added to Dock."
fi

# ─── 10. Open Obsidian ────────────────────────────────────────────────────────
VAULT_NAME="$(basename "$TARGET_DIR")"
if [ "$DRY_RUN" = 1 ]; then
  dry "would open Obsidian directly to vault '$VAULT_NAME' (README + Claudian panel pre-configured to open)"
elif [ -d "/Applications/Obsidian.app" ]; then
  if have jq; then
    VAULT_NAME_ENC="$(jq -rn --arg v "$VAULT_NAME" '$v|@uri')"
    open "obsidian://open?vault=$VAULT_NAME_ENC"
  else
    open -a Obsidian
  fi
else
  echo "Obsidian isn't installed — install it from https://obsidian.md, then open it manually."
fi

# ─── Done — next steps and auth ──────────────────────────────────────────────
echo
echo "════════════════════════════════════════════════════════"
echo "  Installation complete!"
echo "════════════════════════════════════════════════════════"
echo
echo "  OPEN OBSIDIAN"
echo "    Obsidian should now be open with this wiki's README and the"
echo "    Claudian panel already showing. When asked to trust the vault,"
echo "    click 'Trust author and enable plugins'"
echo "    (Claudian won't work without this)"
echo
echo "  ADD TO FINDER SIDEBAR (optional)"
echo "    Select the wiki folder in Finder and press ⌘⌃T, or drag it"
echo "    into the sidebar — there's no reliable way to automate this"
echo "    on current macOS."
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
echo "  Logging you in now..."
echo
if [ "$DRY_RUN" = 1 ]; then
  dry "would skip the first-run theme wizard and run: claude auth login"
elif have claude; then
  if have jq; then
    # Pre-seed onboarding state (global, machine-wide — not project-scoped) so a
    # fresh install skips straight past the cosmetic theme wizard to the actual
    # login. Only sets these if absent; never overwrites a real existing value,
    # and never touches hasTrustDialogAccepted (a real per-project security gate).
    CLAUDE_SETTINGS="$HOME/.claude/settings.json"
    if [ ! -f "$CLAUDE_SETTINGS" ]; then
      mkdir -p "$(dirname "$CLAUDE_SETTINGS")"
      echo '{}' > "$CLAUDE_SETTINGS"
    fi
    if ! jq -e 'has("theme")' "$CLAUDE_SETTINGS" >/dev/null 2>&1; then
      jq '.theme = "dark"' "$CLAUDE_SETTINGS" > "$CLAUDE_SETTINGS.tmp" 2>/dev/null \
        && mv "$CLAUDE_SETTINGS.tmp" "$CLAUDE_SETTINGS"
    fi
    CLAUDE_GLOBAL="$HOME/.claude.json"
    if [ ! -f "$CLAUDE_GLOBAL" ]; then
      echo '{}' > "$CLAUDE_GLOBAL"
    fi
    if ! jq -e '.hasCompletedOnboarding == true' "$CLAUDE_GLOBAL" >/dev/null 2>&1; then
      jq '.hasCompletedOnboarding = true' "$CLAUDE_GLOBAL" > "$CLAUDE_GLOBAL.tmp" 2>/dev/null \
        && mv "$CLAUDE_GLOBAL.tmp" "$CLAUDE_GLOBAL"
    fi
  fi
  claude auth login
else
  echo "  Claude Code isn't on PATH right now."
  echo "  Run this to log in:  claude auth login"
fi
