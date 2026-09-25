# Root cause tracing

Bugs often surface deep in the call stack: `git init` in the wrong directory, a file created in the wrong place, a database opened with the wrong path. Fixing the code where the error appears treats the symptom. Instead, trace backwards through the call chain to the original trigger and fix it there.

Use this when:

- the error happens deep in execution rather than at the entry point;
- the stack trace shows a long call chain;
- it is unclear where an invalid value came from;
- you need to find which test or caller triggers the problem.

If you reach a dead end and cannot trace further up, fix at the deepest point you understand and add the logging described below so the next occurrence tells you more.

## The process

1. **Observe the symptom.**
   ```
   Error: git init failed in /Users/jesse/project/packages/core
   ```
2. **Find the immediate cause**, the line that directly produces it.
   ```typescript
   await execFileAsync('git', ['init'], { cwd: projectDir });
   ```
3. **Ask what called it.**
   ```
   WorktreeManager.createSessionWorktree(projectDir, sessionId)
     called by Session.initializeWorkspace()
     called by Session.create()
     called by a test at Project.create()
   ```
4. **Check the values passed at each level.** Here `projectDir` was `''`. An empty `cwd` resolves to `process.cwd()`, which was the source directory.
5. **Keep going until you reach the origin.**
   ```typescript
   const context = setupCoreTest(); // returns { tempDir: '' } until beforeEach runs
   Project.create('name', context.tempDir); // read at the top level, before beforeEach
   ```

The fix belongs at step 5: make `tempDir` a getter that throws if read before `beforeEach`. Then consider validating at the layers in between as well; see `defense-in-depth.md`.

## Adding stack-trace logging

When you cannot follow the chain by reading, log just before the problematic operation:

```typescript
async function gitInit(directory: string) {
  console.error('DEBUG git init:', {
    directory,
    cwd: process.cwd(),
    nodeEnv: process.env.NODE_ENV,
    stack: new Error().stack,
  });
  await execFileAsync('git', ['init'], { cwd: directory });
}
```

```bash
npm test 2>&1 | grep 'DEBUG git init'
```

Then look for test file names and line numbers in the stacks, and for what the triggering calls have in common (same test, same parameter).

Tips:

- In tests, use `console.error()`; the application logger is often silenced.
- Log before the operation, not after it fails, so you capture the state that led to it.
- Include the context that could differ: directory, cwd, environment variables, timestamps.
- `new Error().stack` gives the full call chain without throwing.

## Finding which test causes pollution

If something appears during a test run and you do not know which test creates it, `find-polluter.sh` in this directory runs test files one at a time and stops at the first one that creates the path:

```bash
./find-polluter.sh '.git' 'src/**/*.test.ts'
TEST_CMD='uv run pytest' ./find-polluter.sh '.cache' 'tests/**/test_*.py'
```
