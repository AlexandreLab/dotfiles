---
name: test-driven-development
description: Use when implementing a feature or fixing a bug in code that has, or should have, automated tests. Write the failing test first, then the code.
---

# Test-driven development

Write the test first, watch it fail, then write the smallest code that makes it pass. A test you never saw fail might not test anything: it could be asserting on the wrong thing, or passing because of existing behaviour.

## The cycle

1. **Red.** Write one test for one behaviour, named after what should happen. Use real code; mock only what is slow, external or non-deterministic.
2. **Watch it fail.** Run just that test. Check that it fails (not errors) and that the failure message is the one you expect because the feature is missing, not because of a typo or a broken import. If it passes, it is testing behaviour that already exists: change the test.
3. **Green.** Write the simplest code that passes. No extra options, no refactoring of neighbouring code, nothing the test does not ask for.
4. **Watch it pass.** Run the test and the rest of the suite. If the new test fails, fix the code rather than the test. Clear any new warnings.
5. **Refactor.** With everything green, remove duplication and improve names. Re-run after each change and add no behaviour here.
6. Repeat with the next behaviour.

If a test is hard to write, the design is usually telling you something: an interface that needs many mocks or a large setup is too coupled. Simplify the interface before forcing the test through.

## Example

A good test names the behaviour and checks the real outcome:

```typescript
test('retries a failing operation until it succeeds', async () => {
  let attempts = 0;
  const operation = async () => {
    attempts++;
    if (attempts < 3) throw new Error('fail');
    return 'success';
  };

  expect(await retryOperation(operation)).toBe('success');
  expect(attempts).toBe(3);
});
```

A weaker version, `test('retry works', ...)` that builds a `jest.fn()` with chained `mockRejectedValueOnce` calls and asserts only `toHaveBeenCalledTimes(3)`, has a vague name and checks the mock's bookkeeping rather than what the caller gets back.

The matching minimal implementation is a three-iteration loop. A version with `maxRetries`, `backoff` and `onRetry` options is premature until a test needs them.

## Fixing a bug

Start with a test that reproduces the bug and fails for the reason the bug describes. Then fix the code and watch the test pass. The test proves the fix works and keeps the bug from coming back.

```typescript
test('rejects an empty email', async () => {
  const result = await submitForm({ email: '' });
  expect(result.error).toBe('Email required');
});
// Before the fix: expected 'Email required', received undefined
```

If the bug is in code with no tests at all, add a test around the behaviour you are changing rather than skipping it.

## When TDD is not a fit

- **Throwaway spikes** to learn an API or try an approach. Treat the spike as disposable: once you know the shape, rebuild the real version test-first rather than wrapping tests around the spike.
- **Pure configuration** (build settings, environment files, dependency bumps). Verify by running the thing the config drives: the build, the app, the existing suite.
- **Generated code** (migrations from a schema tool, API clients, type definitions). Test the generator's input or the behaviour that uses the output, not the generated lines.
- **Visual layout** that no assertion captures well. Check it in the running app or with a screenshot.

In these cases, say which kind of work it is and how you verified it, so the choice not to write a test is visible.

## Mocks and test utilities

Before adding a mock, a test helper or a method that only tests call, read `testing-anti-patterns.md` in this directory. It covers asserting on mocks instead of behaviour, test-only methods on production classes, mocking a method whose side effects the test depends on, and partial mock data.

Adapted from obra/superpowers (MIT).
