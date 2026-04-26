---
name: multi-agent-setup
description: Use when starting a new project (or onboarding an existing one) that will be worked on by multiple AI agents — Claude Code, Gemini CLI, Codex, GitHub Copilot, Cursor, etc. — and you want them to share the same instructions, MCP servers, and playbooks. Scaffolds the canonical AGENTS.md + thin per-tool adapter files so every agent reads from one source of truth. Trigger on phrases like "set up multi-agent", "share rules across agents", "configure for Claude and Gemini", or when the user asks to add AGENTS.md / GEMINI.md / Codex config to a project.
---

# Multi-Agent Setup

> Establish a single source of truth for instructions, MCP servers, and playbooks across every AI coding tool the user runs.

---

## 0. Mental Model

Three layers, ordered by portability:

1. **Portable layer** (shared across all tools): `AGENTS.md`, `.mcp.json`, `docs/playbooks/`
2. **Adapter layer** (per-tool, thin): `CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md` — each is a one-liner pointing to `AGENTS.md` plus tool-specific extras only.
3. **Tool-only layer** (no portability): Claude `~/.claude/skills/`, hooks, slash commands. Don't try to port.

Edit the portable layer once → all agents pick it up. Adapter files exist only because some tools won't read `AGENTS.md` directly.

---

## 1. Global Layout (user's machine, all projects)

```
~/agents-shared/
  AGENTS.md              # canonical engineering rules (was ~/.claude/CLAUDE.md)
  mcp-servers.json       # canonical MCP server definitions
  playbooks/             # skill content extracted to plain markdown
  sync-mcp.sh            # regenerates per-tool MCP configs from mcp-servers.json

~/.claude/CLAUDE.md      # one-liner: "See ~/agents-shared/AGENTS.md" + Claude-only bits
~/.gemini/GEMINI.md      # symlink or @include of ~/agents-shared/AGENTS.md
~/.codex/AGENTS.md       # symlink to ~/agents-shared/AGENTS.md
```

**MCP configs** (each tool has its own format — `sync-mcp.sh` writes them all):
- `~/.claude.json` (Claude Code)
- `~/.gemini/settings.json` → `mcpServers`
- `~/.codex/config.toml` → MCP section

---

## 2. Per-Project Layout

```
<project>/
  AGENTS.md              # canonical project rules — voice, conventions, architecture
  CLAUDE.md              # one-liner pointing to AGENTS.md + Claude-only extras
  GEMINI.md              # one-liner pointing to AGENTS.md
  .mcp.json              # project-scoped MCP servers (Claude + Gemini both read this)
  docs/playbooks/        # project-specific playbooks referenced from AGENTS.md
```

Tool-specific files (`.claude/settings.json`, hooks, skills) stay alongside but are never required reading for non-Claude agents.

---

## 3. Scaffolding Protocol

When invoked, run these steps in order. **Ask before overwriting any existing file.**

### Step 1 — Confirm scope
Ask: "Set up multi-agent layout in `<cwd>`? I'll create `AGENTS.md`, thin `CLAUDE.md` / `GEMINI.md`, and `.mcp.json`. Existing files will be flagged before changes."

### Step 2 — Create `AGENTS.md`
Use this template. Fill in placeholders from the project's existing CLAUDE.md / README.md if present.

```markdown
# AGENTS.md — <project name>

> Canonical instructions for any AI coding agent working in this repo.
> Tool-specific files (CLAUDE.md, GEMINI.md, etc.) are thin adapters that defer to this file.

## Project context
- **What this is:** <one-line description>
- **Stack:** <languages, frameworks, package manager>
- **Run/test:** <how to start the dev server, run tests>

## Engineering rules
- Inherit global rules from `~/agents-shared/AGENTS.md`.
- <project-specific overrides go here>

## Voice & conventions
- See `docs/brand.md` / `.agent/conventions.md` if applicable.

## Playbooks
- `docs/playbooks/<name>.md` — <when to use it>

## Out of scope for agents
- <files or directories agents should never touch>
```

### Step 3 — Create thin adapter files

`CLAUDE.md`:
```markdown
# Claude Instructions

See [AGENTS.md](AGENTS.md) for canonical rules.

## Claude-only extras
<skills to use, slash commands, hooks notes — only what other tools can't honor>
```

`GEMINI.md`:
```markdown
# Gemini Instructions

See [AGENTS.md](AGENTS.md) for canonical rules.
```

`.github/copilot-instructions.md` (only if the project uses Copilot):
```markdown
See [AGENTS.md](../AGENTS.md) for canonical rules.
```

### Step 4 — Create `.mcp.json`
Start with an empty servers list. Populate from `~/agents-shared/mcp-servers.json` if the user wants project-scoped copies.

```json
{
  "mcpServers": {}
}
```

### Step 5 — Migration from existing CLAUDE.md
If `CLAUDE.md` already has substantive content:
1. Move tool-agnostic rules → `AGENTS.md`.
2. Keep only Claude-specific items (skill list, hooks, slash command notes) in `CLAUDE.md`.
3. Replace the body with: "See [AGENTS.md](AGENTS.md)" + the Claude-only section.

Never silently delete content — show the diff and confirm.

### Step 6 — Report
List what was created/changed and what the user should do next:
- Add MCP servers to `.mcp.json` if needed.
- If using Codex/Cursor, drop equivalent adapter files.
- Verify `AGENTS.md` reads correctly by running each agent against a small task.

---

## 4. Anti-Patterns

- **Duplicating rules across CLAUDE.md and GEMINI.md.** If a rule is in two adapter files, it belongs in `AGENTS.md`.
- **Putting Claude-only features in `AGENTS.md`.** Slash commands, hooks, skill names — these confuse non-Claude agents. Keep them in `CLAUDE.md` only.
- **Hand-editing per-tool MCP configs.** Always edit `mcp-servers.json` and re-run the sync script.
- **Creating a SETUP.md instead of AGENTS.md.** `AGENTS.md` is the convention non-Claude tools already look for. Don't invent a new filename.

---

## 5. Quick Reference

| Need | File |
|---|---|
| Engineering rules every agent must follow | `AGENTS.md` |
| Claude-only behavior (skills, hooks) | `CLAUDE.md` |
| Gemini-only tweaks | `GEMINI.md` |
| Shared MCP servers across projects | `~/agents-shared/mcp-servers.json` |
| Project-scoped MCP servers | `.mcp.json` |
| Reusable playbooks referenced from AGENTS.md | `docs/playbooks/<name>.md` |
