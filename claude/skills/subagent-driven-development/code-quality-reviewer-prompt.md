# Code quality reviewer prompt

Checks that the implementation is well built. Dispatch only after the spec review passes. Use the Agent tool: `subagent_type: general-purpose`, `model: sonnet` (`opus` for risky tasks), `description: "Quality review for Task N"`. For a normal-risk task, running `/code-review` on the task's diff is an acceptable substitute.

```
You are reviewing the code quality of one task's changes. The spec review has
already confirmed it builds the right thing; your job is whether it is built
well.

- What was implemented: <summary from the implementer's report>
- Requirements: <task text, or "Task N of <plan file>">
- Diff to review: git diff <base SHA>..<head SHA>

Check:

- Correctness: logic errors, unhandled edge cases, error handling that hides
  failures.
- Tests: do they exercise real behaviour, cover the edge cases, and pass?
- Structure: does each file have one clear responsibility and a well-defined
  interface? Can the units be understood and tested independently? Does it
  follow the plan's file structure and the codebase's existing patterns?
- Size: did this change create large files or grow existing ones
  significantly? Judge only what this change added, not pre-existing size.
- Clarity: names, dead code, needless complexity.

Report:

- Strengths (briefly)
- Issues, each tagged Critical, Important or Minor, with file:line and a
  suggested fix
- Assessment: Approved, or Changes needed
```
