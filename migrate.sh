#!/bin/bash
# Sync an existing llm-wiki vault to the latest schema.
# Run from your wiki root:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/CorcoranEd/llm-wiki/main/migrate.sh)"
# Or from a local copy:
#   bash migrate.sh
#
# Flags:
#   -n, --dry-run   Show what would change without touching any files.
#   -v, --verbose   Show full diffs for updated files.
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

if [ "$DRY_RUN" = 1 ]; then
  echo "Running in --dry-run mode: no files will be written."
  echo
fi

# ─── Verify wiki root ─────────────────────────────────────────────────────────
if [ ! -f "CLAUDE.md" ] || [ ! -d ".claude" ]; then
  echo "This doesn't look like an llm-wiki root (CLAUDE.md or .claude/ not found)."
  echo "Run migrate.sh from the root of your existing wiki."
  exit 1
fi

REPO_RAW="https://raw.githubusercontent.com/CorcoranEd/llm-wiki/main"
BACKUP_DIR=".migration-backup/$(date '+%Y%m%d-%H%M%S')"
SCOPE_PLACEHOLDER="<fill in — whose life/domain does this vault cover, and what's out of scope?>"

UPDATED=0
CREATED=0
SKIPPED=0
ERRORS=0

# ─── Helpers ──────────────────────────────────────────────────────────────────

fetch() {
  # fetch <remote-path> → stdout; returns 1 on failure
  local out
  out=$(curl -fsSL "$REPO_RAW/$1" 2>&1) || {
    echo "  ✗ could not download $1 — check your internet connection"
    ERRORS=$((ERRORS + 1))
    return 1
  }
  printf '%s' "$out"
}

write_file() {
  # write_file <local-path> <content>
  mkdir -p "$(dirname "$1")"
  printf '%s\n' "$2" > "$1"
}

backup_file() {
  # backup_file <local-path>
  local dest="$BACKUP_DIR/$1"
  mkdir -p "$(dirname "$dest")"
  cp "$1" "$dest"
  log_verbose "backed up: $1 → $dest"
}

# ─── Strategy A: compare and overwrite ───────────────────────────────────────
# For agent files and commands. Not user-edited; overwrite if content differs.

apply_a() {
  local file="$1" canonical="$2"

  if [ ! -f "$file" ]; then
    if [ "$DRY_RUN" = 1 ]; then
      echo "  [dry-run] would create: $file"
    else
      write_file "$file" "$canonical"
      echo "  ✓ created: $file"
    fi
    CREATED=$((CREATED + 1))
  elif [ "$(cat "$file")" = "$canonical" ]; then
    echo "  ✓ up to date: $file"
    SKIPPED=$((SKIPPED + 1))
  else
    if [ "$VERBOSE" = 1 ]; then
      diff <(cat "$file") <(printf '%s\n' "$canonical") | head -40 || true
    fi
    if [ "$DRY_RUN" = 1 ]; then
      local stat
      stat=$(diff --stat <(cat "$file") <(printf '%s\n' "$canonical") 2>/dev/null | tail -1 || true)
      echo "  [dry-run] would update: $file  ${stat:+(${stat})}"
    else
      backup_file "$file"
      write_file "$file" "$canonical"
      echo "  ✓ updated: $file"
    fi
    UPDATED=$((UPDATED + 1))
  fi
}

# ─── Strategy B: scope-preserving overwrite ──────────────────────────────────
# For CLAUDE.md. Extracts the user's Scope value, injects it into the canonical
# version before comparing. Everything else in CLAUDE.md updates; Scope stays.

apply_b() {
  local canonical="$1"

  local scope
  scope=$(grep '^\*\*Scope\*\*:' CLAUDE.md 2>/dev/null \
    | sed 's/^\*\*Scope\*\*:[[:space:]]*//' \
    | sed 's/[[:space:]]*$//')
  log_verbose "local Scope value: '$scope'"

  # Only substitute if the user has filled it in (not still the placeholder)
  if [ -n "$scope" ] && [ "$scope" != "$SCOPE_PLACEHOLDER" ]; then
    canonical=$(printf '%s\n' "$canonical" \
      | sed "s|^\*\*Scope\*\*:.*|**Scope**: $scope|")
    log_verbose "Scope injected into canonical before comparison"
  fi

  apply_a "CLAUDE.md" "$canonical"
}

# ─── Strategy C: frontmatter-only merge ──────────────────────────────────────
# For _templates/note.md. Adds any frontmatter fields present in the canonical
# version but absent locally. Never touches existing field values or the body.

