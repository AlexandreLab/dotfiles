# Skills and plugins: install guide

This file is written for an AI agent (or a person) setting up Claude Code on a new machine. It lists every skill and plugin this setup uses, where each one comes from, and how to install and check it. Follow the steps in order.

## How it fits together

- `~/.claude/skills` is a symlink to `claude/skills/` in this repo (made by `install.sh`).
- **Own skills** are stored in this repo as real folders under `claude/skills/`. They are not published anywhere else, so this repo is their only source. `.gitignore` allowlists them by name.
- **Everything else** in `claude/skills/` is git-ignored and reinstalled by `install-skills.sh`: gstack, skills from GitHub, the SEO skill from npm.
- **Plugins** (Supabase, Vercel, frontend-design and others) come from plugin marketplaces. `claude/settings.json` records which are enabled; `install-skills.sh` installs them.
- **claude.ai skills and plugins** (`anthropic-skills:*`, `engineering:*`, `marketing:*`, `product-management:*`) sync from the Anthropic account on login. Nothing to install; they land in `claude/skills/synced/` and `~/.claude/plugins/synced/`, both ignored.

## Install

Prerequisites: git, Node.js 22 or later (for `npx` and `npm`), Claude Code (`curl -fsSL https://claude.ai/install.sh | bash`), and a logged-in Claude account.

```bash
git clone https://github.com/AlexandreLab/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh          # symlinks ~/.claude/{CLAUDE.md,settings.json,skills,commands,tools/statusline.py} and ~/agents-shared
./install-skills.sh   # gstack, GitHub skills, SEO skill + MCP, plugins
```

Both scripts are safe to re-run. `install-skills.sh` ends by listing anything that failed; use the manual commands below for those.

## Check the result

Start a new Claude Code session in any folder and ask it to list its skills, or run:

```bash
ls ~/.claude/skills/*/SKILL.md | wc -l                  # own + third-party skills that resolve
find ~/.claude/skills/ -maxdepth 1 -type l ! -exec test -e {} \; -print   # broken links: should print nothing
claude plugin list
```

A skill folder without a `SKILL.md` at its top level is not loaded. A symlink that points nowhere is silently skipped, which is how `stripe-best-practices` went missing for months.

## Every skill, by source

### Own skills (stored in this repo)

| Skill | Use |
|---|---|
| applying-engineering-standards | Architecture and trade-off decisions; the 4-gate review |
| brain-ingest | Add a source document to a project's brain wiki |
| brainstorming | Shape a new user-facing feature or unclear requirements |
| brand-story-architect | Build or audit a B2C brand story |
| creating-devcontainer | Firewalled dev container for running an agent unattended |
| data-visualisation-expert | Question dashboard and KPI requirements before building |
| design-critic-loop | Iterate a UI with an isolated critic until it scores well |
| design-ideation | Bold visual directions before building a UI |
| design-subtract | Remove clutter and AI tells from a UI |
| multi-agent-setup | AGENTS.md plus per-tool adapters and git hooks for a new project |
| ponytail-review | Find over-engineering in a diff or a whole repo |
| receiving-code-review | Check review findings against the code before acting |
| subagent-driven-development | Run a written plan task by task through subagents |
| systematic-debugging | Find the root cause of a bug before fixing it |
| test-driven-development | Failing test first, then code |
| using-git-worktrees | Isolated branch work in `.worktrees/<branch>` |
| writing-plans | Turn an agreed spec into a task-by-task plan |

