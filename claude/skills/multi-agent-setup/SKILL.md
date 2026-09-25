---
name: multi-agent-setup
description: Use when setting up a project so several AI agents (Claude Code, Gemini CLI, Codex, Cursor, Copilot) share one AGENTS.md, thin per-tool adapters and git hooks. Triggers on "set up multi-agent" or "share rules across agents".
---

# Multi-Agent Setup

Give a project one source of truth for agent instructions, with thin per-tool adapters and hooks that enforce the mechanical rules for every agent.

The global layer already exists: `~/agents-shared/AGENTS.md` holds the rules for every project, `~/.claude/CLAUDE.md` imports it, `~/agents-shared/mcp-servers.json` plus `sync-mcp.sh` write each tool's global MCP config. This skill sets up a single project on top of that.

## Layers

1. **Portable:** `AGENTS.md`, `docs/playbooks/`. Every tool reads these, directly or through an adapter.
2. **Adapters:** `CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`. Each imports or points to `AGENTS.md` and adds only what that tool alone can use.
3. **Enforcement:** `.githooks/` plus `tools/hooks/*.sh`. Git hooks fire for every agent and every human, so deterministic rules live here rather than in prose.
4. **Tool-only:** Claude skills, `.claude/settings.json` hooks, slash commands. Not ported.

Codex and Cursor read `AGENTS.md` natively and need no adapter.

## Steps

Ask before overwriting any existing file, and show the diff when moving content.

### 1. Confirm scope

Tell the user which files you will create or change in the current directory, and which already exist.

### 2. Write AGENTS.md

Fill the template from the existing CLAUDE.md, README and build files. Leave out sections the project has nothing to say about rather than keeping empty placeholders.

```markdown
# AGENTS.md: <project name>

Canonical instructions for any AI coding agent in this repo. Tool-specific
files (CLAUDE.md, GEMINI.md) are thin adapters that defer to this one.
Global rules in ~/agents-shared/AGENTS.md also apply.

## Project context
- What this is: <one line>
- Stack: <languages, frameworks, package manager>
- Run and test: <dev server, test command, quality gate script>
- Production branch and deploy target: <e.g. main on Vercel, auto-deploys>

## Branch and PR discipline
- <branching strategy, PR-only flow>

## CI parity before push
Local checks mirror the CI matrix: same steps, same flags, same order.
Run <tools/quality_gate.sh> before pushing.

## Sub-agent scope
- Give each sub-agent an explicit list of files it may modify.
- Sub-agents leave TODOS.md, CLAUDE.md, AGENTS.md and CHANGELOG.md alone
  unless the task is about them.

## Locale and style
- <spelling variant, punctuation, voice: only what the project mandates>

## Playbooks
- docs/playbooks/<name>.md: <when to use it>

## Out of scope for agents
- <files or directories agents should not touch>
```

Worth checking even if the user didn't mention them: sub-agent scope, CI parity, and the grep-for-siblings rule. They prevent the most common rework loops. The project's history (repeated review comments, CI fixes that followed local passes) is the best source for project-specific rules.

### 3. Write the adapters

`CLAUDE.md`. The `@AGENTS.md` line must stand on its own line: Claude Code only loads a file into context through an `@` import, and a plain "see AGENTS.md" link is never read.

```markdown
# Claude Instructions

@AGENTS.md

## Claude-only extras
<skills, Claude Code hooks, slash commands: only what other tools can't use>
```

`GEMINI.md`. Gemini CLI also expands `@file` imports:

```markdown
# Gemini Instructions

@AGENTS.md
```

`.github/copilot-instructions.md`, only if the project uses Copilot: a one-line pointer to `AGENTS.md`.

### 4. Project MCP servers

Only if the project needs its own servers. Claude Code reads `.mcp.json` at the repo root. Gemini CLI does not: it reads `mcpServers` from `.gemini/settings.json`. Codex reads `[mcp_servers.*]` from `~/.codex/config.toml`. Keep one definition and generate the others, as `~/agents-shared/sync-mcp.sh` does globally, rather than hand-editing three files.

### 5. Migrate an existing CLAUDE.md

Move tool-agnostic rules into `AGENTS.md`, keep only Claude-specific items in `CLAUDE.md`, and put `@AGENTS.md` at the top. Show the diff and confirm; don't silently drop content.

### 6. Scaffold git hooks for deterministic rules

For each rule that is a mechanical check (quality gate before push, no commits to `main`, banned commands or package managers, formatting, secrets), add a hook instead of relying on agents to remember it:

- Hook entry points in `.githooks/` (`pre-commit`, `pre-push`), each a short call into `tools/hooks/<check>.sh` where the logic lives.
- Activate with `git config core.hooksPath .githooks`, and add that command to the README or setup script, since git config is not committed.
- Every blocking hook prints what to do instead, and honours an env-var escape hatch (for example `ALLOW_MAIN=1`), documented in `AGENTS.md`.
- For checks git can't see (tool calls, file edits as they happen), add a Claude Code hook in `.claude/settings.json` that calls the same script.

If the project already uses a hook manager (husky, lefthook, pre-commit), add the checks there instead of creating a second mechanism.

### 7. Report

List what was created or changed, the hooks now active, and what the user still needs to do: add project MCP servers if any, run `git config core.hooksPath .githooks` in other clones, and try each agent on a small task to confirm it picks up `AGENTS.md`.

## Pitfalls

- **A rule in two adapters** belongs in `AGENTS.md`.
- **Claude-only features in AGENTS.md** (skill names, slash commands) confuse other agents; keep them in `CLAUDE.md`.
- **A rule restated in several places, or often broken,** is a hook candidate.
- **A new filename** such as `SETUP.md`: other tools look for `AGENTS.md`, so use that.

