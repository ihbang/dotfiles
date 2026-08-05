---
name: wiki-search
description: Answer from the personal AI/LLM engineering wiki instead of from memory, with citations. Use whenever a session outside the wiki repo touches LLM inference or serving — speculative decoding, draft models, KV cache, quantization, attention cost, batching and dispatch overhead, throughput/latency tradeoffs, vLLM/SGLang/TensorRT-LLM, benchmark numbers, GPU utilization — or when a [wiki] hook message says pages on the topic exist. Also fires on "위키에 뭐 있어", "위키 찾아봐", "wiki에서 확인", "check the wiki".
---

Read side of the personal wiki. The write side is the `wiki-harvest` skill; nothing here
writes to the wiki.

Wiki root — called WIKI below. Resolve it before doing anything else:

    chezmoi execute-template '{{ .wikiPath }}'

chezmoi prompts for this path on a new machine and keeps it in its own config, which is the
single source of truth. `$HOME/.claude/cache/wiki-path` also holds it, but that file is the
`wiki-match.sh` hook's own cache — read it only as a fallback, and delete it if it looks stale.

If both fail, or the resolved directory does not exist, say so and stop rather than guessing at
another location. On a machine carrying these dotfiles, `chezmoi apply` clones the wiki, so a
missing directory means apply has not run yet.

If this session is *already* inside the wiki repo, stop and use the wiki's own `ask` skill. This
skill exists to cross a repo boundary; inside the wiki it adds nothing.

Every path you touch must be absolute. The working directory belongs to the other project.

## 1. Search

Start from `WIKI/wiki/index.md` to see what exists, then grep `WIKI/wiki/` for the terms.

**Read the pages that matter. The index is a catalog, not evidence** — and a `[wiki]` hook
message carries index lines only, so it tells you a page exists and nothing more. Answering
from those one-liners is the main way this skill goes wrong.

Slug matching is narrow on purpose, so the hook misses pages a human would call relevant.
Grep for the concept, not just the slug you were handed.

## 2. Answer

- Cite the page behind each claim. Give the page title and its filename — a relative markdown
  link is meaningless from another repository, so write it as `` `speculative-decoding.md` ``.
- When a claim traces to a `source` page, name the original it came from.
- A page whose `sources` list contains `wiki/` paths is **derived**. Do not cite it as primary
  evidence; follow it to the pages it came from.
- Flag any page you relied on whose `reviewed` date is old enough to matter for the question.
- **If the wiki does not cover it, say so plainly and do not fill the gap from your own
  knowledge.** Answer from your own knowledge if that is what is useful, but label which part
  is the wiki's and which part is yours. The gap itself is the finding — name the source that
  would close it.

These four rules restate `WIKI/CLAUDE.md`, which stays the single source of truth. Read that
file if they seem to disagree with it, or before doing anything beyond reading.

## 3. Do not write

Not the answer as a new page, not a correction to a page you found wrong, not an index entry.
If the session produced something the wiki should hold, say so in one line and let
`wiki-harvest` handle it at the end of the session — that skill owns the triage, the redaction
rules for what must not cross the repo boundary, and the approval gate.
