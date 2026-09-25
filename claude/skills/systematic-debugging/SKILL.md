---
name: systematic-debugging
description: Use when a bug, failing test, build failure or unexpected behaviour has a cause that is not already obvious. Find the root cause before changing code.
---

# Systematic debugging

Guessed fixes tend to hide the symptom, add new bugs, and make the real cause harder to find later. Work out why the failure happens before changing code. For a simple bug this takes minutes; for a hard one it is still faster than a series of guesses.

Work through the four phases in order. If the cause turns out to be obvious once you have read the error and reproduced it, go straight to phase 4.

## Phase 1: Reproduce and read the error

1. **Read the whole error.** Read the full message, stack trace, file paths, line numbers and error codes, and any warnings printed before it. The answer is often already there.
2. **Reproduce it.** Find the exact steps or command that trigger the failure, and check whether it happens every time. If it is intermittent, gather more data (inputs, timing, environment, ordering) rather than guessing.
3. **Check what changed.** Look at `git diff`, recent commits, dependency and lockfile changes, config and environment differences between where it works and where it fails.
4. **In multi-layer systems, log at each boundary.** When data passes through several components (CI to build script to signing, API to service to database), add temporary logging where each component receives and hands off data, and check that config and environment variables reach each layer. Run once and see which layer first holds a wrong value, then investigate that layer.

   ```bash
   # Layer 1: workflow
   echo "IDENTITY in workflow: ${IDENTITY:+set}${IDENTITY:-unset}"
   # Layer 2: build script
   env | grep IDENTITY || echo "IDENTITY not in build environment"
   # Layer 3: signing
   security find-identity -v
   codesign --sign "$IDENTITY" --verbose=4 "$APP"
   ```

5. **Trace bad values backwards.** When the error surfaces deep in a call stack, ask where the bad value came from, what called this with it, and keep going up until you reach the source. `root-cause-tracing.md` in this directory walks through the technique, including stack-trace logging.

## Phase 2: Compare with working code

1. Find similar code in the same codebase that works.
2. If you are following a pattern or reference implementation, read it fully rather than skimming. Partial reading is a common source of subtle differences.
3. List every difference between the working and the broken case, including ones that look irrelevant.
4. Note what the broken code depends on: other components, settings, environment, and the assumptions it makes about them.

## Phase 3: Test one hypothesis at a time

1. State a single hypothesis: "X is the cause because Y." Be specific.
2. Test it with the smallest possible change or probe, changing one variable at a time.
3. If it is confirmed, move to phase 4. If not, form a new hypothesis from what you learned, and undo the probe rather than stacking another change on top of it.
4. If you do not understand something, say so and investigate or ask, rather than acting as if you do.

## Phase 4: Fix the root cause

1. **Write a failing test that reproduces the bug**, using the project's test framework, or a small script if there is none. It proves the fix and guards against regressions.
2. **Make one fix, at the root cause**, not where the symptom appears. Leave unrelated improvements and refactoring for a separate change so the fix stays easy to review.
3. **Verify.** The new test passes, the rest of the suite still passes, and the original reproduction no longer fails.
4. **If the bug came from invalid data**, consider adding validation at the other layers the data passes through; see `defense-in-depth.md`.

## When fixes keep failing

If a fix does not work, go back to phase 1 with what you learned. After about three failed fixes, stop trying new ones. Repeated failure usually means an assumption is wrong or the design itself is the problem, especially when each fix exposes a new issue somewhere else, or would need a large refactor to land. At that point:

- write down what you tried and what each attempt showed;
- question the assumptions and the design: is this pattern sound, or is it being kept out of inertia?
- tell the user, and agree on a direction before attempting another fix.

## When there is no root cause in the code

Sometimes the investigation shows the failure really is environmental, timing-dependent or external. Say what you investigated and ruled out, then add appropriate handling (a retry, a timeout, a clear error message) and logging that will help next time. Treat this as the conclusion only after the phases above, since most "no root cause" cases are an investigation that stopped early.

## Technique files in this directory

- `root-cause-tracing.md`: trace a bad value backwards through the call stack to its source.
- `defense-in-depth.md`: after fixing a data bug, add validation at each layer so it cannot recur.
- `condition-based-waiting.md` (with `condition-based-waiting-example.ts`): replace arbitrary sleeps in flaky tests with polling for the real condition.
- `find-polluter.sh`: run test files one by one to find which one leaves an unwanted file or state behind.

Adapted from obra/superpowers (MIT).
