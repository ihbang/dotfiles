---
name: wiki-harvest
description: Harvest a work session's durable knowledge into the personal AI/LLM wiki at ~/Workspace/Wiki — documents read, things learned, measurements taken, decisions and their reasoning. Use when the user is wrapping up a session and wants findings reflected into the wiki ("세션 정리", "wiki에 반영", "wrap up", "record what we learned"). Only on an explicit request; never fire on your own at the end of a task.
---

Wiki root: `$HOME/Workspace/Wiki` — called WIKI below. Resolve it before use and stop if it does
not exist; do not guess at another location.

## Before anything

Read `WIKI/CLAUDE.md`. This session is almost certainly running in a different repository, so
the wiki's conventions are not loaded. Page types, the frontmatter schema, file naming, linking,
and the language rules all live in that file and are not restated here.

Then:

- `git -C WIKI status --short` — if the tree is dirty, stop and report. Do not fold your commit
  into work someone else left in progress.
- If this session is *already* in the wiki repo, stop and use the wiki's own `ingest` skill.
  This skill exists to cross a repo boundary; inside the wiki it adds nothing.

Every path you touch must be absolute. The working directory belongs to the other project.

## 1. Triage — and expect to find nothing

**Most sessions produce nothing durable, and writing nothing is the correct outcome.** A session
that fixed a bug, wired up config, chased a deploy, or renamed things has no place in a knowledge
wiki. Say so plainly and stop. A skill that always finds something to write turns the wiki into
noise, which is worse than leaving it alone.

Sort what actually happened into four buckets.

**External documents actually read** — papers, vendor docs, specs, release notes. These have
originals worth archiving, so run each through the wiki's `ingest` flow properly and let `raw/`
get the real file. Re-fetch them; do not write a summary from what you remember of the session.

**Domain knowledge** — something now understood about the field that the wiki does not say, or
that contradicts what it does say. A correction to an existing page is worth more than a new
page, so look for contradictions before reaching for a new file.

**Measurements and observations from your own work** — a benchmark that was run, a failure mode
that was reproduced, a version boundary that was hit, a config that behaved differently than
documented. This is the highest-grade evidence the wiki can hold: primary data rather than a
vendor's qualitative claim. Keep whatever makes the number meaningful — workload shape, hardware,
versions, batch size, concurrency — and drop everything that identifies the project.

**Everything else** — drop it. List each dropped item in one line so the judgement is visible
and can be overridden.

## 2. What must not cross the boundary

The wiki is a personal knowledge repo, not a work record. Strip before writing anything:

- project, service, customer, team, and repo names; ticket IDs; internal document links
- internal hostnames, cluster names, namespaces, bucket names, any URL not publicly reachable
- credentials, tokens, keys, connection strings — no exceptions, including ones that look redacted

And never generalise something that was not read, run, or measured. An untested hypothesis is not
a finding. If it matters, it goes in the session note as an open question, not onto a concept page
as a claim.

## 3. Plan, then stop

Report and wait for approval. Do not write yet.

1. What landed in each bucket.
2. Pages to create or edit, one line of reasoning each.
3. Contradictions with what the wiki already claims — quote the existing page.
4. What was dropped, and why.

## 4. Write

Write the session note first, as a raw source:
`WIKI/raw/session-YYYY-MM-DD-<slug>.md`

It holds the distilled findings, each measurement with the conditions that make it meaningful,
and any open questions. Nothing else — it is not a transcript and not a work log.

This is not a workaround for the missing original. Measurements taken in the session *are* the
primary record, so they earn `raw/` more honestly than a vendor doc does. It also means no
convention has to bend: the note gets a `source` page at the matching stem, every claim traces to
a file, and the existing lint rules apply as written.

Then follow the ingest procedure in `WIKI/CLAUDE.md` — source page, the concept/entity/comparison
pages from the approved plan, inbound links from related pages, `wiki/index.md` entries, and a
`## [YYYY-MM-DD] ingest | <title>` block prepended to `wiki/log.md`.

Use `ingest` as the log prefix. A session note is simply a new source entering the wiki; inventing
a fourth prefix would break the grep contract that `CLAUDE.md` defines.

Finish with:

    git -C WIKI add -A
    git -C WIKI commit
    git -C WIKI push

`git` needs the sandbox disabled on this machine.
