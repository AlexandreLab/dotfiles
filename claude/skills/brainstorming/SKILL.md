---
name: brainstorming
description: Use before building a new user-facing feature, or when a request's requirements are genuinely unclear, to agree on intent and a design with the user before writing code. Not for bug fixes or well-specified changes.
---

# Brainstorming

Turn a rough idea into an agreed design through a short conversation. The aim is to catch wrong assumptions while they are still cheap to change, so keep the process in proportion to the feature: a small feature may need one exchange and a few sentences of design.

## 1. Understand before asking

Read what already exists first: the relevant code, docs, specs, recent commits and the conversation so far. Answer your own questions from the repo where you can, and only ask the user what the repo cannot tell you.

If the request bundles several independent pieces (for example chat, billing and analytics), say so early and agree which piece to design first. Each piece gets its own design.

## 2. Ask the questions that change the design

Ask only questions whose answer would change what you build: purpose, who uses it, constraints, what success looks like, and edge cases with real consequences. Batch them in one message, numbered, with a suggested default or multiple-choice options for each so the user can answer quickly. Follow up only where an answer opens a new fork.

## 3. Offer two or three approaches

Describe each approach in a few lines with its main trade-offs (effort, risk, what it rules out later). Lead with your recommendation and say why. If one approach is clearly right, say that rather than inventing weaker alternatives.

## 4. Cut scope

Before settling, remove anything the stated goal does not need. Name what you are leaving out, so the user can bring it back deliberately. In an existing codebase, follow its patterns and include only the refactoring the feature actually needs.

## 5. Write a short design note

Once the user agrees, summarise the design: the goal, the chosen approach, the main units and what each is responsible for, data flow, error handling, how it will be tested, and what is out of scope. Scale each part to its complexity.

Put it in chat by default. If the project keeps specs (for example a `specs/` or `docs/` folder), save it there following the existing naming, and tell the user the path. Then continue with whatever the user wants next: a written plan, or straight to implementation for small work.

## Visual questions

When a question is about layout or look and is easier to answer by seeing it, the browser companion described in `visual-companion.md` can show mockups and record the user's clicks. Ask the user before starting it, and use it only for questions that are visual, not for every question.

Adapted from obra/superpowers (MIT).
