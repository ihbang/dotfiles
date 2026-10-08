---
name: llm-wiki
description: "LLM inference knowledge store at ~/Documents/llm-wiki: serving engines (vLLM, SGLang), scheduling, KV cache and offloading, speculative decoding, sparse attention, GPU and model specs. Use to look up a fact before relying on memory, and to propose a correction or addition when your work contradicts or extends it."
---

# llm-wiki

The vault is `~/Documents/llm-wiki`. Its `AGENTS.md` holds the layout, the lookup procedure and the
trust rules; read it before the first lookup in a session.

## Look up

1. Read `~/Documents/llm-wiki/AGENTS.md`, then `wiki/index.md`, and pick pages by their summaries.
   For a term, `rg -i '<term>' ~/Documents/llm-wiki/wiki/`.
2. On a page, read `## Summary`, then `## Pitfalls` before using any number from it. Compare the
   page's `valid_for` with the version you are working on.
3. When a fact shapes your work, cite the page path and its claim ID. Re-check against the code or
   source in front of you before relying on a fact pinned to another version, a `provisional` or
   `contested` claim, or anything listed under `## Pitfalls`.

## Propose

When your work shows that a wiki fact is wrong, stale for a newer version, or missing, write one
proposal file per fact to `~/Documents/llm-wiki/inbox/proposals/<YYYYMMDD>-<slug>.md`.

- Give evidence another agent can reopen: a commit SHA with `path:line`, a URL, or the absolute path
  of a file the vault can capture.
- The proposal file is your only write in the vault. A session opened in the vault verifies and
  files it with `wiki-ingest`. Tell the user a proposal is waiting.

```markdown
---
kind: correction | addition | gap
target: [wiki/topics/<page>.md]
origin: <project or repo>, <YYYY-MM-DD>
---

## Proposal

<the fact as the wiki should state it, with its scope and version>

## Evidence

- <locator>: <what it shows>

## Current wiki text

<the line it contradicts, quoted; omit for an addition>
```