apply_c() {
  local canonical="$1"

  if [ ! -f "_templates/note.md" ]; then
    if [ "$DRY_RUN" = 1 ]; then
      echo "  [dry-run] would create: _templates/note.md"
    else
      write_file "_templates/note.md" "$canonical"
      echo "  ✓ created: _templates/note.md"
    fi
    CREATED=$((CREATED + 1))
    return
  fi

  # Extract frontmatter keys from canonical (lines between the first --- pair)
  local canonical_keys
  canonical_keys=$(awk 'BEGIN{f=0} /^---/{f++; next} f==1{sub(/:.*/, ""); print}' \
    <<< "$canonical")

  local added=0
  while IFS= read -r key; do
    [ -z "$key" ] && continue
    if ! grep -q "^${key}:" "_templates/note.md"; then
      local field_line
      field_line=$(grep "^${key}:" <<< "$canonical" | head -1)
      [ -z "$field_line" ] && continue

      if [ "$DRY_RUN" = 1 ]; then
        echo "  [dry-run] would add frontmatter field: $key"
      else
        [ "$added" = 0 ] && backup_file "_templates/note.md"
        # Insert the new field before the closing --- of the frontmatter block
        python3 - "$field_line" "_templates/note.md" <<'PYEOF'
import sys
field, path = sys.argv[1], sys.argv[2]
with open(path) as f:
    content = f.read()
# Split on --- to find frontmatter boundaries
parts = content.split('---', 2)
if len(parts) >= 3:
    parts[1] = parts[1].rstrip('\n') + '\n' + field + '\n'
    content = '---'.join(parts)
with open(path, 'w') as f:
    f.write(content)
PYEOF
        echo "  ✓ added template field: $key"
      fi
      UPDATED=$((UPDATED + 1))
      added=$((added + 1))
    else
      log_verbose "template field already present: $key"
    fi
  done <<< "$canonical_keys"

  if [ "$added" = 0 ]; then
    echo "  ✓ up to date: _templates/note.md"
    [ "$DRY_RUN" = 0 ] && SKIPPED=$((SKIPPED + 1))
  fi
}

# ─── Strategy D: create only ─────────────────────────────────────────────────
# For wiki/issues.md. Only created if absent — the linter owns it after that.

apply_d() {
  local file="$1" canonical="$2"

  if [ ! -f "$file" ]; then
    if [ "$DRY_RUN" = 1 ]; then
      echo "  [dry-run] would create: $file"
    else
      write_file "$file" "$canonical"
      echo "  ✓ created: $file"
    fi
    CREATED=$((CREATED + 1))
  else
    echo "  ✓ up to date: $file  (linter-managed, not overwritten)"
    SKIPPED=$((SKIPPED + 1))
  fi
}

# ─── 1. Agent files and commands (Strategy A) ─────────────────────────────────

echo "Checking agent files and commands..."
for file in \
  ".claude/agents/wiki-ingestor.md" \
  ".claude/agents/wiki-librarian.md" \
  ".claude/agents/wiki-linter.md" \
  ".claude/agents/wiki-curator.md" \
  ".claude/commands/review.md"
do
  canonical=$(fetch "$file") || continue
  apply_a "$file" "$canonical"
done
echo

# ─── 2. CLAUDE.md (Strategy B) ───────────────────────────────────────────────

echo "Checking CLAUDE.md..."
canonical=$(fetch "CLAUDE.md") && apply_b "$canonical" || true
echo

# ─── 3. _templates/note.md (Strategy C) ──────────────────────────────────────

echo "Checking _templates/note.md..."
canonical=$(fetch "_templates/note.md") && apply_c "$canonical" || true
echo

# ─── 4. wiki/issues.md (Strategy D) ──────────────────────────────────────────

echo "Checking wiki/issues.md..."
canonical=$(fetch "wiki/issues.md") && apply_d "wiki/issues.md" "$canonical" || true
echo

# ─── Summary ──────────────────────────────────────────────────────────────────

echo "───────────────────────────────────────────────────────────"
if [ "$DRY_RUN" = 1 ]; then
  echo "Dry run complete — nothing was written."
  echo "Created: $CREATED  Updated: $UPDATED  Up to date: $SKIPPED  Errors: $ERRORS"
  echo
  echo "Run without --dry-run to apply."
else
  echo "Done."
  echo "Created: $CREATED  Updated: $UPDATED  Up to date: $SKIPPED  Errors: $ERRORS"
  if [ "$((CREATED + UPDATED))" -gt 0 ]; then
    echo
    echo "Backups saved to: $BACKUP_DIR"
  fi
fi
echo
