# Global Engineering Habits

## Skills to apply

- Before writing more than ~20 lines of code, consult `applying-engineering-standards`
- Before any code review request, apply the 4-gate review framework from `applying-engineering-standards`
- When working with Stripe (payments, subscriptions, webhooks), consult `stripe-best-practices`

## Pre-merge checklist
Before opening or approving a PR on any project, suggest running `gstack-review`
(paranoid staff engineer mode) on any files changed in high-risk areas:
billing, auth, webhooks, database migrations.

## Fix discipline

**Grep for siblings before declaring a fix done.** After fixing any bug, search the entire codebase for the same pattern and fix ALL instances in one commit. A single-instance fix that misses a sibling is an incomplete fix. Applies to: assertion strings, env var names, display transformations, copy strings, and API method calls.

**Never poll CI in-chat.** Do not loop on `gh pr checks` or `gh run watch` interactively — it drains quota and hits rate limits.

**Auto-merge is mandatory when creating PRs.** After every `gh pr create`, immediately run `gh pr merge <number> --auto --squash` in the same step — never as a follow-up. The full sequence is always:
```bash
gh pr create --title "..." --body "..."  # capture the PR number from output
gh pr merge <number> --auto --squash      # set auto-merge immediately
```
GitHub then merges when checks pass — no further monitoring needed.

## Scope discipline

**Never touch TODOS.md, CLAUDE.md, CHANGELOG.md, or other project-management files unless explicitly asked.** Keep commits scoped to the task at hand. If you notice something worth logging, mention it in chat — don't write it yourself.

**Verify branch before every commit.** Run `git branch --show-current` before committing. If on the wrong branch, stop and ask rather than committing and cherry-picking later.

**Run the full test suite before creating a PR.** When fixing copy or UI text, also check that test locators and assertions still match the updated strings. A passing local suite catches issues before CI does.
