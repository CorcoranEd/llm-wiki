# Slack

- **Server**: official — `https://mcp.slack.com/mcp` (docs.slack.dev/ai/slack-mcp-server/)
- **Auth**: confidential OAuth. Requires a registered Slack app with a **fixed app ID** — the user (or a workspace admin) creates an app at api.slack.com/apps, which yields a client ID/secret.
  - Authorization endpoint: `https://slack.com/oauth/v2_user/authorize`
  - Token endpoint: `https://slack.com/api/oauth.v2.user.access`
  - Note: some workspaces require admin approval before a new app can be installed/authorized — flag this possibility to the user rather than assuming it'll go through immediately.

## Scopes — register only the read-only ones

Use: `channels:history`, `channels:read`, `groups:read`, `groups:history`, `im:history`, `mpim:read`, `mpim:history`, `users:read`, `users:read.email`, `search:read.public`, `search:read.private`, `search:read.mpim`, `search:read.im`, `search:read.files`, `search:read.users`, `files:read`, `canvases:read`, `emoji:read`

Never register: `chat:write`, `reactions:write`, `canvases:write`, or any channel-creation/management scope.

## `.mcp.json` snippet

```json
{
  "mcpServers": {
    "slack": {
      "type": "http",
      "url": "https://mcp.slack.com/mcp",
      "env": {
        "SLACK_CLIENT_ID": "${SLACK_CLIENT_ID}",
        "SLACK_CLIENT_SECRET": "${SLACK_CLIENT_SECRET}"
      }
    }
  }
}
```

## Setup flow

1. Have the user create a Slack app at api.slack.com/apps (or confirm one already exists for this purpose).
2. Add only the read-only scopes listed above to the app's OAuth configuration.
3. Set `SLACK_CLIENT_ID`/`SLACK_CLIENT_SECRET` as environment variables.
4. Add the snippet above to `.mcp.json`.
5. On first use, an OAuth authorize flow runs in the browser — the user logs into the workspace and approves.
6. No `.claude/settings.json` deny-list needed — read-only is enforced by which scopes were actually granted.
