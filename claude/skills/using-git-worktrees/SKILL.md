---
name: using-git-worktrees
description: Use when starting isolated feature work or a parallel session on its own branch, so it runs in a separate git worktree with dependencies installed and a known test baseline.
---

# Using Git Worktrees

A worktree is a second checkout of the same repository on its own branch, so two pieces of work can proceed without switching branches or overwriting each other.

## Pick the right tool

- **A subagent's task:** give the Agent tool `isolation: "worktree"`. Claude Code creates and cleans up the checkout for you.
- **This session, temporary:** use EnterWorktree, and ExitWorktree when done.
- **A persistent worktree under the project's convention** (the user wants to come back to it, or run another session in it): create it by hand as below.

## Where it goes

1. Use `.worktrees/<branch>` if `.worktrees/` exists, else `worktrees/<branch>` if that exists. If both exist, `.worktrees/` wins.
2. If neither exists, check the project's CLAUDE.md or AGENTS.md for a stated location. If there is none, ask the user.
3. Confirm the directory is git-ignored, so worktree contents never get committed to the main checkout:
   ```bash
   git check-ignore -q .worktrees || echo "not ignored"
   ```
   If it is not ignored, add it to `.gitignore` and tell the user, rather than silently committing that change.

## Create it

Branch from the default branch, detected rather than assumed:

```bash
base=$(git symbolic-ref --short refs/remotes/origin/HEAD | sed 's@^origin/@@')
git fetch origin "$base"
git worktree add ".worktrees/<branch>" -b "<branch>" "origin/$base"
cd ".worktrees/<branch>"
```

If `origin/HEAD` is unset, `git remote set-head origin --auto` fixes it. If the user named a different base branch, use that.

## Set it up

Install dependencies from what the project uses, detected from its lockfiles:

| Found | Run |
|---|---|
| `bun.lock` / `bun.lockb` | `bun install` |
| `package-lock.json` | `npm ci` |
| `pyproject.toml` / `uv.lock` | `uv sync` |
| `Cargo.toml` | `cargo build` |
| `go.mod` | `go mod download` |

Python always goes through `uv`, never pip or poetry. If the project uses a package manager that isn't installed, report it as a blocker.

Then run the project's test suite once. If anything fails, report the failures to the user before starting work, so pre-existing breakage isn't later mistaken for something the new work caused. Ask whether to proceed.

Finish by reporting the worktree path, branch, base, and baseline test result.

## Shared state

Untracked files such as `.env` are not copied into a new worktree; copy or symlink them if the task needs them. Anything reached by path from the main checkout (a local SQLite database, generated artefacts at the repo root) is shared by every worktree, so two sessions writing it will collide. Say so if the task touches them.

## Cleanup

After the branch is merged:

```bash
git worktree remove .worktrees/<branch>
git branch -D <branch>   # -D because a squash merge leaves the branch looking unmerged
```

`git worktree prune` clears entries for worktrees whose directories were deleted by hand.

Adapted from obra/superpowers (MIT).
