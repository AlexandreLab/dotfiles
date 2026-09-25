---
name: creating-devcontainer
description: Use when the user wants a firewalled dev container (.devcontainer/) so an AI agent can run unattended with permission prompts turned off, or wants to update an existing one.
---

# Creating a dev container for AI agents

A dev container runs the project inside Docker with a default-deny outbound firewall and a short allowlist of domains. Inside it, an agent can run with permission prompts off (`--dangerously-skip-permissions` or its equivalent), because what it can reach and damage is bounded by the container. The setup works for Claude Code, Codex, Gemini CLI, Aider or any other CLI agent.

**Lighter option first.** Claude Code has a built-in sandbox mode (`/sandbox`) that isolates the filesystem and network with OS-level primitives, without Docker. If the user only needs fewer permission prompts for Claude Code on their own machine, suggest that before building a container. A container is worth it for other agents, identical team environments, CI, or keeping one client's credentials away from another's.

**Upstream reference.** Anthropic maintains a reference devcontainer at https://github.com/anthropics/claude-code/tree/main/.devcontainer. The templates here follow it; compare against it when creating or updating a container, especially the firewall's domain list, which changes as Claude Code does.

## Prerequisites

- Docker Desktop (macOS, Windows) or Docker Engine (Linux).
- Something that reads `devcontainer.json`: VS Code with the Dev Containers extension, the [devcontainer CLI](https://github.com/devcontainers/cli) (`npm install -g @devcontainers/cli`), GitHub Codespaces, or Cursor.

## Files

Copy the three files in `templates/` into `.devcontainer/` at the repo root:

- `devcontainer.json`: container settings, extensions, volumes.
- `Dockerfile`: the image, with the agent CLIs.
- `init-firewall.sh`: iptables rules applied at container start.

**devcontainer.json.** Keep these settings, because the firewall depends on them:

- `runArgs` with `--cap-add=NET_ADMIN` and `--cap-add=NET_RAW`, which iptables needs.
- `postStartCommand: sudo /usr/local/bin/init-firewall.sh`, so the firewall is up on every start.
- `waitFor: postStartCommand`, so the editor does not attach before the firewall is in place.
- Named volumes for shell history and `~/.claude`, so agent config survives rebuilds.
- `DISABLE_AUTOUPDATER=1`: the firewall blocks Claude Code's self-updates, so update it by rebuilding the image instead.

**Dockerfile.** Base image `node:24` (current Node LTS), system tools including the firewall packages, the firewall script with a sudo rule for that script only, then the agent CLIs. Claude Code uses its native installer (`curl -fsSL https://claude.ai/install.sh | bash`); Codex (`@openai/codex`), Gemini CLI (`@google/gemini-cli`) and Aider (via `uv tool install aider-chat`) are commented out. For a Python project, add uv to this image rather than switching the base, so the Node-based agents keep working.

**init-firewall.sh.** Default deny with an explicit allowlist: it flushes existing rules, keeps Docker's DNS, allows DNS, SSH, localhost and the host network, loads GitHub's published IP ranges plus the resolved IPs of `ALLOWED_DOMAINS` into an ipset, sets every policy to DROP, then checks that `example.com` is blocked and `api.github.com` is reachable. The default list is npm, the Anthropic API, and the telemetry hosts in Anthropic's reference firewall (`sentry.io`, `statsig.com`; check upstream for the current set). Add each API the project or another agent calls; check each agent's docs for the hosts it needs, since they differ by auth method.

## Opening the container

- VS Code: open the repo and choose "Reopen in Container".
- CLI: `devcontainer up --workspace-folder .` then `devcontainer exec --workspace-folder . zsh`.
- Codespaces: push `.devcontainer/`; it is picked up automatically.

## Running the agent without prompts

```bash
claude --dangerously-skip-permissions
claude --dangerously-skip-permissions -p "run the test suite and fix all failures"   # non-interactive
codex --full-auto
aider --yes-always
```

## Customising

- Add the project's language runtime to the Dockerfile.
- Extend `ALLOWED_DOMAINS` for every external API and package registry the project uses.
- Add editor extensions under `customizations.vscode.extensions`.
- Pass secrets at run time through `containerEnv` or an env file, not in the image, because image layers keep them.
- For a team, pre-build the image in CI with `devcontainer build` to speed up onboarding.

## What it protects against, and what it does not

It limits arbitrary outbound requests (exfiltration to unknown hosts) and keeps the agent away from the host's config directories. It does not protect secrets passed into the container, since the agent process can read them; it does not stop exfiltration through allowlisted services such as GitHub; and it does not prevent damage inside the workspace, which is bind-mounted from the host. Use prompt-free mode only on repositories you trust.

## Common problems

| Problem | Fix |
|---|---|
| `init-firewall.sh` fails at start | `runArgs` is missing `NET_ADMIN` or `NET_RAW`. |
| The agent cannot reach npm, PyPI or an API | Add the domain to `ALLOWED_DOMAINS` and rebuild or restart. |
| A domain's IPs change and requests start failing | The ipset holds IPs resolved at start; restart the container to re-resolve. |
| Agent config lost on rebuild | Use named volumes, not bind mounts, for `~/.claude` and similar. |
| Secrets visible in `docker history` | They were baked into a layer; pass them at run time instead. |
