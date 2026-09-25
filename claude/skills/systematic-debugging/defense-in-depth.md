# Defense-in-depth validation

After fixing a bug caused by invalid data, one check at the source can feel like enough. But other code paths, later refactors or mocks can bypass a single check. Where the consequence is serious (writing to the wrong directory, corrupting data), validate at each layer the data passes through so the bug cannot recur by another route.

Use judgment on how many layers a given bug deserves; a cosmetic bug does not need four.

## The layers

**1. Entry point.** Reject obviously invalid input at the API boundary.

```typescript
function createProject(name: string, workingDirectory: string) {
  if (!workingDirectory?.trim()) throw new Error('workingDirectory cannot be empty');
  if (!existsSync(workingDirectory)) throw new Error(`workingDirectory does not exist: ${workingDirectory}`);
  if (!statSync(workingDirectory).isDirectory()) throw new Error(`workingDirectory is not a directory: ${workingDirectory}`);
  // ...
}
```

**2. Business logic.** Check that the data makes sense for this operation.

```typescript
function initializeWorkspace(projectDir: string, sessionId: string) {
  if (!projectDir) throw new Error('projectDir required for workspace initialization');
  // ...
}
```

**3. Environment guards.** Refuse dangerous operations in contexts where they should never happen.

```typescript
async function gitInit(directory: string) {
  if (process.env.NODE_ENV === 'test') {
    const target = normalize(resolve(directory));
    if (!target.startsWith(normalize(resolve(tmpdir())))) {
      throw new Error(`Refusing git init outside temp dir during tests: ${directory}`);
    }
  }
  // ...
}
```

**4. Debug logging.** Capture context for the next investigation.

```typescript
logger.debug('About to git init', { directory, cwd: process.cwd(), stack: new Error().stack });
```

## Applying it

1. Trace where the bad value originates and where it is used (see `root-cause-tracing.md`).
2. List every point the data passes through.
3. Add a check at each layer that warrants one.
4. Test each layer: bypass the first check and confirm the next one catches it.

## Example

An empty `projectDir` caused `git init` to run in the source directory. The data flowed: test setup returned `''`, then `Project.create(name, '')`, then `WorkspaceManager.createWorkspace('')`, then `git init` in `process.cwd()`.

Checks added: `Project.create()` validates the directory exists and is writable; `WorkspaceManager` rejects an empty `projectDir`; `WorktreeManager` refuses `git init` outside the temp directory during tests; a stack trace is logged before `git init`. During testing each layer caught a case the others missed: other code paths bypassed the entry check, and mocks bypassed the business-logic check.