Seven of these (brainstorming, receiving-code-review, subagent-driven-development, systematic-debugging, test-driven-development, using-git-worktrees, writing-plans) are rewritten versions of skills from [obra/superpowers](https://github.com/obra/superpowers), MIT licence in `claude/skills/LICENSE-superpowers`. They are maintained here now, so do not reinstall the originals over them.

**Adding a new own skill:** create `claude/skills/<name>/SKILL.md`, then add `!claude/skills/<name>/` to `.gitignore`, or git will ignore it.

### gstack (GitHub: garrytan/gstack)

About 60 `gstack-*` skills (review, ship, QA, browser, design review, plan reviews and more) plus the `gstack` router.

```bash
git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git ~/.claude/skills/gstack
cd ~/.claude/skills/gstack && ./setup --prefix
```

`--prefix` gives the `gstack-` names that project CLAUDE.md files refer to (`gstack-review`, `gstack-ship`). Update with `/gstack-upgrade` or by pulling and re-running `./setup --prefix`. All gstack skills are kept, since setup recreates them on every update anyway.

### Skills from GitHub (skills CLI)

| Skill | Source | Manual install |
|---|---|---|
| herdr | herdrdev/herdr | `npx -y skills add herdrdev/herdr --skill herdr -g -a claude-code -y --copy` |
| stripe-best-practices | stripe/ai | `npx -y skills add stripe/ai --skill stripe-best-practices -g -a claude-code -y --copy` |
| next-best-practices | vercel-labs/next-skills | `npx -y skills add vercel-labs/next-skills --skill next-best-practices -g -a claude-code -y --copy` (gosip's CLAUDE.md names it) |

Always pass `--copy`. Without it the CLI writes a relative symlink from `~/.claude/skills`, but that folder is itself a symlink into this repo, so the link resolves to the wrong place and the skill never loads.

### SEO skill (npm package `seo`, not on GitHub)

```bash
npm i -g seo
seo skill install
seo mcp install --claude-code
```

The skill ships inside the CLI and updates with `npm i -g seo@latest` followed by `seo skill install`. Local edits to it are overwritten on update, so leave it as shipped.

### Plugins

| Plugin | Marketplace (add first) | What it gives |
|---|---|---|
| supabase@claude-plugins-official | anthropics/claude-plugins-official | `supabase:*` skills, including Postgres best practices, plus the Supabase MCP |
| vercel@claude-plugins-official | anthropics/claude-plugins-official | `vercel:*` skills (Next.js, AI SDK, functions, storage and more) |
| frontend-design@claude-plugins-official | anthropics/claude-plugins-official | `frontend-design` skill |
| claude-mem@thedotmack | thedotmack/claude-mem | Memory across sessions |
| watch@claude-video | bradautomates/claude-video | Watch a video by URL or path |
| typesafe@typesafe-ai | typesafe-ai/skills | `typesafe:typesafe-ai` skill |

```bash
claude plugin marketplace add anthropics/claude-plugins-official   # once per marketplace
claude plugin install supabase@claude-plugins-official             # once per plugin
```

`context7` and `vercel-plugin@vercel-vercel-plugin` are listed as disabled in `settings.json`; the second points at a local folder on the old machine, so ignore it.

### Installed but not loaded into Claude

`~/.agents/skills` on the old machine also holds skills that were never linked into Claude Code: `next-cache-components`, `playwright-best-practices`, `webapp-testing`, `vitest-best-practices`, `e2e-studio-tests`, and old unprefixed gstack copies (`review`, `ship`, `qa`, and others). The Vercel plugin covers the first. Install any of the others with the skills CLI (with `--copy`) only if a project needs it.

## Removed on purpose (September 2026)

Do not reinstall these; they were removed after a review:

- `engineering-*`, `marketing-*`, `product-management-*` copies: identical to the claude.ai plugins that sync on login.
- `using-superpowers`, `verification-before-completion`, `writing-skills`, `requesting-code-review`, `executing-plans`, `dispatching-parallel-agents`, `finishing-a-development-branch`: covered by Claude Code itself (skill routing, `/code-review`, the Agent tool, worktree isolation) or broken.
- `ponytail-audit`: merged into `ponytail-review`.
- The `brainstorm`, `write-plan`, `execute-plan` and `marketing-*` commands.
