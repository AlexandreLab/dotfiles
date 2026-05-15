#!/usr/bin/env python3
"""sync-mcp — regenerate per-tool MCP configs from mcp-servers.json.

Source of truth: ~/agents-shared/mcp-servers.json
Targets:
  - Claude Code: ~/.claude.json (skipped — context7 comes via Claude.ai integration; uncomment if you add other servers)
  - Gemini CLI:  ~/.gemini/settings.json (top-level "mcpServers")
  - Codex:       ~/.codex/config.toml    (manual — TOML conversion left to user)

Run: python3 ~/agents-shared/sync-mcp.sh
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

HOME = Path.home()
SHARED = HOME / "agents-shared" / "mcp-servers.json"


def load_servers() -> dict:
    if not SHARED.exists():
        sys.exit(f"missing {SHARED}")
    raw = json.loads(SHARED.read_text())
    servers = raw.get("mcpServers", {})
    # Strip $note / $comment metadata fields before writing to tool configs.
    return {
        name: {k: v for k, v in cfg.items() if not k.startswith("$")}
        for name, cfg in servers.items()
    }


def update_json(path: Path, servers: dict) -> None:
    if not path.exists():
        print(f"skip (not found): {path}")
        return
    data = json.loads(path.read_text())
    data["mcpServers"] = servers
    path.write_text(json.dumps(data, indent=2) + "\n")
    print(f"updated {path}")


def main() -> None:
    servers = load_servers()

    # --- Claude Code ---
    # claude_cfg = HOME / ".claude.json"
    # update_json(claude_cfg, servers)

    # --- Gemini CLI ---
    update_json(HOME / ".gemini" / "settings.json", servers)

    # --- Codex (TOML) ---
    # Codex uses TOML; conversion is non-trivial. Either edit ~/.codex/config.toml
    # manually after updating mcp-servers.json, or pipe through a JSON->TOML tool.

    print("sync complete")


if __name__ == "__main__":
    main()
