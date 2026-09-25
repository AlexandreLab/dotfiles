---
name: design-critic-loop
description: Use when a rendered UI needs studio-level polish and the user asks for it, or says a design looks "fine but generic", "AI-made" or "not there yet". Runs a fresh-context critic on screenshots until it reaches a hidden score.
---

# Design Critic Loop

Define-stage iteration. A separate critic subagent, in a fresh context with only a screenshot,
scores the design against how a top studio would execute the same aesthetic. The builder
iterates until the critic independently reaches the bar. Critic and builder never share context.

Source: Anshu Chimala, "How to Turn Your AI Into a World-Class Designer" (Lenny's Newsletter, 2026-09-01), technique 3.

## When to use

- A page or component renders and works, and the question is now "is it great?"
- The user reacts with "meh", "generic", "looks like every SaaS", "not premium"
- After `design-ideation` → `frontend-design` produced a POC

**Do not use** with no running UI (nothing to screenshot), for functional QA (`gstack-qa`),
or for a one-off checklist audit (`gstack-design-review`, `design-subtract`).

## Why a separate critic

The builder is biased toward what it already wrote. A critic that sees only pixels has no sunk
cost, no memory of past rounds, and no knowledge of the stopping threshold. The article's cost
profile: critic on a large model, under 10% of tokens; builder on whatever is already running.

## Arguments

`/design-critic-loop <url-or-route> [--target N] [--max K] [--aesthetic "..."] [--refs dir/] [--viewport WxH]`

| Flag | Default | Notes |
|---|---|---|
| `--target` | 9 | Score /10 that ends the loop. Never revealed to the critic |
| `--max` | 5 | Hard cap on rounds. Stop and report if reached |
| `--aesthetic` | inferred by critic | Pass the brief's direction name if one exists |
| `--refs` | none | Folder of 2–4 reference screenshots or moodboard images at the quality bar. Given as baselines, not templates |
| `--viewport` | 1440x900 | Add `--mobile` to also score 390x844 |

Critic model: `opus`. Builder: the current session.

## Process

### 0. Preconditions

Confirm the UI is reachable. If a brief exists (`specs/design-briefs/` or `docs/design-briefs/`),
read it and pass its direction name as `--aesthetic`. Fix the critic prompt now; it does not
change between rounds.

### 1. Screenshot

Prefer the gstack browse daemon (see `gstack-browse`): `$B goto <url>` then
`$B screenshot <scratchpad>/critic/round-N.png`, where `<scratchpad>` is the session scratchpad
directory. Full page. Fallback:

```bash
npx -y playwright install chromium-headless-shell   # once; cached browsers may not match npx's version
npx -y playwright screenshot --viewport-size=1440,900 --full-page <url> <scratchpad>/critic/round-N.png
```

If neither works, ask the user for a screenshot path. The critic judges pixels only, so do not
hand it code as a substitute.

### 2. Invoke the critic

Fresh `Agent` call every round, `model: opus`, prompt from `references/critic-prompt.md` with
the screenshot path, the AI tells checklist from `design-subtract`, optional aesthetic, optional
refs. Pass nothing else: no code, no diff, no earlier critiques, no target score. Use the
identical prompt each round.

The critic returns: aesthetic as read, studio-level vision in 3 lines, the biggest gaps ranked
(max 5, each specific and actionable), AI tells spotted, score /10 with one-line justification.

### 3. Compare and act

- Score ≥ target: stop. Go to step 5.
- Round = max, or the score did not move since last round: stop. Report the best round and remaining gaps.
- Otherwise: fix the top gaps in order. Each fix is a concrete change; if a gap is vague, treat
  it as "remove" rather than "add". Re-run step 1.

Keep a round log in `<scratchpad>/critic/log.md`: round, score, gaps, what changed.

### 4. Guard against drift

Every round check the aesthetic the critic read matches the intended one. If it drifts, the
builder over-corrected; revert the last change set rather than pile on.

### 5. Report

Table of rounds and scores, the final critique verbatim, list of changed files. Show the first
and last screenshots with the Read tool so the user sees them. Recommend `design-subtract` if
the critic's remaining gaps are mostly "too much".

## Ranking mode (optional, sharper signal)

When `--refs` is given with 3–4 images, ask the critic to rank all images including the
screenshot by polish, blind, and explain the gap to the one ranked just above. Objective
comparisons beat "is it beautiful".

## Common mistakes

| Mistake | Fix |
|---|---|
| Telling the critic the target | It anchors. Threshold lives in the builder only |
| Passing code or prior critiques | Fresh context each round or the loop converges on its own bias |
| Changing the critic prompt mid-loop | Scores stop being comparable |
| Adding on every round | Most gaps close by removing. See `design-subtract` |
| Infinite loop on a plateau | `--max` is a hard stop. Same score two rounds running: stop and report; a test run spent two extra rounds for +0.5 |
| Critic on a small model | Design sense scales with model size. Keep opus for the critic |

## Related

`design-ideation` (before), `design-subtract` (the fix pass), `gstack-design-review` (one-shot audit
with grades), `gstack-browse` (screenshots).
