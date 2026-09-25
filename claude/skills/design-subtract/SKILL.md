---
name: design-subtract
description: Use when a UI feels busy, cheap, cluttered or "AI-made", when a critic says too much is going on, or when the user asks for a final polish pass. Holds the AI-tells checklist the other design skills use.
---

# Design Subtract

Deliver-stage pass. Models add; premium design is what remains after ruthless removal.
Inventory every element, ask what it alone communicates, and cut everything that fails.

Source: Anshu Chimala, "How to Turn Your AI Into a World-Class Designer" (Lenny's Newsletter, 2026-09-01), techniques 6 and 7.

## When to use

- After a build or a `design-critic-loop` round where gaps are mostly "too much"
- The user asks for a final polish pass on a screen
- The user says "cluttered", "busy", "tacky", "cheap", "looks AI-generated"

**Do not use** to add features or to restyle into a different direction. That is
`design-ideation`. This skill only removes, replaces with native, and tightens.

## Process

### 1. Capture before

Screenshot the screen (see `gstack-browse` or `npx -y playwright screenshot`). Save it as
`subtract/before.png` in the session scratchpad directory. Show it with the Read tool.

### 2. Inventory

List every visible element: backgrounds, effects, containers, labels, icons, badges, buttons,
dividers, shadows, animations. One line each. Do not skip small ones; they are the clutter.

### 3. Interrogate each element

For each line ask, in order, and stop at the first "no":

1. Does it communicate something no other element already communicates? No → **cut**.
2. Is it decoration standing in for a missing visual? No visual to replace it → **cut**;
   otherwise → **replace with the real visual** (image, product, data).
3. Is there a native platform equivalent (OS control, system font, CSS feature)? Yes → **use native**.
4. Is it the smallest, quietest version that still works? No → **tighten**.

Default rulings from the article, apply unless the direction explicitly demands otherwise:

| Element | Ruling |
|---|---|
| Glow, blob, mesh, gradient backgrounds | Cut. Flat or a single real image |
| Gradients on buttons, cards, text | Cut. Solid colour |
| Random colour highlights on words | Cut. One accent, used once per screen |
| Labels repeating what the visual shows | Cut the label |
| Containers around content that already groups itself | Cut the container |
| Custom inputs, buttons, toggles, pickers | Use native, style minimally |
| Drop shadow on every card | Cut. Shadows only for elevation that means something |
| Icon in a coloured circle before every heading | Cut |
| "New" / "Beta" / "✨" pills | Cut unless it changes what the user does |
| Rounded everything at the same radius | One radius scale, most things square |
| Typography sized "generously" everywhere | Smaller, tighter, one clear step between levels |

### 4. Apply

Make the cuts in code in one pass. Then the tighten pass: type scale, spacing rhythm, alignment.
Let the strongest visual dominate; everything else recedes.

### 5. Capture after and compare

Screenshot to `subtract/after.png` in the scratchpad. Show before and after together. The after should
have fewer elements, fewer colours, fewer effects, and read faster. If it reads emptier but not
better, you removed a communicating element; put that one back.

### 6. AI tells sweep

Final grep of the rendered page and the code for the list below. Fix every hit that is a
removal, a copy edit, or a native swap. Hits that need a new direction (section order, font
choice, layout system) are **flagged, not fixed**: list them in the report as input for
`design-ideation`. This skill never restyles.

## AI tells checklist

This is the one copy of the list. `design-critic-loop` pastes this section into its critic prompt and
`design-ideation` pastes it into its writer prompts, so edit it here and nowhere else.

Would a designer at a respected studio ship this? If no, it is a tell. A direction may break an
entry on purpose when it says why.

**Colour and effects**
- Purple, violet, indigo, or blue-to-purple anywhere it was not chosen for a reason
- Gradient text, gradient borders, glow blobs, mesh backgrounds, backdrop blur on everything
- Neon accent on dark for no reason
- Colour chosen because it is safe rather than for this product

**Layout**
- Centred hero → three equal cards → logo strip → testimonials → pricing grid, in that order
- Identical card grids where content varies in weight
- Bento grid used as a default, not to express hierarchy
- Uniform 16 or 24px padding everywhere; no rhythm

**Type and copy**
- Inter or Roboto on white with one accent, unconsidered, or any font chosen because it is safe
- Headline patterns: "Supercharge your X", "X, reimagined", "The future of X", "Meet X"
- Emoji or sparkle icons as bullets or in headings
- Labels that restate the visual

**Components and motion**
- Custom-drawn controls that behave worse than native
- Same radius and same shadow on every surface
- Fade-up-on-scroll on every section
- Decorative icons in coloured circles

## Report

Two screenshots side by side, the inventory with a ruling per line, files changed, and a
count: elements before → after. Recommend a `design-critic-loop` round if the user wants a score.

## Related

`design-critic-loop` (scored rounds; its critic uses the checklist above), `gstack-design-review` (graded
one-shot audit), `design-ideation` (when the problem is direction, not clutter; also uses the checklist).
