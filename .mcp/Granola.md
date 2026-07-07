# Granola

- **Server**: official, first-party — `https://mcp.granola.ai/mcp` (announced at granola.ai/blog/granola-mcp)
- **Auth**: OAuth login to the user's Granola account, via Claude Code's browser-based OAuth flow on first connection. Requires the user be on a **paid Granola plan** — check this before starting setup, it'll fail otherwise.
- **Scope**: no scope selection needed — the server is inherently read-only (meeting notes/transcripts only). No write tools are exposed at all, so there's nothing to restrict.
- **What it can do**: read meeting notes, transcripts, and summaries from the user's Granola account.
- **What it can't do**: nothing — there is no write capability to worry about.

## `.mcp.json` snippet

```json
{
  "mcpServers": {
    "granola": {
      "type": "http",
      "url": "https://mcp.granola.ai/mcp"
    }
  }
}
```

## Setup flow

1. Confirm the user has a paid Granola plan.
2. Add the snippet above to `.mcp.json` (create the file if it doesn't exist).
3. On first use, Claude Code will prompt an OAuth login in the browser — the user logs into Granola and approves.
4. No `.claude/settings.json` deny-list needed for this one.
