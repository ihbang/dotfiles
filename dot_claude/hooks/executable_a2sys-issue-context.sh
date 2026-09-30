#!/usr/bin/env bash
# PreToolUse(Bash): when a Bash call creates an issue in an a2sys-platform repository,
# inject the issue-tracking rules so the new issue is attached to its Epic and board fields.
#
# Matches `gh issue create`, and `gh api` POSTs to the create endpoint (`.../issues` followed
# by a title or an --input body). Reads/sub-issue calls (`.../issues/<n>/...`, `?query`) pass.

doc="$HOME/.claude/references/a2sys-issue-tracking.md"
cmd=$(jq -r '.tool_input.command // ""')

creates_issue() {
  printf '%s' "$cmd" | grep -Eq '(^|[;&|(] *)gh +issue +create' && return 0
  printf '%s' "$cmd" | grep -Eq "gh +api .*repos/[^/ ]+/[^/ ]+/issues([ '\"]|$)" &&
    printf '%s' "$cmd" | grep -Eq -- '--input|title='
}

targets_a2sys() {
  printf '%s' "$cmd" | grep -q 'a2sys-platform' && return 0
  git remote get-url origin 2>/dev/null | grep -q 'a2sys-platform'
}

creates_issue && targets_a2sys || exit 0

jq -Rs '{hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext:
  ("[A2SYS tracking] creating an issue: attach it to its Epic and set its Serving Board fields. Full text: ~/.claude/references/a2sys-issue-tracking.md\n" + .)}}' "$doc"
