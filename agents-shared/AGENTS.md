# AGENTS.md: Global Engineering Rules

> Canonical instructions for any AI coding agent (Claude Code, Gemini CLI, Codex, GitHub Copilot, Cursor, etc.).
> Tool-specific files (`~/.claude/CLAUDE.md`, `~/.gemini/GEMINI.md`, `~/.codex/AGENTS.md`) are thin adapters that import this file (Claude: `@~/agents-shared/AGENTS.md`).

---

## Pre-merge checklist

Before opening or approving a PR on any project, run a paranoid staff-engineer review on any files changed in high-risk areas: billing, auth, webhooks, database migrations.

**Run the project's quality gate before every push.** If a `tools/quality_gate.sh` exists, run it and fix all failures before committing. This mirrors CI locally and eliminates round-trip failures. Never push code that you know will fail the quality gate.

---

## Fix discipline

**Grep for siblings before declaring a fix done.** After fixing any bug, search the entire codebase for the same pattern and fix ALL instances in one commit. A single-instance fix that misses a sibling is an incomplete fix. Applies to: assertion strings, env var names, display transformations, copy strings, and API method calls.

**Never poll CI in-chat.** Do not loop on `gh pr checks` or `gh run watch` interactively: it drains quota and hits rate limits.

**Auto-merge is mandatory when creating PRs.** After every `gh pr create`, immediately run `gh pr merge <number> --auto --squash` in the same step, not as a follow-up. The full sequence is always:
```bash
gh pr create --title "..." --body "..."  # capture the PR number from output
gh pr merge <number> --auto --squash      # set auto-merge immediately
```
GitHub then merges when checks pass, so no further monitoring is needed.

---

## Multi-terminal / parallel feature work

Each agent session must work on its own branch inside its own **git worktree**, never two sessions on the same branch at once.

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
git worktree add .worktrees/<branch> -b <branch> main   # or the repo's default branch
cd .worktrees/<branch>
# install deps, then run baseline tests
```

Before the first edit, check the current branch. If it is the default branch (`main`), create a feature branch named after the task rather than editing there; ask only if the task doesn't suggest a sensible name or another session may already own that work.

**Cleanup** when the branch is merged:
```bash
git worktree remove .worktrees/<branch>
```

Shared files (`.env`, local SQLite DBs, generated artefacts at the repo root) are visible across all worktrees, so avoid concurrent writes to them from separate sessions.

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

**Never touch `TODOS.md`, `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `CHANGELOG.md`, or other project-management files unless explicitly asked.** A project's own `AGENTS.md` or `CLAUDE.md` counts as asking: if it says to log meaningful work in `CHANGELOG.md` (or keep another such file current), do it in the same PR as the work rather than offering it afterwards. Otherwise keep commits scoped to the task at hand, and if you notice something worth logging, mention it in chat rather than writing it yourself.

**Verify branch before every commit.** Run `git branch --show-current` before committing. If on the wrong branch, stop and ask rather than committing and cherry-picking later.

**Run the full test suite before creating a PR.** When fixing copy or UI text, also check that test locators and assertions still match the updated strings. A passing local suite catches issues before CI does.

---

## Engineering posture

- **Be deliberate.** Do not rush. Speed that introduces debt or ambiguity is not speed.
- **Verify everything.** Use inspection, documentation, logs, and reproducible tests. Never assume.
- **Prefer explicit over clever.** Code should be obvious to a reader unfamiliar with its history.
- **Fail loudly.** When valid interpretations would lead to materially different results, surface the ambiguity and ask rather than silently picking one. When the choice is minor or easy to undo, pick the sensible default and say which one you picked.

Priority order when principles conflict: **Maintainability > Security > Reliability > Performance.**

---

## Parallel agents, model and effort

### Model and effort by task

Pick both the model and the reasoning effort from the task, for in-process subagents and for agents started in herdr panes alike:

| Task type | Model | Effort |
|---|---|---|
| Mechanical: isolated function, clear spec, 1–2 files, renames, log triage | cheapest tier (Haiku / Flash) | low |
| Integration: multi-file coordination, pattern matching, debugging | mid tier (Sonnet / Pro) | medium |
| Architecture, design decisions, review, ADRs | top tier (Opus / Ultra) | high |
| Security, billing, auth or migration review; a bug two attempts have not found | top tier | xhigh or max |

