# Global instructions

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

Shared by every coding agent: Claude Code reads this file through `~/.claude/CLAUDE.md`, Codex as
`$CODEX_HOME/AGENTS.md`. Tool-specific rules live in each tool's own file.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

**Writing rules here:** terse bullets, the rule itself only. No rationale paragraphs, no
worked examples unless the rule is unusable without one.

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

## 5. Always Work in a Worktree

**Code work in a git repository happens in a worktree. Never edit the primary checkout.**

- Scope: any edit to tracked files. Exempt: read-only work, and files outside a repo
  (`~/.claude/`, `~/.codex/`, scratchpad, `/tmp`).
- Location and base ref are the agent tool's own worktree mechanism's. Never `../` or anywhere
  else.
- Branch name follows the repository's convention, not one I invent. a2sys-platform:
  `<type>/#<issue>-<short-description>`, and no branch without an issue.
- Uncommitted work in the primary checkout does not carry over. Say so, let the user decide.
- Cleanup is the user's call.

## 6. Comments and Docstrings

**Names carry the meaning. A comment adds only what the code cannot show.**

- Name variables, functions and types so the code reads without comments.
- Don't explain in a comment or docstring what the code already makes clear.
- Say each thing once; don't repeat the same explanation in several places.
- When code is removed, remove its comments. Don't describe code that no longer exists, why it
  was removed included, unless a reader would otherwise get it wrong.
- Applies to what I write. Existing comments stay (§3) unless my change makes them false.

## Language of what I write

Three rules, in priority order.

### 1. Editing an existing file — follow the language already there

Match the file's current language, even where rule 2 would have picked the other one for a
new file. A repo's stated convention counts as "already there" (model-profiler, for instance:
"Code comments in English; user-facing docs (README) in Korean"). Never translate surrounding
content as a side effect of an edit — that is not a surgical change.

### 2. New prose/markdown — Korean by default, English only when agent-only

- **English** — files that exist *only* so an agent can read them: this file, anything under
  `~/.claude/` or `~/.codex/` (`rules/`, auto-memory in `projects/*/memory/`), scratchpad
  working notes, `docs/agents/`, skill definitions.
- **Korean** — everything else, i.e. anything a human reads or edits: README, `docs/`,
  `CONTEXT.md`, a repo's own `CLAUDE.md` or `AGENTS.md`, ADRs, plans, hand-off notes, PR/issue bodies and
  templates.

A file that serves both audiences (a repo `CLAUDE.md` or `AGENTS.md`, a plan the user reviews) is **not**
agent-only — write Korean.

### 3. Inside source code — English, everything

Comments, docstrings, identifiers, log and error messages. No Korean in code files, whatever
language that repo's docs are in.

### 4. Commit messages — English

Subject and body both, in every repository. PR titles and bodies are not covered here: the
title is governed by the Conventional Commits rule, the body by rule 2.

Applies to **file content only** — conversation stays in the user's language.

## Terminology and wording

Applies to everything I write: replies, docs, slides, commit messages, issue and PR text.

- Technical terms stay in their original form: each project's official term as written, and
  terms the industry uses in English (KV cache, continuous batching, attention). Never a Korean
  rendering. For these terms this overrides the output style's preference for settled Korean
  translations.
- When two projects name the same behavior differently, give both names and say they are the
  same behavior (vLLM `preemption`, SGLang `retraction`).
- Refer to a technical object by its name, not a metaphor or a broad word: `KV cache pool`
  (the space) or `가용 공간` (the amount still allocatable), not `자리`.
- Labels and headings use literal words, not metaphors: `오늘의 주제`, not `오늘의 지도`.
- A verb carries its object and names the actual operation: `KV block을 할당한다`, not
  `할당한다`; `입력이 들어갈 가용 공간이 있는지 확인한다`, not `센다`.
- One concept, one term, throughout a deck, document, or conversation.
- Name a state with a noun (`보호`), not an adjective (`보호된`). A name grouping several steps
  reuses the steps' name (steps named `조회` → group named `조회`).
- Acronyms in uppercase (FCFS, LPM, TTFT, ITL). A string used verbatim in code or config keeps
  its spelling (`scheduling_policy: fcfs`).
