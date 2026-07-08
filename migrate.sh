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
# For agent files, commands, fileClass definitions, and plugin code. Not
# user-edited; overwrite if content differs.

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
    # Skip full-content diffing for large files (e.g. plugin main.js bundles) —
    # a diff over a multi-MB, near-single-line minified file is unreadable and slow.
    local size
    size=$(wc -c < "$file" 2>/dev/null || echo 0)
    if [ "$VERBOSE" = 1 ] && [ "$size" -lt 100000 ]; then
      diff <(cat "$file") <(printf '%s\n' "$canonical") | head -40 || true
    elif [ "$VERBOSE" = 1 ]; then
      log_verbose "$file is $(( size / 1024 ))KB — skipping full diff"
    fi
    if [ "$DRY_RUN" = 1 ]; then
      local stat
      if [ "$size" -lt 100000 ]; then
        stat=$(diff --stat <(cat "$file") <(printf '%s\n' "$canonical") 2>/dev/null | tail -1 || true)
      fi
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
# For templates under _config/templates/. Adds any frontmatter fields present
# in the canonical version but absent locally. Never touches existing field
# values or the body.

apply_c() {
  local file="$1" canonical="$2"

  if [ ! -f "$file" ]; then
    if [ "$DRY_RUN" = 1 ]; then
      echo "  [dry-run] would create: $file"
    else
      write_file "$file" "$canonical"
      echo "  ✓ created: $file"
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
    if ! grep -q "^${key}:" "$file"; then
      local field_line
      field_line=$(grep "^${key}:" <<< "$canonical" | head -1)
      [ -z "$field_line" ] && continue

      if [ "$DRY_RUN" = 1 ]; then
        echo "  [dry-run] would add frontmatter field to $file: $key"
      else
        [ "$added" = 0 ] && backup_file "$file"
        # Insert the new field before the closing --- of the frontmatter block
        python3 - "$field_line" "$file" <<'PYEOF'
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
        echo "  ✓ added template field to $file: $key"
      fi
      UPDATED=$((UPDATED + 1))
      added=$((added + 1))
    else
      log_verbose "template field already present in $file: $key"
    fi
  done <<< "$canonical_keys"

  if [ "$added" = 0 ]; then
    echo "  ✓ up to date: $file"
    [ "$DRY_RUN" = 0 ] && SKIPPED=$((SKIPPED + 1))
  fi
}

# ─── Strategy D: create only ─────────────────────────────────────────────────
# For wiki/issues.md and plugin settings (data.json) a user may have already
# customized. Only created if absent — never overwritten after that.

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
    echo "  ✓ up to date: $file  (not overwritten — may hold local customization)"
    SKIPPED=$((SKIPPED + 1))
  fi
}

# ─── Strategy E: JSON array union-merge ──────────────────────────────────────
# For .obsidian/community-plugins.json. Adds any plugin IDs present in the
# canonical list but missing locally; keeps every existing local entry
# (including plugins the user added independently) and never reorders/removes.

apply_e() {
  local file="$1" canonical="$2"

  if [ ! -f "$file" ]; then
    if [ "$DRY_RUN" = 1 ]; then
      echo "  [dry-run] would create: $file"
    else
      write_file "$file" "$canonical"
      echo "  ✓ created: $file"
    fi
    CREATED=$((CREATED + 1))
    return
  fi

  local tmp_canonical merged
  tmp_canonical=$(mktemp)
  printf '%s' "$canonical" > "$tmp_canonical"

  merged=$(python3 - "$file" "$tmp_canonical" <<'PYEOF'
import json, sys
local_path, canon_path = sys.argv[1], sys.argv[2]
with open(local_path) as f:
    local = json.load(f)
with open(canon_path) as f:
    canon = json.load(f)
merged = local + [x for x in canon if x not in local]
print(json.dumps(merged, indent=2))
PYEOF
)
  rm -f "$tmp_canonical"

  if [ -z "$merged" ]; then
    echo "  ✗ could not parse $file as JSON — skipping merge"
    ERRORS=$((ERRORS + 1))
    return
  fi

  if [ "$(cat "$file")" = "$merged" ]; then
    echo "  ✓ up to date: $file"
    [ "$DRY_RUN" = 0 ] && SKIPPED=$((SKIPPED + 1))
  else
    if [ "$DRY_RUN" = 1 ]; then
      echo "  [dry-run] would update: $file  (merge in any missing plugin IDs)"
    else
      backup_file "$file"
      printf '%s\n' "$merged" > "$file"
      echo "  ✓ updated: $file"
    fi
    UPDATED=$((UPDATED + 1))
  fi
}

# ─── Strategy F: named-section merge ─────────────────────────────────────────
# For wiki/index.md. Inserts or updates the fixed "## Status Board" section
# (matched by heading, ending at the next "## " heading) while leaving
# everything else — the user's hand-maintained PARA catalog — untouched.

