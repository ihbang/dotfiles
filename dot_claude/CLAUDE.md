# Global instructions

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## Language of what I write

Three rules, in priority order.

### 1. Editing an existing file — follow the language already there

Match the file's current language, even where rule 2 would have picked the other one for a
new file. A repo's stated convention counts as "already there" (model-profiler, for instance:
"Code comments in English; user-facing docs (README) in Korean"). Never translate surrounding
content as a side effect of an edit — that is not a surgical change.

### 2. New prose/markdown — Korean by default, English only when agent-only

- **English** — files that exist *only* so an agent can read them: anything under `~/.claude/`
  (this file, `rules/`, auto-memory in `projects/*/memory/`), scratchpad working notes,
  `docs/agents/`, skill definitions.
- **Korean** — everything else, i.e. anything a human reads or edits: README, `docs/`,
  `CONTEXT.md`, a repo's own `CLAUDE.md`, ADRs, plans, hand-off notes, PR/issue bodies and
  templates.

A file that serves both audiences (a repo `CLAUDE.md`, a plan the user reviews) is **not**
agent-only — write Korean.

### 3. Inside source code — English, everything

Comments, docstrings, identifiers, log and error messages. No Korean in code files, whatever
language that repo's docs are in.

### 4. Commit messages — English

Subject and body both, in every repository. PR titles and bodies are not covered here: the
title is governed by the Conventional Commits rule, the body by rule 2.

Applies to **file content only** — conversation stays in the user's language.

## Never commit the `## Agent skills` block in CLAUDE.md

Every repo's `CLAUDE.md` may end with an `## Agent skills` section — the per-repo config
written by `mattpocock-skills:setup-matt-pocock-skills` (issue-tracker / triage-labels /
domain-docs pointers into `docs/agents/`). **That section is local-only. It must never enter
a commit, on any project.**

Rules:

- Never `git add` / `git commit` a `CLAUDE.md` diff whose only change is that block, or any
  part of it. If the block is the only change, leave `CLAUDE.md` modified — a permanently
  dirty `CLAUDE.md` is the intended steady state, not a problem to clean up.
- When `CLAUDE.md` has *other* changes that do belong in the commit, stage a copy with the
  block stripped, then restore the local file (interactive `git add -p` is unavailable):

  ```bash
  cp CLAUDE.md /tmp/CLAUDE.local.md                 # keep the local copy (with the block)
  sed -i '/^## Agent skills$/,$d' CLAUDE.md         # strip block .. EOF from the staged version
  printf '%s\n' "$(cat CLAUDE.md)" > CLAUDE.md      # drop the trailing blank line the strip leaves
  git add CLAUDE.md && git commit -m "..."
  cp /tmp/CLAUDE.local.md CLAUDE.md                 # restore the block locally
  ```

  Verified round-trip: without the `printf` step the stripped file differs from the committed
  version by exactly one trailing blank line.
- `docs/agents/` (the files the block points at) is local-only too. Keep it out of the repo
  via `.git/info/exclude`, **not** `.gitignore` — the exclude file is itself uncommitted, so
  the team's ignore list stays untouched:

  ```bash
  printf '\n# mattpocock-skills per-repo config (local-only)\n/docs/agents/\n' >> .git/info/exclude
  ```

  `.gitignore` cannot cover `CLAUDE.md` anyway (ignore rules apply to untracked files only),
  which is why the block needs the staging workaround above while `docs/agents/` needs a
  plain exclude entry.
- Never suggest deleting the block instead of excluding it — the skills read it at runtime.
- If a repo already has the block committed (inherited from someone else), leave it alone;
  this rule governs commits *I* make, not history rewrites.
- Alternative when a repo wants zero `CLAUDE.md` churn: move the block into a git-ignored
  file (e.g. `CLAUDE.local.md`) and reference it from `CLAUDE.md` with an `@CLAUDE.local.md`
  import line — do this only when the user asks for it.
