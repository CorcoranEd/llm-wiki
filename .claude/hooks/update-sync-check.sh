#!/bin/bash
# SessionStart hook: nudges the user to sync existing pages after update.sh has
# rolled the schema forward. update.sh only creates .update-backup/<timestamp>/
# when it actually writes changes (never on --dry-run, never when nothing
# differed), so a new timestamp there reliably means the schema just changed.
set -euo pipefail

cd "$(dirname "$0")/../.."

BACKUP_DIR=".update-backup"
MARKER_FILE=".claude/state/last-update-sync-check.txt"

[ -d "$BACKUP_DIR" ] || exit 0

latest=$(find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | sort | tail -1 || true)
[ -n "$latest" ] || exit 0

last_seen=""
[ -f "$MARKER_FILE" ] && last_seen=$(cat "$MARKER_FILE")

if [ -n "$last_seen" ] && [[ ! "$latest" > "$last_seen" ]]; then
  exit 0
fi

mkdir -p "$(dirname "$MARKER_FILE")"
echo "$latest" > "$MARKER_FILE"

context="update.sh ran on this vault recently (backup timestamp ${latest}), which means the schema (fileClass definitions and/or page templates) may have moved forward since some existing pages were created. If this is the start of a fresh conversation, mention this and offer to run /sync-templates to bring existing pages up to date with the current schema (additive only — it won't overwrite anything) — or /triage first if the user would rather review what's out of date before applying fixes. This is a one-time nudge for this update.sh run; skip it if this is a resumed/continued session."

jq -n --arg ctx "$context" '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
