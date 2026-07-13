#!/bin/bash
# SessionStart hook: summarizes inbox/issue/auto-fix state so Claude can greet
# the user with it instead of requiring a manual /review.
set -euo pipefail

cd "$(dirname "$0")/../.."

INBOX_DIR="_inbox"
ISSUES_FILE="wiki/issues.md"
LOG_FILE="wiki/log.md"
MARKER_FILE=".claude/state/last-greeting.txt"

inbox_count=0
if [ -d "$INBOX_DIR" ]; then
  inbox_count=$(find "$INBOX_DIR" -maxdepth 1 -type f ! -name 'README.md' ! -name '.*' | wc -l | tr -d ' ')
fi

issue_count=0
if [ -f "$ISSUES_FILE" ]; then
  issue_count=$(grep -c '^- ' "$ISSUES_FILE" || true)
fi

log_lines=0
if [ -f "$LOG_FILE" ]; then
  log_lines=$(wc -l < "$LOG_FILE" | tr -d ' ')
fi

last_lines=0
if [ -f "$MARKER_FILE" ]; then
  last_lines=$(cat "$MARKER_FILE" | tr -d ' ')
fi
[ -z "$last_lines" ] && last_lines=0

autofixed_count=0
if [ -f "$LOG_FILE" ] && [ "$log_lines" -gt "$last_lines" ]; then
  autofixed_count=$(tail -n +"$((last_lines + 1))" "$LOG_FILE" | grep -c '^## \[.*\] curate | auto-fix' || true)
fi

mkdir -p "$(dirname "$MARKER_FILE")"
echo "$log_lines" > "$MARKER_FILE"

context="Wiki status: ${inbox_count} file(s) in _inbox/, ${issue_count} open issue(s) in wiki/issues.md, ${autofixed_count} issue(s) auto-fixed by wiki-curator since the last session. If this is the start of a conversation, briefly greet the user with these three numbers in one line before addressing their message. Skip the greeting if all three are zero, or if this is a resumed/continued session rather than a fresh one."

jq -n --arg ctx "$context" '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
