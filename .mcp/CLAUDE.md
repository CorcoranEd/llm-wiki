This folder holds reference sheets for optional MCP integrations — Granola, Google Calendar/Gmail/Drive, Slack, Figma. None of these are live. Nothing here is auto-loaded into the vault or run automatically; they exist so you can enable one on request without re-deriving setup details from scratch.

## When the user asks to connect one of these

1. Read the matching file (`Granola.md`, `Google-Workspace.md`, `Slack.md`, `Figma.md`).
2. Always prefer the official server listed there — these files already did that research; don't substitute a community/third-party server unless the user explicitly asks for one and understands the tradeoff.
3. Walk the user through whatever manual steps that service actually requires (OAuth app registration, Cloud Console setup, etc.) conversationally — these files are your reference facts (URL, scopes, auth type), not scripts to paste verbatim at the user. Explain what each step does as you go.
4. Register **only the read-only scopes** listed in the file — never the write/mutating scopes shown alongside them for contrast.
5. Write (or create) `.mcp.json` at the repo root with the entry from the file, using env var references for credentials (e.g. `${GOOGLE_OAUTH_CLIENT_ID}`), never hardcoded secrets — safe to commit as-is.
6. For Figma specifically: also create/update `.claude/settings.json` with the deny rule from `Figma.md` before considering it "read-only enabled" — the plugin itself doesn't offer a read-only mode, so this step is the actual enforcement, not optional.
7. Confirm with the user what was set up and what it can/can't do (e.g. "this can read your calendar but never create or modify events").

## Why nothing is live by default

The user wants these available on request, not installed as part of vault setup — most people won't need most of these, and each one requires its own account-specific credentials the user has to provide interactively anyway. There's nothing to pre-configure beyond the reference facts in this folder.
