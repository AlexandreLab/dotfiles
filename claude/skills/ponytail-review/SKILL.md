---
name: ponytail-review
description: "Over-engineering review of a diff or a whole repo: what to delete, inline, or replace with stdlib or native features. Use for \"review for over-engineering\", \"is this over-engineered\", \"audit this codebase\", \"what can I delete\", \"find bloat\", /ponytail-review, /ponytail-audit."
---

Hunt unnecessary complexity. One line per finding: location, what to cut, what replaces it. The best outcome is less code.

## Modes

- **Diff** (default): review the current diff or the PR named.
- **Whole repo**: when the user asks to audit the codebase, find bloat, or what can be deleted from the repo. Scan the whole tree and rank findings biggest cut first. Look especially for dependencies the stdlib or platform already ships, interfaces with one implementation, factories with one product, wrappers that only delegate, files exporting one thing, dead flags and config, and hand-rolled stdlib.

## Format

Diff: `L<line>: <tag> <what>. <replacement>.`, or `<file>:L<line>: ...` when the diff spans several files.

Whole repo: `<tag> <what to cut>. <replacement>. [path]`, one per line, ranked.

Tags:

- `delete:` dead code, unused flexibility, speculative feature. Replacement: nothing.
- `stdlib:` hand-rolled thing the standard library ships. Name the function.
- `native:` dependency or code doing what the platform already does. Name the feature.
- `yagni:` abstraction with one implementation, config nobody sets, layer with one caller.
- `shrink:` same logic, fewer lines. Show the shorter form.

## Examples

Not this: "This EmailValidator class might be more complex than necessary, have you considered whether all these validation rules are needed at this stage?"

This:

- `L12-38: stdlib: 27-line validator class. "@" in email, 1 line, real validation is the confirmation mail.`
- `L4: native: moment.js imported for one format call. Intl.DateTimeFormat, 0 deps.`
- `repo.py:L88: yagni: AbstractRepository with one implementation. Inline it until a second one exists.`
- `L52-71: delete: retry wrapper around an idempotent local call. Nothing replaces it.`
- `L30-44: shrink: manual loop builds dict. dict(zip(keys, values)), 1 line.`
- `native: axios for three GET calls. fetch, 0 deps. [src/api/client.ts]`

## Total

End with `net: -<N> lines possible.` In whole-repo mode add dependencies: `net: -<N> lines, -<M> deps possible.`

If there is nothing to cut, say `Lean already. Ship.` and stop.

## Boundaries

Over-engineering and complexity only. Correctness bugs, security holes and performance belong to a normal review pass (`/code-review`), not this one. A single smoke test or `assert`-based self-check is the minimum, not bloat; don't flag it for deletion. Report only: list the findings, apply nothing.
