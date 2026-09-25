---
name: receiving-code-review
description: Use when acting on code review feedback, such as PR review comments or a reviewer agent's findings. Verify each finding against the code before changing anything.
---

# Receiving code review

Treat review findings as claims to check, not instructions to carry out. Reviewers, human or agent, often lack context: they may not know why the code is the way it is, which platforms it supports, or whether a feature is used. Checking each finding first avoids changes that break working code or add code nobody needs.

## Process

1. **Read all the feedback before changing anything.** Items are often related, and a later one can change how you read an earlier one.
2. **Clarify unclear items first.** If some items are clear and others are not, ask about the unclear ones before implementing the batch, since partial understanding tends to produce the wrong change. For example: "Items 1, 2, 3 and 6 are clear. For 4 and 5, do you mean X or Y?"
3. **Verify each finding against the code.** Read the code it points at and check whether the problem is real in this codebase: does it happen on the paths that exist, would the suggested change break existing behaviour, is there a reason for the current implementation (compatibility, platform support, an earlier decision)? If you cannot verify a finding, say what you would need to check it.
4. **Check usage before adding requested features.** When a reviewer asks for something to be "implemented properly" (more options, persistence, filters, exports), grep for callers first. If nothing uses it, propose removing or leaving it rather than building it out.
5. **Fix one item at a time.** Make the change, run the relevant tests, then move on, so a regression can be traced to a single change. Order: blocking issues (breakage, security) first, then simple fixes, then larger refactors.
6. **Report what you did per item**: fixed (with where), declined (with the evidence), or needs a decision.

## Pushing back

Disagree when a suggestion is wrong for this codebase: it breaks existing behaviour, rests on missing context, adds unused features, is incorrect for this stack or version, or conflicts with a decision the user already made. Push back with evidence (the code, a test, a caller count, a doc or version constraint) and propose an alternative where there is one. If it touches architecture or a prior decision by the user, raise it with the user rather than settling it with the reviewer.

Examples:

- "Remove legacy code": "The build target is 10.15 and this API needs 13, so the legacy path is still reached. I can fix the wrong bundle ID in it, or we can drop pre-13 support. Which do you want?"
- "Add date filters and CSV export to the metrics endpoint": "Nothing calls this endpoint. Remove it instead?"

If you pushed back and then find the reviewer was right, say so plainly, state what you checked, and make the fix.

## Replying on GitHub

For inline PR review comments, reply in the comment's own thread so the conversation stays attached to the code, rather than posting a top-level PR comment:

```bash
gh api repos/{owner}/{repo}/pulls/{pr}/comments/{comment_id}/replies -f body="Fixed in abc1234: ..."
```

Keep replies factual: what changed and where, or why it was not changed.

Adapted from obra/superpowers (MIT).
