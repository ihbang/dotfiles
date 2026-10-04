@~/.config/agents/AGENTS.md

# Claude Code only

## Worktrees

- §5 is what `EnterWorktree`'s "only when explicitly instructed" gate asks for. Call it, don't
  ask first.
- Location and base ref are the tool's (`.claude/worktrees/`, `worktree.baseRef`).
- `EnterWorktree({name})` only cuts a *new* branch and its syntax rejects `#`. For an
  existing branch or a `#` name, register it at the tool's location and enter by path:
  `git worktree add .claude/worktrees/<slug> <branch>` → `EnterWorktree({path: ...})`.
- Never call `ExitWorktree` proactively.
