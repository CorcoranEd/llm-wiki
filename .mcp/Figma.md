# Figma

- **Server**: official remote plugin — `claude plugin install figma@claude-plugins-official`
- **Auth**: OAuth via browser flow on install. After installing, go to the Installed plugins tab, select the Figma server, and confirm access when the authentication page opens.
- **Alternative not used here**: the local Dev Mode desktop server (`http://127.0.0.1:3845/mcp`, needs no OAuth but requires the Figma desktop app running with Dev Mode enabled) has fewer capabilities per Figma's own docs. The user explicitly chose the more capable remote plugin over this simpler option.

## Read-only enforcement — hybrid, not fully native

Figma is the only one of the six integrations without a genuine read-only mode. The remote plugin ships with write tools baked in. Enforcement is split:

- **Hard-denied** via `.claude/settings.json` (add these — see snippet below, fill in the real server name once installed): `create_new_file`, `upload_assets`, `add_code_connect_map`, `send_code_connect_mappings`. These are unambiguously write-only.
- **Left allowed, instructional only**: `use_figma`. This tool is FigJam's combined read/write entry point — denying it would also break FigJam reading (confirmed: `get_figjam` depends on `use_figma` for establishing context in some flows). Document to the user that `use_figma` must only be used to *read* FigJam content, never to create/edit it — this is a behavioral guideline, not a technical block.
- Everything else (`get_design_context`, `get_screenshot`, `get_metadata`, `get_variable_defs`, `get_figjam`, `get_code_connect_map`, `search_design_system`, `download_assets`, `export_video`, `list_shader_effects`, `list_shader_fills`, `get_shader_effect`, `get_shader_fill`, `get_motion_context`, `get_libraries`, `whoami`) is read-only by nature and needs no restriction.

## `.claude/settings.json` deny-list (merge into the existing file, don't overwrite)

Replace `<figma-server-name>` with whatever Claude Code actually names the connection once installed (visible in `claude mcp list` or similar) — it's not knowable in advance.

```json
{
  "permissions": {
    "deny": [
      "mcp__<figma-server-name>__create_new_file",
      "mcp__<figma-server-name>__upload_assets",
      "mcp__<figma-server-name>__add_code_connect_map",
      "mcp__<figma-server-name>__send_code_connect_mappings"
    ]
  }
}
```

## Setup flow

1. Run `claude plugin install figma@claude-plugins-official`.
2. Complete the OAuth confirmation in the browser when prompted.
3. Find the actual tool namespace prefix Claude Code assigned (check the connected server's tool list).
4. Add/update the deny rule above in `.claude/settings.json` with the real prefix substituted in.
5. Tell the user: reading Figma designs and FigJam boards works; `use_figma` should only be used to read, never to create/edit, even though it's technically not blocked.
