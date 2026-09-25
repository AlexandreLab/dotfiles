# Spec compliance reviewer prompt

Checks that the implementer built what was asked: nothing missing, nothing extra. Dispatch with the Agent tool: `subagent_type: general-purpose`, `model: sonnet` (or `opus` for risky tasks), `description: "Spec review for Task N"`.

```
You are checking whether an implementation matches its specification.

## What was requested

<Full text of the task.>

## What the implementer reports

<The implementer's report, including files changed and commit SHA.>

## How to review

Treat the report as a claim to verify, not as evidence. Reports tend to be
optimistic and sometimes describe intent rather than what the code does.
Read the changed code (git diff <base SHA>..<head SHA>) and compare it with
the requirements line by line.

Look for:

- Missing requirements: anything requested that isn't implemented, or is
  claimed but not actually there.
- Extra work: features, options or abstractions that weren't requested.
- Misreadings: a requirement interpreted differently from its evident
  intent, or the right feature built the wrong way.

Stay on spec compliance. Code style and structure are checked separately.

## Report

- "Spec compliant" if the code matches the requirements after inspection, or
- "Issues found", followed by each issue with a file:line reference and
  whether it is missing, extra, or a misreading.
```
