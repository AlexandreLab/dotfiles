# dotfiles

Personal configuration for [Claude Code](https://claude.ai/code).

## What's here

```
claude/
├── CLAUDE.md                      # Global rules applied to every project
├── settings.json                  # Claude Code settings (plugins, hooks, effort level)
├── workspace-efficiency-guide.md  # How to set up any workspace for low token usage
├── commands/                      # Slash command shortcuts (/brainstorm, /write-plan, etc.)
└── skills/                        # Reusable skill prompts (gstack/ and ostack/ excluded — too large)
```

## Install on a new machine

```bash
git clone https://github.com/AlexandreLab/dotfiles.git ~/dotfiles
cd ~/dotfiles && chmod +x install.sh && ./install.sh
```

The script creates symlinks from `~/.claude/` into this repo. Any edits made through
Claude Code (new skills, CLAUDE.md updates) automatically appear as changes here.

## Keeping it up to date

After Claude Code installs a new skill or you edit CLAUDE.md:

```bash
cd ~/dotfiles
git status          # see what changed
git add -A
git commit -m "chore: sync claude config"
git push
```

## Sharing with a collaborator

The same install steps above work for anyone with read access to this repo. They get:

- Your global `CLAUDE.md` rules
- All slash commands and skills (except the heavy gstack/ostack bundles)
- The shared `agents-shared/` playbooks that apply across every AI agent

A launchd job (`com.alexandrecanet.dotfiles-sync.plist`) auto-commits and pushes config changes daily, so `main` is generally current — collaborators can `git pull` to stay in sync.

## What's excluded

- `claude/skills/gstack/` and `claude/skills/ostack/` — 600MB+ embedded codebases, not suitable for git
- `claude/cache/`, `sessions/`, `backups/` and other runtime state — ephemeral, machine-specific
- `claude/projects/` — session memory for individual projects (stays local)
