---
name: design-ideation
description: Use when starting the visual design of a page, app, component or brand surface and the user wants bold, distinct directions rather than a default look ("design directions", "how should this look", "give me options").
---

# Design Ideation

Discover-stage facilitation. Produces N (default 4) one-page design briefs, each in its own
markdown file, each a genuinely different direction. Human taste steers; seed strings add
variety the model cannot generate on its own.

Source: Anshu Chimala, "How to Turn Your AI Into a World-Class Designer" (Lenny's Newsletter, 2026-09-01).

## When to use

- A page, app, component, or brand surface needs a visual direction and nothing exists yet
- The user says the current design looks generic, "AI-made", or like every other SaaS
- Before `frontend-design` builds anything user-facing and no brief exists

**Do not use** to build UI (that is `frontend-design`), to compare rendered variants
(`gstack-design-shotgun`), or to define a full design system (`gstack-design-consultation`).

## Arguments

`/design-ideation [what] [--count N] [--out DIR] [--model sonnet|opus]`

| Flag | Default | Notes |
|---|---|---|
| `--count` | 4 | Number of briefs and writer subagents |
| `--out` | `specs/design-briefs/` if `specs/` exists, else `docs/design-briefs/` | Created if missing |
| `--model` | `opus` | Model alias for the writers. Larger models have a wider idea distribution; `sonnet` for cheap runs |

## Process

Run the steps in order, including the taste round even when it costs a turn. AI ideating against
AI converges on the mean, so the user's reaction in step 3 is the input that makes the briefs
distinct.

### 1. Intake

One `AskUserQuestion` covering only what the prompt did not already say: what is being designed,
who it is for, hard constraints (platform, accessibility, existing brand), and whether brand docs
exist. If `docs/brand.md`, `BRAND.md`, or `brand.md` exists, read it first and say you did.

### 2. Go broad

Run `openssl rand -base64 48` once. Use the string as private inspiration for the list below.
Look past the surface: repeated characters, digit clusters, rhythm. Keep it out of anything you
show, since it is inspiration, not content. This seed is for the list only; every writer in step 5
gets its own fresh seed, so directions do not share a starting point.

List 15–20 design-language ideas. Format: **Name** followed by one sentence. Rules:

- Span unrelated fringes: physical materials, eras, media, subcultures, sciences, games, places
- At least three entries break a layout, colour, or typography rule on purpose
- No palettes, fonts, or detail yet. Go broad, not deep
- Nothing from the AI tells checklist in `design-subtract` unless a direction subverts it deliberately

### 3. Taste round

Ask the user to pick 2–4 and react in their own words. Include the quote below as an example
of the kind of reaction that helps. It is a sample answer, not a question to send:

> "Industrial Control Panel: I'm imagining something tactile. Clicky, satisfying buttons.
> Skeuomorphic feels tacky to me, avoid that. Gray gradients would be boring, need texture.
> Maybe some colour while keeping the control-panel feel?"

If a reaction is one word, ask one follow-up for that pick only. Maximum two rounds total.

### 4. Sharpen

For each pick write a 3–5 line sharpened direction that encodes every reaction: what they
pictured, what to avoid, what to keep. Show all picks together and get a yes or edits.
This is the last human checkpoint before files are written.

### 5. Fan out

Dispatch `count` writer subagents **in one message** so they run in parallel. One per sharpened
direction. If picks < count, the remaining writers are **wildcards**: they derive the whole
direction from their seed string alone, constrained only by intake context.

For each writer:

1. Run `openssl rand -base64 48` to get a fresh seed (one per writer, distinct from step 2)
2. Fill `references/writer-prompt.md` with context, direction (or `WILDCARD`), seed, out dir, `n`, subject slug
3. Paste the contents of `references/brief-template.md` and the "AI tells checklist" section of
   `design-subtract/SKILL.md` into the prompt, so each writer has the rubric without reading files
4. `model` set to the `--model` alias

Writers never see each other's directions or output.

### 6. Verify files

Path pattern: `<out>/<YYYY-MM-DD>-<subject-slug>-<n>-<direction-slug>.md`. Each writer derives
`<direction-slug>` from its own direction name, so wildcards name themselves.
Check every file exists, has all 10 template sections, is under ~60 lines, and contains no
seed fragment: `grep -E '[A-Za-z0-9+/]{20,}' <files> | grep -E '[0-9]'` must return nothing
(a long English compound like `chronograph/drafting` has no digit and is fine). Fix or
re-dispatch one writer if not.

### 7. Report

A table: n, direction name, one-line hook, path. Then exactly two next steps:
build one with `frontend-design` by pasting its build prompt, or render all with
`gstack-design-shotgun`.

## What to avoid

The go-broad list and the writers steer clear of the AI tells checklist in `design-subtract`, the
single copy of that list, unless a direction subverts an entry on purpose. Every brief names one
rule it breaks and why it still works.

## Common mistakes

| Mistake | Fix |
|---|---|
| Skipping the taste round to save turns | AI ideating against AI converges on the mean. The human reaction is the input |
| Revealing or hinting at the seed string | It is inspiration only. Strip it from output and files |
| Four briefs that are one idea in four palettes | Directions must differ in concept, layout, and material, not just colour |
| Briefs longer than a page | Cut prose; the build prompt carries the detail |
| Re-asking what the prompt already said | Intake covers gaps only |
| Writers sharing context | Each writer gets a fresh subagent and its own seed |

## Related

- `frontend-design` builds from a brief. `gstack-design-shotgun` compares renders.
- Next stages: `design-critic-loop` (fresh-context critic on screenshots, hidden score
  threshold), then `design-subtract` (subtraction pass and AI-tells checklist).
