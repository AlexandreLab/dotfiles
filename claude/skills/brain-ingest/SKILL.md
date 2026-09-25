---
name: brain-ingest
description: Ingests a new source document into a project's brain wiki. Reads the source, creates a source summary page, updates the relevant knowledge pages (per the wiki's own schema), updates the index, appends to the log, and refreshes hot.md. Use when the user says /ingest, "ingest <file>", or "add to brain <file>".
---

# Brain Ingest

You are acting as a disciplined wiki maintainer. Your job is to integrate a new source document into the project's persistent brain wiki.

> **Throughout this skill, `<BRAIN>` is the resolved brain root from Step 0.** Every
> path written below as `brain/...` means `<BRAIN>/...`. Do not assume a fixed
> location, and do not assume a fixed page taxonomy – **the schema in
> `<BRAIN>/CLAUDE.md` is authoritative** (some brains use domain folders like
> `market/ customer/ brand/ product/ finance/ strategy/`, others use
> `entities/ concepts/`). Load it in Step 1 and follow it exactly.

---

## Step 0 – Locate the brain root, then parse the argument

**First, resolve `<BRAIN>`** (the wiki root) in this order:
1. If `knowledge_base/brain/CLAUDE.md` exists → `<BRAIN>` = `knowledge_base/brain/`.
2. Else if `brain/CLAUDE.md` exists → `<BRAIN>` = `brain/`.
3. Else search the project for a `CLAUDE.md` that is a brain schema and use its directory; if none, stop and tell the user no brain wiki was found.

Announce the resolved root, e.g. "Brain root: `knowledge_base/brain/`."

**Then parse the argument.**

The user has provided a file reference. It may be:
- A filename only: `loste-strategy-report.md`
- A path relative to the project root: `strategy/Loste.md`
- A path relative to `brain/raw/`: `raw/loste-strategy-report.md`
- An absolute path

**Resolution order:**
1. If the path resolves directly as given – use it.
2. If not, check `brain/raw/<argument>`.
3. If not, search the project for a file matching the name.
4. If still not found, stop and tell the user the exact path you looked in.

---

## Step 1 – Load wiki context (read these files before anything else)

Read all three of these files before touching anything:

1. `brain/CLAUDE.md` – the schema. This defines page formats, conventions, and rules. You must follow it exactly.
2. `brain/index.md` – the current catalog of all pages. Use this to know what already exists before creating new pages.
3. `brain/wiki/hot.md` – session state. Understand what was recently touched and what is in flight.

---

## Step 2 – Copy source to brain/raw/ (if not already there)

If the source file is not already inside `brain/raw/`, copy it there now.
- Use a lowercase, hyphen-separated slug for the filename: `loste-strategy-report.md`, not `Loste_strategy_report.md`.
- Never modify the file after copying. `brain/raw/` is immutable.

Announce to the user: "Copied to `brain/raw/<slug>.md`." or "Already in `brain/raw/`."

---

## Step 3 – Read the source

Read the full source file. If it is longer than 2000 lines, read it in sequential chunks (offset + limit) until you have covered the whole document. Do not proceed until you have read the entire source.

---

## Step 4 – Discuss key takeaways (if in interactive session)

Briefly summarize to the user:
- What this source is about (1–2 sentences).
- The 3–5 most important facts or claims for the wiki.
- Which existing pages it will likely update.
- Which new pages it will likely create.

Ask: "Ready to proceed with the ingest?" and wait for confirmation before writing any files.

If the user has already said "just do it", "proceed", "yes", or equivalent, skip confirmation and proceed.

---

## Step 5 – Write the source summary page

File: `brain/wiki/sources/<slug>.md`

Use the source page format from `brain/CLAUDE.md`. Include:
- Frontmatter: `title`, `source`, `ingested` (today's date), `tags`, `entities`, `concepts`
- `## Summary` – 40–60 words
- `## Key takeaways` – bullet list
- `## Connections` – links to every entity and concept page this source creates or updates

If a source page for this slug already exists, update it rather than overwriting.

---

## Step 6 – Update the knowledge pages (per the wiki's schema)

For every entity, concept, or topic the source touches, create or update its page
**in the folder structure `<BRAIN>/CLAUDE.md` defines** – do not force an
entity/concept split if the schema uses domain folders (or vice versa). Choose the
page's home the way the schema says (for a domain-folder wiki, ask "what business
function does this inform?": `market` / `customer` / `brand` / `product` /
`finance` / `strategy`).

Discipline for each page:
- If the page already exists: open it, read it, then integrate the new information under the appropriate section. **Never overwrite what is already there – extend it.** Append to the `sources:` frontmatter.
- If it does not exist: create it using the page format for that folder from `<BRAIN>/CLAUDE.md`.
- Update the `updated:` date.
- Add `[[Connections]]` back to the source page and across related pages.

Things to look for: named products, customer archetypes, competitors, creators,
platforms, named people (entities); and frameworks, strategies, market dynamics,
mental models (concepts). A single source commonly touches 5–15 pages – do all of them.

---

## Step 7 – Update overview.md (if the synthesis changes)

Read `brain/wiki/overview.md`. If this source changes the big picture – adds a new strategic insight, contradicts an existing claim, introduces a major new entity or concept – update the relevant section.

If nothing at the overview level changes, leave it untouched.

---

## Step 8 – Update index.md

Open `brain/index.md`. For every page created or significantly updated:
- Add a new entry in the correct category section, or
- Update the one-line summary of an existing entry.

Entry format: `- [Page title](wiki/path/to/page.md) – one-line summary`

Do not re-sort or reformat entries beyond what you touched.

---

## Step 9 – Append to log.md

Open `brain/log.md`. Add a new entry at the **top** (newest first):

```
## [YYYY-MM-DD] ingest | <source title>

<One sentence: what was ingested and what changed. Number of pages created/updated.>
```

---

## Step 10 – Update hot.md

Rewrite `brain/wiki/hot.md` to reflect the current state:
- **Current focus:** what was just ingested.
- **Last operation:** `ingest | <source title>` – today's date.
- **Active pages:** 3–7 pages just created or updated (with `[[links]]`).
- **Key facts in play:** 3–5 bullet points that matter for the next session.
- **Next steps:** what would be the most valuable next ingest or query.

Hard limit: 500 words.

---

## Completion report

After all files are written, report to the user:

```
Ingest complete.

Source: brain/raw/<slug>.md
Pages created: <list>
Pages updated: <list>
index.md: updated
log.md: appended
hot.md: updated
```

Then suggest the next most valuable source to ingest, based on open questions now visible in the wiki.
