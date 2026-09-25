---
name: subagent-driven-development
description: Use when executing a written multi-task implementation plan in this session by handing each task to a subagent, with review scaled to each task's risk.
---

# Subagent-Driven Development

You coordinate; subagents implement. Each task in the plan goes to a fresh subagent with exactly the context it needs, and you check the result before moving on. This keeps your own context free for coordination and stops one task's history from confusing the next.

## Before you start

1. Read the plan once. Extract every task's full text and note the shared context (architecture, conventions, file layout, how to run the tests).
2. Create a task list with one entry per plan task, so progress survives a long session.
3. Work on a feature branch, not `main`. If the work needs its own checkout, set one up first (see the `using-git-worktrees` skill, or EnterWorktree for this session).
4. Note the current commit SHA. You will want it as the base for reviewing each task.

## Per task

1. **Dispatch the implementer** with `./implementer-prompt.md`. Paste the full task text and the scene-setting context into the prompt; a subagent that has to go and read the plan file wastes its context and may read the wrong section.
2. **Answer questions.** If the implementer comes back with questions before starting, answer them fully and let it continue.
3. **Handle its status** (see below).
4. **Review at the level the task's risk calls for** (see below): spec compliance first, then code quality.
5. **Mark the task done** in the task list only when the review level you chose has no open issues.

After the last task, review the whole branch once (`/code-review`, or a reviewer subagent on `opus` given the full diff from the base SHA), then run the project's quality gate before opening the PR.

## Choosing the model

Use the cheapest model that can do the job well, passed as the Agent tool's `model`:

| Task | Model |
|---|---|
| One or two files, complete spec, mechanical | `haiku` |
| Several files, integration, pattern matching, debugging | `sonnet` |
| Design judgment, broad codebase understanding, review of risky work | `opus` |

Most tasks in a well-specified plan are mechanical. If a cheap model returns BLOCKED because the task needed more reasoning, re-dispatch on the next tier up rather than retrying the same one.

## Handling implementer status

The implementer ends its report with one of four statuses.

- **DONE:** proceed to review.
- **DONE_WITH_CONCERNS:** read the concerns first. If they are about correctness or scope, resolve them before review. If they are observations ("this file is getting large"), note them and proceed.
- **NEEDS_CONTEXT:** supply what was missing and re-dispatch, or continue the same agent with SendMessage so it keeps what it already learned.
- **BLOCKED:** something has to change before a retry. Work out which:
  - missing context: provide it and re-dispatch on the same model;
  - not enough reasoning: re-dispatch on a stronger model;
  - task too large: split it into smaller tasks;
  - the plan is wrong: stop and ask the user.

Retrying unchanged just produces the same result.

## How much review

Review effort follows risk, not a fixed ritual.

- **Trivial** (a rename, a config value, a one-function change with a passing test): read the diff yourself and check the tests ran. No separate reviewers.
- **Normal** (a new module, a multi-file change): dispatch the spec reviewer (`./spec-reviewer-prompt.md`). If it passes and the change is non-trivial, dispatch the quality reviewer (`./code-quality-reviewer-prompt.md`), or run `/code-review` on the task's diff.
- **Risky** (auth, billing, webhooks, migrations, data deletion, concurrency, public API changes): both reviewers, the quality reviewer on `opus`, plus any review the project requires for those areas (for example `gstack-review`).

Run the spec check before the quality check. There is no point polishing code that builds the wrong thing, and fixing a spec gap often changes the code the quality reviewer would have looked at.

Don't rely on the implementer's self-review or its report alone for normal and risky tasks: reports tend to be optimistic, and the reviewers read the code.

## When a review finds issues

- **Small and obvious** (a missing null check, a stray debug line, a wrong constant): fix it yourself, run the relevant tests, and move on. A round trip costs more than the fix.
- **Larger or spread across files:** send the findings back to the same implementer with SendMessage, then re-run the review that failed.
- Re-review after any non-trivial fix. A fix that wasn't checked is a guess.
- Move to the next task only when the chosen review level has no open issues.

## Running tasks in parallel

Tasks are sequential by default, because two agents editing one checkout will overwrite each other. You can run independent tasks at the same time when:

- they touch disjoint files and neither depends on the other's output, and
- each implementer runs with `isolation: "worktree"`, so it gets its own checkout and branch.

Launch them in one message, as background agents if you have other coordination to do. When they finish, merge each worktree branch back into the feature branch one at a time, run the tests after each merge, and resolve conflicts yourself. Review each task as usual.

If the user has opted into multi-agent orchestration, the Workflow tool can run a large plan this way; otherwise use the Agent tool directly.

## What the subagent needs from you

- The full task text, not a pointer to the plan.
- Where the task fits: what earlier tasks built, what later tasks will rely on.
- The working directory and branch.
- How to run the tests and the project's conventions (TDD if the project uses it, the package manager, the formatter).
- An explicit list of files it may change, and the instruction to leave project-management files (CLAUDE.md, AGENTS.md, TODOS.md, CHANGELOG.md) alone.

## Prompt templates

- `./implementer-prompt.md`: implementer subagent.
- `./spec-reviewer-prompt.md`: spec compliance reviewer.
- `./code-quality-reviewer-prompt.md`: code quality reviewer.

Adapted from obra/superpowers (MIT).
