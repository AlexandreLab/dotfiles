# Testing anti-patterns

Read this when writing or changing tests, adding mocks, or considering a method that only tests would call.

Mocks isolate the code under test from things that are slow, external or non-deterministic. They are not the thing being tested. Each pattern below is a way a test ends up checking the mock, or the test setup, instead of the code.

## 1. Asserting on the mock

```typescript
// Bad: passes as long as the mock renders
test('renders sidebar', () => {
  render(<Page />);
  expect(screen.getByTestId('sidebar-mock')).toBeInTheDocument();
});

// Better: render the real sidebar and check what the user sees
test('renders sidebar', () => {
  render(<Page />);
  expect(screen.getByRole('navigation')).toBeInTheDocument();
});
```

The first test tells you the mock exists, not that the page works. If the sidebar has to be mocked for isolation, assert on the page's own behaviour with the sidebar present, not on the mock.

Before asserting on a mocked element, ask whether the assertion would still mean something if the mock were removed.

## 2. Test-only methods on production classes

```typescript
// Bad: destroy() exists only so tests can clean up
class Session {
  async destroy() {
    await this._workspaceManager?.destroyWorkspace(this.id);
  }
}
afterEach(() => session.destroy());

// Better: cleanup lives with the tests
export async function cleanupSession(session: Session) {
  const workspace = session.getWorkspaceInfo();
  if (workspace) await workspaceManager.destroyWorkspace(workspace.id);
}
afterEach(() => cleanupSession(session));
```

A test-only method looks like public API, can be called by accident in production, and often sits on a class that does not own the resource. Put it in test utilities, and check which class actually owns the lifecycle.

## 3. Mocking without knowing what the test depends on

```typescript
// Bad: the mock also removes the config write the test relies on
test('detects duplicate server', async () => {
  vi.mock('ToolCatalog', () => ({
    discoverAndCacheTools: vi.fn().mockResolvedValue(undefined),
  }));
  await addServer(config);
  await addServer(config); // should throw, but no longer does
});

// Better: mock only the slow part
test('detects duplicate server', async () => {
  vi.mock('MCPServerManager'); // skips server startup only
  await addServer(config); // config is written
  await addServer(config); // duplicate detected
});
```

Before mocking a method, list its side effects and check whether the test needs any of them. If you are not sure, run the test against the real implementation first, see what has to happen, then mock at the lowest level that removes the slow or external part. "Mock it to be safe" usually breaks the behaviour under test.

## 4. Partial mock data

```typescript
// Bad: only the fields this test reads
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' },
};
// Downstream code later reads response.metadata.requestId and fails

// Better: mirror the real response shape
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' },
  metadata: { requestId: 'req-789', timestamp: 1234567890 },
};
```

A partial mock encodes your assumptions about which fields matter. Tests pass while integration fails. Build mock data from the real schema, documentation or a recorded response, and include every field that downstream code might read.

## 5. Tests written after the fact

Code reported as done with tests "to follow" has not been verified. Testing is part of implementing: write the failing test, make it pass, refactor, then call it done.

## When mocks get too complex

Signs that a mock is costing more than it saves:

- the mock setup is longer than the test logic;
- the test breaks when the mock changes but not when the code does;
- the mock is missing methods the real component has;
- you cannot say why the mock is needed.

At that point an integration test with real components is often simpler and more trustworthy.

## Quick reference

| Pattern | Fix |
|---|---|
| Asserting on mock elements | Test the real component, or assert on the caller's behaviour |
| Test-only methods in production | Move them to test utilities |
| Mocking without understanding | Find the side effects first, mock at the lowest level |
| Partial mock data | Mirror the real schema |
| Tests after the fact | Write the failing test first |
| Over-complex mocks | Use an integration test |
