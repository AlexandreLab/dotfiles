# Claude Instructions (Global)

See [`~/agents-shared/AGENTS.md`](../agents-shared/AGENTS.md) for canonical engineering rules — they apply to every project and every AI agent.

This file holds Claude-only extras that other tools can't honor.

## Skills to apply

- Before writing more than ~20 lines of code, consult `applying-engineering-standards`.
- Before any code review request, apply the 4-gate review framework from `applying-engineering-standards`.
- Before opening or approving a PR on files touching billing, auth, webhooks, or migrations, run `gstack-review`.
- When working with Stripe (payments, subscriptions, webhooks), consult `stripe-best-practices`.
- When starting a new project that will be worked on by multiple agents, run `multi-agent-setup`.

## Subagent model IDs

The general ladder lives in `AGENTS.md`. Concrete Claude model IDs:

| Tier | Model ID |
|---|---|
| Cheapest (mechanical) | `claude-haiku-4-5-20251001` |
| Mid (integration / debugging) | `claude-sonnet-4-6` |
| Top (architecture / review) | `claude-opus-4-7` |
