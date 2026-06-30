# AGENTS.md — Global Engineering Rules

> Canonical instructions for any AI coding agent (Claude Code, Gemini CLI, Codex, GitHub Copilot, Cursor, etc.).
> Tool-specific files (`~/.claude/CLAUDE.md`, `~/.gemini/GEMINI.md`, `~/.codex/AGENTS.md`) are thin adapters that defer to this file.

---

## Pre-merge checklist

Before opening or approving a PR on any project, run a paranoid staff-engineer review on any files changed in high-risk areas: billing, auth, webhooks, database migrations.

**Run the project's quality gate before every push.** If a `tools/quality_gate.sh` exists, run it and fix all failures before committing. This mirrors CI locally and eliminates round-trip failures. Never push code that you know will fail the quality gate.

---

## Fix discipline

**Grep for siblings before declaring a fix done.** After fixing any bug, search the entire codebase for the same pattern and fix ALL instances in one commit. A single-instance fix that misses a sibling is an incomplete fix. Applies to: assertion strings, env var names, display transformations, copy strings, and API method calls.

**Never poll CI in-chat.** Do not loop on `gh pr checks` or `gh run watch` interactively — it drains quota and hits rate limits.

**Auto-merge is mandatory when creating PRs.** After every `gh pr create`, immediately run `gh pr merge <number> --auto --squash` in the same step — never as a follow-up. The full sequence is always:
```bash
gh pr create --title "..." --body "..."  # capture the PR number from output
gh pr merge <number> --auto --squash      # set auto-merge immediately
```
GitHub then merges when checks pass — no further monitoring needed.

---

## Multi-terminal / parallel feature work

Each agent session must work on its own branch inside its own **git worktree** — never two sessions on the same branch simultaneously.

Use the `using-git-worktrees` skill when creating a worktree. It handles directory selection, `.gitignore` safety, dependency setup, and baseline test verification automatically. Key conventions:

**Directory priority (project-local):**
```
.worktrees/<branch>   ← preferred (hidden, ignored)
worktrees/<branch>    ← fallback
```
If neither exists and no preference is in CLAUDE.md/AGENTS.md, ask the user before creating.

**Creating a worktree:**
```bash
# Verify the directory is git-ignored before using it
git check-ignore -q .worktrees
git worktree add .worktrees/<branch> -b <branch> master
cd .worktrees/<branch>
# install deps, then run baseline tests
```

If the user starts a session without specifying a branch, **ask which branch to use before touching any files.**

**Cleanup** when the branch is merged:
```bash
git worktree remove .worktrees/<branch>
```

Shared files (`.env`, local SQLite DBs, generated artefacts at the repo root) are visible across all worktrees — avoid concurrent writes to them from separate sessions.

---

## Python tooling

**Always use `uv` for Python work.** Never call `pip`, `pip3`, `python -m pip`, or `virtualenv` directly.

| Action | Command |
|---|---|
| Run a script or app | `uv run <script>` |
| Run tests | `uv run pytest ...` |
| Add a dependency | `uv add <package>` |
| Add a dev dependency | `uv add --dev <package>` |
| Sync the environment | `uv sync` |

If `uv` is not installed in the environment, surface that as a blocker rather than silently falling back to pip.

---

## Scope discipline

**Never touch `TODOS.md`, `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `CHANGELOG.md`, or other project-management files unless explicitly asked.** Keep commits scoped to the task at hand. If you notice something worth logging, mention it in chat — don't write it yourself.

**Verify branch before every commit.** Run `git branch --show-current` before committing. If on the wrong branch, stop and ask rather than committing and cherry-picking later.

**Run the full test suite before creating a PR.** When fixing copy or UI text, also check that test locators and assertions still match the updated strings. A passing local suite catches issues before CI does.

---

## Engineering posture

- **Be deliberate.** Do not rush. Speed that introduces debt or ambiguity is not speed.
- **Verify everything.** Use inspection, documentation, logs, and reproducible tests. Never assume.
- **Prefer explicit over clever.** Code should be obvious to a reader unfamiliar with its history.
- **Fail loudly.** When multiple valid interpretations exist, surface the ambiguity and ask — do not silently pick one.

Priority order when principles conflict: **Maintainability > Security > Reliability > Performance.**

---

## Subagent / sub-task model selection

When dispatching subagents or sub-tasks, choose model by task complexity:

| Task type | Model |
|---|---|
| Mechanical: isolated function, clear spec, 1–2 files | cheapest tier (Haiku / Flash) |
| Integration: multi-file coordination, pattern matching, debugging | mid tier (Sonnet / Pro) |
| Architecture, design decisions, review | top tier (Opus / Ultra) |

When in doubt: if the plan is fully specified and the task touches ≤2 files → cheapest. Multi-file judgment → mid. Review or ADR → top.

---

## Writing style (prose & content)

Applies to all human-facing prose the agent writes: blog posts, social media posts, marketing copy, emails, newsletters, documentation, and READMEs. Not code identifiers.

- **Never use em dashes (—).** They are a common AI-writing tell. Instead use one of:
  - a spaced en dash ( – ) for a parenthetical aside;
  - a comma, colon, or full stop where the sentence allows;
  - parentheses or brackets for a genuine aside.
- Do not substitute a double hyphen (`--`) or an unspaced hyphen for an em dash either — rewrite the sentence.
- Project-specific style guides (e.g. a repo's `DESIGN.md` or brand voice doc) may add stricter punctuation rules, but must never re-permit the em dash.
