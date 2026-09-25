# Condition-based waiting

Flaky tests often guess at timing with fixed delays. They pass on a fast machine and fail under load or in CI. Wait for the condition you actually care about instead of a guess at how long it takes.

Use this when:

- tests contain arbitrary delays (`setTimeout`, `sleep`, `time.sleep()`);
- tests pass sometimes and fail under load or when run in parallel;
- a test waits for an async operation to finish.

Keep a fixed delay only when the test is about timing itself (debounce, throttle, tick intervals), and comment why.

## The pattern

```typescript
// Before: guessing at timing
await new Promise((r) => setTimeout(r, 50));
expect(getResult()).toBeDefined();

// After: waiting for the condition
await waitFor(() => getResult() !== undefined, 'result to be set');
expect(getResult()).toBeDefined();
```

| Waiting for | Condition |
|---|---|
| An event | `waitFor(() => events.find((e) => e.type === 'DONE'), 'DONE event')` |
| A state | `waitFor(() => machine.state === 'ready', 'ready state')` |
| A count | `waitFor(() => items.length >= 5, '5 items')` |
| A file | `waitFor(() => fs.existsSync(path), 'output file')` |

## Implementation

```typescript
async function waitFor<T>(
  condition: () => T | undefined | null | false,
  description: string,
  timeoutMs = 5000,
): Promise<T> {
  const start = Date.now();
  while (true) {
    const result = condition();
    if (result) return result;
    if (Date.now() - start > timeoutMs) {
      throw new Error(`Timeout waiting for ${description} after ${timeoutMs}ms`);
    }
    await new Promise((r) => setTimeout(r, 10));
  }
}
```

`condition-based-waiting-example.ts` in this directory has a fuller version with event-specific helpers (`waitForEvent`, `waitForEventCount`, `waitForEventMatch`).

Most test frameworks already ship an equivalent (`waitFor` in Testing Library, `expect.poll` in Playwright and Vitest, `tenacity` or a polling fixture in Python). Prefer the built-in one where it exists.

## Common mistakes

- **Polling too fast** (every 1 ms) wastes CPU. Around 10 ms is enough.
- **No timeout** lets a broken condition hang the suite. Always time out with a message that says what was awaited.
- **Stale data**: reading state once before the loop. Call the getter inside the loop.

## When a fixed delay is right

```typescript
// The tool emits output every 100 ms; two ticks are needed to see partial output.
await waitForEvent(manager, 'TOOL_STARTED'); // first wait for the trigger
await new Promise((r) => setTimeout(r, 200)); // then wait for the timed behaviour
```

Wait for the triggering condition first, base the delay on known timing rather than a guess, and comment the reason.
