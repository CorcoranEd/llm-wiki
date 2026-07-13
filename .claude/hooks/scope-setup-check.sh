#!/bin/bash
# SessionStart hook: nudges a new user to fill in CLAUDE.md's Scope line
# (still the template placeholder) instead of leaving it unset indefinitely.
# Becomes a permanent no-op the moment the placeholder text is edited.
set -euo pipefail

cd "$(dirname "$0")/../.."

CLAUDE_MD="CLAUDE.md"
PLACEHOLDER='<fill in — whose life/domain does this vault cover, and what'"'"'s out of scope?>'

if [ ! -f "$CLAUDE_MD" ] || ! grep -qF "$PLACEHOLDER" "$CLAUDE_MD"; then
  exit 0
fi

context="This vault's CLAUDE.md Scope line is still the template placeholder — no one has said what this wiki should cover yet. If this is genuinely the start of a new conversation (not a resumed one), ask the user what this wiki should cover: whose life or work it's for, and what's out of scope. You can offer the four example scopes from README.md's '2. Make it yours' section (photographer, PhD researcher, product studio, personal life) if it helps them get specific. Once they answer, replace the placeholder in CLAUDE.md's Scope line with their answer. This is a soft nudge only: if the user wants to do something else first, proceed with that instead and ask again next fresh session."

jq -n --arg ctx "$context" '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
