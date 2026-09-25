---
name: writing-plans
description: Use when turning an agreed spec or design into a multi-step implementation plan, especially one that another session or a subagent will execute without this conversation's context.
---

# Writing Plans

A plan is for a reader who has the repo but not this conversation. Write down what they cannot work out quickly from the code: which files change and why, what order the work goes in, and how to tell that each step is done. Leave out what they can see for themselves.

If the spec covers several independent subsystems, suggest one plan per subsystem, each producing working, testable software on its own.

## Before the tasks: the file map

List every file to be created or changed, with one line on its responsibility or what changes in it. This is where the structure is decided, so check it against the codebase:

- Follow the patterns the codebase already uses. Split a file only if it has grown unwieldy and the task touches it.
- Give each new file one clear job. Files that change together belong together.

## Tasks

Break the work into small tasks, each one a change you could review and commit on its own. For each task give:

- **Files:** exact paths, with line ranges when changing part of a large file.
- **Test first:** the test to write, named and described precisely enough to write without guessing (its inputs, the behaviour it checks, the expected result). Include code only where the exact shape matters, such as an interface signature or a tricky fixture.
- **Change:** what to implement, in terms of behaviour and interfaces, plus any constraint or gotcha the reader would not spot.
- **Verify:** the exact command, and what it should show before the change (the new test fails, and why) and after (it passes, plus any wider suite to run).
- **Depends on:** earlier tasks this one needs, or "none". Mark tasks that can run in parallel, since independent tasks can go to separate subagents.

Put the tasks in dependency order, and name the checkpoints where the user should look before work continues (for example after a migration or a public interface change).

## Where to put it

Save the plan where the project keeps plans or specs, following its naming; if it has none, ask the user where. Start it with a one-paragraph goal and a link to the spec, then the file map, then the tasks as a checklist so progress can be ticked off.

Adapted from obra/superpowers (MIT).
