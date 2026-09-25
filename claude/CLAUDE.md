# Claude Instructions (Global)

The rules every AI agent follows live in `~/agents-shared/AGENTS.md`, imported here so they load in every session:

@~/agents-shared/AGENTS.md

This file adds what only Claude Code can act on. Where the two disagree, the more specific rule wins: a project's CLAUDE.md or AGENTS.md over this file, this file over the shared one.

## When to load a skill

Load a skill when the task in front of you matches it, not on the chance that it might. Each skill costs context on every later turn, so don't chain skills into each other unless the task needs each step.

- Changes that touch billing, auth, webhooks or database migrations: run `gstack-review` before opening or approving the PR. These are the areas where a missed bug costs money or data.
- Stripe work (payments, subscriptions, webhooks): read `stripe-best-practices` first.
- Architecture or trade-off decisions, and when the user asks for a 4-gate review: use `applying-engineering-standards`.
- A new project that several agents will work on: run `multi-agent-setup`.

## Writing documents

When a document has repeated parallel items (emails in a flow, sections, table rows, API endpoints), give every item the same structure and depth: the same fields and the same completeness. Readers compare items side by side, and a thinner one reads as unfinished. If one item genuinely differs, say why. Do a consistency pass before finishing.

Follow the em dash rule in AGENTS.md in everything you write, including messages to the user.

## Hooks, not reminders

If a required behaviour is mechanical (formatting on edit, branch and push guards, the quality gate before push, banned commands such as `pip` in a uv-only repo), enforce it with a hook rather than a written instruction. Instructions an agent has to remember eventually get missed; a hook fires every time. Written rules are for judgment calls.

- Prefer git hooks committed to the repo (`.githooks/` plus `git config core.hooksPath .githooks`). They fire for every agent and every human.
- Use Claude Code hooks in `settings.json` (`PreToolUse` to block, `PostToolUse` to react) for what git can't see, such as tool calls and file edits.
- Keep the logic in shared scripts under version control (for example `tools/hooks/*.sh`), so each agent's hook config is a one-line call and other agents reuse the same check.
- Give every blocking hook an error message that says what to do instead, and an env-var escape hatch (for example `ALLOW_MASTER=1`).
- When reviewing a project's CLAUDE.md or AGENTS.md, point out rules that keep being restated or broken: they are candidates for a hook. Loste_antigravity's `.githooks/` and `tools/hooks/` are a worked example.

## Learning from corrections

When the user corrects something you did wrong, add a short lesson to that project's CLAUDE.md in the same turn, and tell the user in one line what you added. This is standing permission, and an exception to the AGENTS.md rule against editing CLAUDE.md unasked. Write the lesson as a rule with its reason, next to related rules, and update an existing entry rather than adding a near-duplicate. Lessons that apply to every project go in this file instead.

## Keeping cost down

Every message re-sends the whole conversation, and in measured sessions 82% of spend was re-sent context rather than new work. What enters the context is paid for again on every later turn.

- Be concise. Skip preamble, recaps and options you won't take. Answer, then stop.
- Hand mechanical work to a subagent on the cheapest model: renames, reformatting, summarising or extracting from a file, bulk find-and-replace, boilerplate, log triage. Keep only its conclusion. If you need one fact from a large file, delegate the reading instead of loading the file.
- Don't read a file again if you already have it in context and it hasn't changed since. Don't re-run a check that passed until the code changes.
- Put independent tool calls in one message; each round trip re-sends everything.
- Don't suggest `/compact` to save money. When context is full, suggest `/clear` and a fresh session, with a short handoff note if the work continues.

## Which model a subagent uses

AGENTS.md sets the ladder. In Claude Code, pass the alias as the Agent tool's `model`, so the table stays current as new versions ship:

| Task | Alias |
|---|---|
| Mechanical: clear spec, one or two files | `haiku` |
| Integration and debugging across several files | `sonnet` |
| Architecture, design decisions, review | `opus` |
