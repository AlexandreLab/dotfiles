---
name: applying-engineering-standards
description: Use for architecture or trade-off decisions that are significant or hard to reverse, and when the user asks for a 4-gate review (architecture, code quality, tests, performance).
---

# Engineering standards

Engineering posture and priority order live in AGENTS.md, and debugging belongs to `systematic-debugging`. This skill adds the design rules, the review gates and the decision protocol.

## Design rules

- **Deterministic by design.** Pass values in as parameters or read them from config rather than deriving them at runtime, and document any default where it is defined. The same input should give the same output, with side effects explicit and isolated, so behaviour can be reproduced and tested.
- **Generic by default.** Keep environment-specific values, personal identifiers, local paths and account IDs out of application code and AI workflows; put them in configuration. Hardcoded values break the project for the next contributor or machine.
- **Engineered enough.** Neither fragile nor prematurely abstracted. Start with the simpler option and add structure when a real second use or failure justifies it.
- **Docs are part of the change.** Update docs when behaviour, interfaces or configuration change, or say what is left and why, because a follow-up note is easy to lose once the conversation moves on.

## The 4-gate review

Run the gates in this order, because a performance or style finding is wasted effort if the architecture underneath is about to change. Finish each gate before starting the next. If the user wants a quick review, say which gates you are shortening and why.

1. **Architecture:** component boundaries, coupling and dependency direction, data flow and bottlenecks, single points of failure, and security boundaries (auth, data access, API edges).
2. **Code quality:** module structure, duplication worth removing, error handling and missed edge cases, debt hotspots, and areas that are over- or under-engineered.
3. **Tests:** coverage gaps across unit, integration and end-to-end, assertion strength, and failure paths no test exercises.
4. **Performance:** N+1 queries and database access patterns, memory use, caching opportunities, and slow or high-complexity paths.

For each finding give the file and line, the problem, and a proposed fix. End with a summary ranked by severity.

## Decision protocol

Use this for choices that are significant or hard to reverse: a new dependency, a schema or public interface, a data model, a change of approach mid-task.

1. **Problem:** state it concretely, with file and line references where they exist.
2. **Options:** two or three, including "do nothing" when that is reasonable. Present "do nothing" fairly rather than as a straw man.
3. **Trade-offs:** for each option, effort, risk, effect on nearby code and ongoing maintenance. Weigh your preferred option as hard as the others; if it seems to have no downside, look again, because that is where optimism bias hides.
4. **Recommendation:** pick one and say which principle decides it.
5. **Who decides:** if the choice turns on something only the user knows (product intent, budget, timeline, risk appetite) or cannot be undone, ask and name the specific option you are asking them to approve. Otherwise proceed with the recommendation and record the reasoning where the next reader will find it, such as the PR description or an ADR.