apply_f() {
  local file="$1" canonical="$2"

  if [ ! -f "$file" ]; then
    if [ "$DRY_RUN" = 1 ]; then
      echo "  [dry-run] would create: $file"
    else
      write_file "$file" "$canonical"
      echo "  ✓ created: $file"
    fi
    CREATED=$((CREATED + 1))
    return
  fi

  local tmp_canonical result
  tmp_canonical=$(mktemp)
  printf '%s\n' "$canonical" > "$tmp_canonical"

  result=$(python3 - "$file" "$tmp_canonical" <<'PYEOF'
import sys
local_path, canon_path = sys.argv[1], sys.argv[2]
with open(local_path) as f:
    local = f.read()
with open(canon_path) as f:
    canon = f.read()

HEADING = "## Status Board"

def extract_section(text):
    lines = text.split('\n')
    try:
        start = next(i for i, l in enumerate(lines) if l.strip() == HEADING)
    except StopIteration:
        return None
    end = len(lines)
    for i in range(start + 1, len(lines)):
        if lines[i].startswith('## '):
            end = i
            break
    return '\n'.join(lines[start:end]).rstrip('\n') + '\n'

canon_section = extract_section(canon)
if canon_section is None:
    print(local, end='')
    sys.exit(0)

local_section = extract_section(local)
if local_section == canon_section:
    print("UNCHANGED", end='')
    sys.exit(0)

lines = local.split('\n')
if local_section is None:
    try:
        insert_at = next(i for i, l in enumerate(lines) if l.startswith('## '))
    except StopIteration:
        insert_at = len(lines)
    new_lines = lines[:insert_at] + canon_section.split('\n') + [''] + lines[insert_at:]
else:
    start = next(i for i, l in enumerate(lines) if l.strip() == HEADING)
    end = len(lines)
    for i in range(start + 1, len(lines)):
        if lines[i].startswith('## '):
            end = i
            break
    new_lines = lines[:start] + canon_section.split('\n') + lines[end:]

print('\n'.join(new_lines), end='')
PYEOF
)
  rm -f "$tmp_canonical"

  if [ "$result" = "UNCHANGED" ]; then
    echo "  ✓ up to date: $file"
    [ "$DRY_RUN" = 0 ] && SKIPPED=$((SKIPPED + 1))
    return
  fi

  if [ "$DRY_RUN" = 1 ]; then
    echo "  [dry-run] would update: $file  (Status Board section)"
  else
    backup_file "$file"
    printf '%s\n' "$result" > "$file"
    echo "  ✓ updated: $file  (Status Board section)"
  fi
  UPDATED=$((UPDATED + 1))
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

# ─── 2.5. README.md (Strategy A) ─────────────────────────────────────────────
# Unlike CLAUDE.md, README.md has no user-filled content to preserve — plain
# compare-and-overwrite, same as the agent files.

echo "Checking README.md..."
canonical=$(fetch "README.md") && apply_a "README.md" "$canonical" || true
echo

# ─── 3. _config/ directory layout ────────────────────────────────────────────
# Older vaults ship _templates/note.md at the old location. Move it (with
# backup) before running the template merge below — otherwise a fresh
# _config/templates/note.md would be created from scratch and the user's
# customized old template would be silently orphaned at _templates/note.md.

echo "Checking _config/ directory layout..."
if [ -f "_templates/note.md" ] && [ ! -f "_config/templates/note.md" ]; then
  if [ "$DRY_RUN" = 1 ]; then
    echo "  [dry-run] would move: _templates/note.md -> _config/templates/note.md"
  else
    mkdir -p "_config/templates"
    backup_file "_templates/note.md"
    mv "_templates/note.md" "_config/templates/note.md"
    rmdir "_templates" 2>/dev/null || true
    echo "  ✓ moved: _templates/note.md -> _config/templates/note.md"
  fi
  UPDATED=$((UPDATED + 1))
else
  log_verbose "no _templates/ -> _config/ move needed"
fi
echo

# ─── 4. _config/templates/*.md (Strategy C) ──────────────────────────────────

echo "Checking _config/templates/..."
for file in note Project Area Resource Person; do
  canonical=$(fetch "_config/templates/${file}.md") || continue
  apply_c "_config/templates/${file}.md" "$canonical"
done
echo

# ─── 5. _config/fileclasses/*.md (Strategy A) ────────────────────────────────

echo "Checking _config/fileclasses/..."
for file in Base Project Area Resource Person; do
  canonical=$(fetch "_config/fileclasses/${file}.md") || continue
  apply_a "_config/fileclasses/${file}.md" "$canonical"
done
echo

# ─── 6. wiki/issues.md (Strategy D) ──────────────────────────────────────────

echo "Checking wiki/issues.md..."
canonical=$(fetch "wiki/issues.md") && apply_d "wiki/issues.md" "$canonical" || true
echo

# ─── 7. wiki/index.md Status Board (Strategy F) ──────────────────────────────

echo "Checking wiki/index.md Status Board..."
canonical=$(fetch "wiki/index.md") && apply_f "wiki/index.md" "$canonical" || true
echo

# ─── 8. Obsidian plugins (Strategy A for code, Strategy D for settings) ──────

echo "Checking Obsidian plugins..."
for plugin in dataview metadata-menu templater-obsidian \
              obsidian-tasks-plugin obsidian-excalidraw-plugin homepage
do
  for asset in main.js manifest.json styles.css; do
    canonical=$(fetch ".obsidian/plugins/${plugin}/${asset}") || continue
    apply_a ".obsidian/plugins/${plugin}/${asset}" "$canonical"
  done
done
# Settings worth pinning on first install; never overwritten once present,
# since the user may have customized fields/templates/choices by then.
for plugin_data in \
  "metadata-menu" \
  "templater-obsidian" \
  "homepage" \
  "obsidian-excalidraw-plugin"
do
  canonical=$(fetch ".obsidian/plugins/${plugin_data}/data.json") || continue
  apply_d ".obsidian/plugins/${plugin_data}/data.json" "$canonical"
done
echo

# ─── 9. .obsidian/community-plugins.json (Strategy E) ────────────────────────

echo "Checking .obsidian/community-plugins.json..."
canonical=$(fetch ".obsidian/community-plugins.json") && apply_e ".obsidian/community-plugins.json" "$canonical" || true
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
