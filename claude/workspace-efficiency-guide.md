# Workspace Token Efficiency — Setup Guide

Use this guide to configure any Claude Code workspace for minimal token usage without sacrificing context quality.

---

## 1. Split CLAUDE.md by audience

**The problem:** A single root `CLAUDE.md` that @imports all docs loads everything on every session — even when the session only touches one subsystem.

**The fix:** Nest CLAUDE.md files. Claude Code automatically loads the nearest CLAUDE.md in the directory tree.

```
project/
├── CLAUDE.md                  # Minimal: only cross-cutting rules + routing note
├── src/app/CLAUDE.md          # Frontend-specific context (loaded for frontend sessions)
├── src/api/CLAUDE.md          # Backend-specific context (loaded for backend sessions)
└── docs/CLAUDE.md             # Content/copy context (loaded for content sessions)
```

**Root CLAUDE.md should contain:**
- Project overview (2–3 sentences)
- Branch strategy
- Scope/commit discipline rules
- Pointer: "More context in `src/app/CLAUDE.md` for frontend work"

**Sub-CLAUDE.md should contain:**
- Tech stack for that subsystem
- Relevant @imports (ADRs, plans, conventions)
- Subsystem-specific lessons

**Savings:** ~5,000–10,000 tokens per session when large plan docs are only loaded for the relevant subsystem.

---

## 2. Auto-merge every PR at creation time

**The problem:** Polling CI status interactively burns tokens and hits rate limits (one project had 50/68 sessions doing nothing but checking CI).

**The fix:** When creating a PR, set auto-merge in the same step — never separately.

```bash
# Always this two-step sequence — never just gh pr create alone:
gh pr create --title "feat: ..." --body "$(cat <<'EOF'
## Summary
...
EOF
)"
gh pr merge <number> --auto --squash
```

Add this to your global `~/.claude/CLAUDE.md`:
```markdown
**Auto-merge is mandatory when creating PRs.** After every `gh pr create`,
immediately run `gh pr merge <number> --auto --squash` in the same step.
GitHub merges when checks pass — no monitoring needed.
```

---

## 3. Scope discipline rules (add to global CLAUDE.md)

```markdown
## Scope discipline

**Never touch TODOS.md, CLAUDE.md, CHANGELOG.md, or project-management files
unless explicitly asked.** Mention observations in chat — don't write them.

**Verify branch before every commit.** Run `git branch --show-current` before
committing. If on the wrong branch, stop and ask.

**Run the full test suite before creating a PR.** When fixing copy or UI text,
verify test locators still match updated strings.
```

---

## 4. Audit @imports for dead weight

Before setting up a workspace, audit what gets auto-loaded:

```bash
# Find all @imports in all CLAUDE.md files:
grep -r "^- @" */CLAUDE.md CLAUDE.md 2>/dev/null

# Check the size of each imported file:
wc -c docs/plans/*.md
```

**Remove @imports for:**
- Completed phase plans (a 30KB plan for a done phase loads on every session forever)
- Files that are only relevant to one subsystem (move to a sub-CLAUDE.md)
- Files that are only needed for specific tasks (reference them in the task prompt instead)

**Keep @imports for:**
- Brand/voice guides (needed for any copy-adjacent work)
- Active ADRs (ongoing architectural constraints)
- Short convention files (<200 lines)

---

## 5. Use headless mode for one-shot tasks

For tasks that don't need back-and-forth, skip the interactive session entirely:

```bash
# Check and auto-merge green PRs — no session needed:
claude -p "Check all open PRs with 'gh pr list'. For any with passing CI, merge with --squash." \
  --allowedTools "Bash"

# Run a smoke test and report:
claude -p "Run 'uv run python tools/smoke_test.py' and summarise the output." \
  --allowedTools "Bash,Read"
```

Headless mode skips session startup, conversation history accumulation, and skill loading — often 60–70% cheaper for simple automation tasks.

---

## 6. Keep sessions short and focused

Long sessions accumulate conversation history that's re-sent with every message. Each message in a 40-message session pays for ~39 prior messages as context.

**Practical rules:**
- One task per session when tasks are independent
- Commit and end the session after each logical unit of work
- Start a new session for the next task — it opens with only CLAUDE.md context, not 40 messages of history

**When to keep a long session:** When tasks are tightly coupled (e.g., fix bug → write test → verify → commit) — breaking these up costs more in context re-loading than it saves.

---

## 7. Subagent context discipline

When dispatching subagents, provide only what they need — not the whole conversation:

```
BAD:  "Based on everything we've discussed, implement this in a subagent"
GOOD: [Read the relevant files first, then write a self-contained prompt with]
      - Exact file paths to read
      - Exact spec/requirements text
      - What to commit and how
```

A subagent that reads 3 specific files is 5–10x cheaper than one that inherits the full session context.

---

## Checklist for setting up a new workspace

- [ ] Root `CLAUDE.md` is under 50 lines and contains only cross-cutting rules
- [ ] Heavy docs (@imports >500 lines) live in sub-CLAUDE.md files, not root
- [ ] Completed phase plans removed from @imports
- [ ] Global `~/.claude/CLAUDE.md` has the auto-merge rule and scope discipline rules
- [ ] PR creation script/workflow always includes `gh pr merge <number> --auto --squash`
- [ ] No interactive CI polling — either headless or auto-merge