When in doubt: if the plan is fully specified and the task touches ≤2 files → cheapest. Multi-file judgment → mid. Review or ADR → top. Raise the effort rather than the tier when the task is small but subtle; lower it when the model is right but the work is rote.

How each CLI takes them (pass native flags after `--` in `herdr agent start`):

| Agent | Model | Effort |
|---|---|---|
| Claude Code | `--model haiku\|sonnet\|opus` | `--effort low\|medium\|high\|xhigh\|max` |
| Codex | `-m <model>` | `-c model_reasoning_effort="low\|medium\|high"` |
| Gemini CLI | `-m <model>` | no flag; choose by model |

### When to parallelise

Split work across agents when the pieces are independent: no shared files, and no step that needs another's output. Good candidates: separate work packages of a written plan, a review running beside implementation, a long test or build run, research across unrelated areas. Do not split a task whose parts edit the same files, or one small enough that briefing an agent costs more than doing it.

- **In-process subagent** (the Agent tool, or your CLI's equivalent) for short, self-contained work whose result you only need as a conclusion: searches, extraction, a focused review.
- **herdr pane** (load the `herdr` skill) for work that is long-running, needs its own branch, should be visible to the user, or suits a different agent kind (for example a Codex reviewer beside a Claude implementer). This standing rule is the user's go-ahead to use herdr for this; it only applies when `HERDR_ENV=1`.

### Running agents in herdr

- One agent, one branch, one worktree (see Multi-terminal above). An agent that only reads can share the caller's directory; one that edits gets its own worktree under `.worktrees/<branch>`.
- Open a sibling pane with `--no-focus`, start the agent with a short unique name (`impl-auth`, `reviewer`), and set model and effort from the table above.
- Give each agent a self-contained prompt: the goal, an explicit allowlist of files it may change, the checks to run before it reports, and what to return. It has none of your conversation.
- Wait with `herdr agent prompt ... --wait` or `herdr agent wait`, then read its output. If it is `blocked` on an approval, read the dialog and ask the user; never answer it blindly.
- Keep ownership clear: the primary session merges results, runs the quality gate and commits, unless a lane was given its own branch and PR.
- Close only the panes and worktrees you created, once their work is merged or discarded.

---

## Spotting a use for Jev (TypeSafe)

Jev, TypeSafe's System One model, turns text and application state into typed answers with probabilities. The user wants to hear when a step in an algorithm or method being designed could use it, so raise it as a question rather than staying silent or wiring it in.

**Ask when a step needs judgement that code can't express cleanly**, such as:
- classifying or labelling free text with keyword lists, regexes or hand-written heuristics;
- choosing the right value, span or candidate from several that code has already found;
- ranking or filtering by relevance, or deciding whether a piece of evidence supports a claim;
- a threshold or rule tuned by eye because the real criterion is semantic;
- an LLM prompt-and-parse call whose output is really a choice, a yes/no or a score.

**Don't ask** about exact rules, calculations, lookups or anything a test can pin down exactly: those stay in code.

**How to ask:** at the design point, before the code is written, put one question to the user (in Claude Code, the AskUserQuestion tool). Name the step, the question Jev would answer, what stays in code, and the trade-off: cost and latency per call, a probability to set a threshold on, and a dependency on the TypeSafe API. Offer three answers: explore it now (load the `typesafe-ai` skill and read the live docs), keep it in code, or note it for later. Don't wire Jev in without a yes, and don't ask again about a step the user has already declined this session.

---

## Writing style (prose & content)

Applies to all human-facing prose the agent writes: blog posts, social media posts, marketing copy, emails, newsletters, documentation, and READMEs. Not code identifiers.

- **Never use em dashes (—).** They are a common AI-writing tell. Instead use one of:
  - a spaced en dash ( – ) for a parenthetical aside;
  - a comma, colon, or full stop where the sentence allows;
  - parentheses or brackets for a genuine aside.
- Do not substitute a double hyphen (`--`) or an unspaced hyphen for an em dash either: rewrite the sentence.
- Project-specific style guides (e.g. a repo's `DESIGN.md` or brand voice doc) may add stricter punctuation rules, but must never re-permit the em dash.
