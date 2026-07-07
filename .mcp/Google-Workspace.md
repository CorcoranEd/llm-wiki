# Google Workspace (Calendar, Gmail, Drive)

Three separate official servers, one shared Google Cloud OAuth setup. All part of Google's Workspace Developer Preview Program as of this writing.

| Service | Server URL | Official doc |
|---|---|---|
| Calendar | `https://calendarmcp.googleapis.com/mcp/v1` | developers.google.com/workspace/calendar/api/guides/configure-mcp-server |
| Gmail | `https://gmailmcp.googleapis.com/mcp/v1` | developers.google.com/workspace/gmail/api/guides/configure-mcp-server |
| Drive | `https://drivemcp.googleapis.com/mcp/v1` | developers.google.com/workspace/drive/api/guides/configure-mcp-server |

Combined setup guide: developers.google.com/workspace/guides/configure-mcp-servers

## Scopes — register only the readonly ones

| Service | Read-only scope (use this) | Write scope (never register this) |
|---|---|---|
| Calendar | `https://www.googleapis.com/auth/calendar.calendarlist.readonly`, `https://www.googleapis.com/auth/calendar.events.readonly` | full read-write calendar scopes |
| Gmail | `https://www.googleapis.com/auth/gmail.readonly` | `https://www.googleapis.com/auth/gmail.compose` (drafts, labeling) |
| Drive | `https://www.googleapis.com/auth/drive.readonly` | `https://www.googleapis.com/auth/drive.file` (file creation) |

## Auth setup (one-time, covers all three services)

1. Create a Google Cloud project (or use an existing one dedicated to this).
2. Enable APIs: Gmail API, Google Drive API, Google Calendar API, plus the MCP service variants (`gmailmcp.googleapis.com`, `drivemcp.googleapis.com`, `calendarmcp.googleapis.com`).
3. Configure the OAuth consent screen (any app name, e.g. "Wiki MCP"; Internal or External user type — External if the user's own Google account isn't on a Workspace org).
4. Add **only** the six readonly scopes above to the consent screen — not the write ones.
5. Create OAuth 2.0 client credentials (Web application type).
6. Set `GOOGLE_OAUTH_CLIENT_ID` and `GOOGLE_OAUTH_CLIENT_SECRET` as environment variables the user's shell has access to (never hardcode them in `.mcp.json`).

Google's own walkthrough describes step 5–6 for the claude.ai web Connectors UI (Settings → Connectors → Add custom connector) rather than Claude Code specifically. For Claude Code, the equivalent is the `.mcp.json` entries below — Claude Code handles the OAuth redirect itself on first connection. If Claude Code's OAuth flow needs a specific redirect URI registered in the Cloud Console (rather than accepting any/localhost), confirm that against Claude Code's current remote-MCP-OAuth docs at setup time rather than assuming — this detail wasn't independently verified for the Claude Code CLI specifically.

## `.mcp.json` snippet (enable only the services actually wanted — doesn't have to be all three)

```json
{
  "mcpServers": {
    "google-calendar": {
      "type": "http",
      "url": "https://calendarmcp.googleapis.com/mcp/v1",
      "env": {
        "GOOGLE_OAUTH_CLIENT_ID": "${GOOGLE_OAUTH_CLIENT_ID}",
        "GOOGLE_OAUTH_CLIENT_SECRET": "${GOOGLE_OAUTH_CLIENT_SECRET}"
      }
    },
    "gmail": {
      "type": "http",
      "url": "https://gmailmcp.googleapis.com/mcp/v1",
      "env": {
        "GOOGLE_OAUTH_CLIENT_ID": "${GOOGLE_OAUTH_CLIENT_ID}",
        "GOOGLE_OAUTH_CLIENT_SECRET": "${GOOGLE_OAUTH_CLIENT_SECRET}"
      }
    },
    "google-drive": {
      "type": "http",
      "url": "https://drivemcp.googleapis.com/mcp/v1",
      "env": {
        "GOOGLE_OAUTH_CLIENT_ID": "${GOOGLE_OAUTH_CLIENT_ID}",
        "GOOGLE_OAUTH_CLIENT_SECRET": "${GOOGLE_OAUTH_CLIENT_SECRET}"
      }
    }
  }
}
```

No `.claude/settings.json` deny-list needed — read-only is enforced at the OAuth scope level, so the token itself can't perform write operations regardless of which tools the server exposes.
