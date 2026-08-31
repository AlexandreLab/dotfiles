# Claude Instructions (Global)

See [`~/agents-shared/AGENTS.md`](../agents-shared/AGENTS.md) for canonical engineering rules — they apply to every project and every AI agent.

This file holds Claude-only extras that other tools can't honor.

## Skills to apply

- Before writing more than ~20 lines of code, consult `applying-engineering-standards`.
- Before any code review request, apply the 4-gate review framework from `applying-engineering-standards`.
- Before opening or approving a PR on files touching billing, auth, webhooks, or migrations, run `gstack-review`.
- When working with Stripe (payments, subscriptions, webhooks), consult `stripe-best-practices`.
- When starting a new project that will be worked on by multiple agents, run `multi-agent-setup`.

## Writing documents

- **Consistent level of detail across a document.** When a doc has repeated parallel items (e.g. emails
  in a flow spec, sections, table rows, API endpoints, list entries), give **every** item the **same
  structure and depth** — the same fields (subject, preheader, body, CTA, etc.) and the same completeness.
  Never fully spec some items and abbreviate others. If one item genuinely differs, spell out why; don't
  just leave it thinner. Do a consistency pass before finishing.

## Hooks for deterministic behaviour

- **If a required behaviour is deterministic, enforce it with a hook — never with a prose instruction.**
  Formatting on edit, branch/push guards, quality gates before push, banned commands (e.g. `pip` in a
  uv-only repo): these are mechanical predicates on a tool call or git event, and instructions agents
  "should remember" will eventually be missed. Prose is only for judgment calls (when/how/whether).
- Prefer, in order:
  1. **Git hooks** committed to the repo (`.githooks/` + `git config core.hooksPath .githooks`) — truly
     agent-agnostic: they fire for every AI agent and every human on `commit`/`push`.
  2. **Claude hooks** in `settings.json` (`PreToolUse` to block, `PostToolUse` to react) for things git
     can't see (tool-call commands, file edits as they happen).
- Keep the logic in **version-controlled shared scripts** (e.g. `tools/hooks/*.sh`); each agent's hook
  config is a one-line call to the script, so Gemini/Codex/Cursor adapters reuse the same enforcement.
- Give every blocking hook a clear error message telling the agent what to do instead, and a deliberate
  env-var escape hatch (e.g. `ALLOW_MASTER=1`).
- When reviewing a project's CLAUDE.md/AGENTS.md, flag rules that keep being restated or violated —
  they are hook candidates. Worked example: Loste_antigravity's `.githooks/` + `tools/hooks/`.

## Self-correction policy

- Anytime Claude does something incorrectly, add the lesson to the relevant project's CLAUDE.md so it knows not to repeat the mistake.
- After every correction from the user, end with: "Update your CLAUDE.md so you don't make that mistake again." — then actually do it.

## Subagent model IDs

The general ladder lives in `AGENTS.md`. Concrete Claude model IDs:

| Tier | Model ID |
|---|---|
| Cheapest (mechanical) | `claude-haiku-4-5-20251001` |
| Mid (integration / debugging) | `claude-sonnet-4-6` |
| Top (architecture / review) | `claude-opus-4-7` |
