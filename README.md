# dotfiles

Personal configuration for [Claude Code](https://claude.ai/code).

## What's here

```
claude/
├── CLAUDE.md                      # Global rules applied to every project
├── settings.json                  # Claude Code settings (plugins, hooks, effort level, status line)
├── tools/statusline.py            # Status line: model, effort, context %, 5h limit, folder, branch
├── workspace-efficiency-guide.md  # How to set up any workspace for low token usage
├── commands/                      # Slash command shortcuts (/brainstorm, /write-plan, etc.)
└── skills/                        # The user's own skills; third-party ones are reinstalled (see SKILLS.md)
```

## Install on a new machine

```bash
git clone https://github.com/AlexandreLab/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh && ./install-skills.sh
```

`install-skills.sh` installs gstack, skills from GitHub, the SEO skill and the Claude Code plugins.
[SKILLS.md](SKILLS.md) lists every skill and plugin with its source, and is written so an agent can
follow it on a fresh machine.

On a machine that already has the repo, pull and re-run both scripts. They skip what is already
in place, and they add anything new, such as skills added since the last install:

```bash
cd ~/dotfiles && git pull && ./install.sh && ./install-skills.sh
```

Then start a new Claude Code session so it picks up the changes.

`install.sh` creates symlinks from `~/.claude/` into this repo. Any edits made through
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

A new skill of your own also needs its name added to the allowlist in `.gitignore`
(`!claude/skills/<name>/`), or git ignores it. Third-party skills go in `install-skills.sh` instead.

## Sharing with a collaborator

The same install steps above work for anyone with read access to this repo. They get:

- Your global `CLAUDE.md` rules
- The own skills stored here, plus the third-party skills and plugins that `install-skills.sh` fetches
- The shared `agents-shared/` playbooks that apply across every AI agent

A launchd job (`com.alexandrecanet.dotfiles-sync.plist`) auto-commits and pushes config changes daily, so `main` is generally current, and collaborators can `git pull` to stay in sync.

## What's excluded

- Third-party skills (gstack, skills-CLI installs, the SEO skill, claude.ai synced skills): `.gitignore`
  allowlists own skills by name, and `install-skills.sh` reinstalls the rest
- `claude/cache/`, `sessions/`, `backups/` and other runtime state: ephemeral, machine-specific
- `claude/projects/`: session memory for individual projects (stays local)
