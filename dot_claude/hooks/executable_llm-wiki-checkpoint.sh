#!/usr/bin/env bash
# PreToolUse/PostToolUse(Bash): one Git checkpoint per claude-obsidian transaction in llm-wiki.
#
# pre:  deny a `transaction apply` while the vault has uncommitted changes, i.e. while an
#       earlier transaction still waits for its checkpoint. Stacking a second apply on top makes
#       the earlier one uncheckpointable (the checkpoint tool reports TRANSACTION_DRIFT).
# post: after an apply prints `"status": "complete"`, tell the model to checkpoint it now.
#
# A --vault given as a literal path other than llm-wiki opts out. A --vault given through a
# shell variable cannot be resolved here, so it counts as llm-wiki.

mode=$1
vault="${LLM_WIKI_VAULT:-$HOME/Documents/llm-wiki}"
input=$(cat)
cmd=$(jq -r '.tool_input.command // ""' <<<"$input")

printf '%s' "$cmd" | grep -Eq 'claude-obsidian.*transaction +apply' || exit 0

arg=$(printf '%s' "$cmd" | grep -oE -- '--vault[= ]+[^ ;&|]+' | head -1 |
  sed -E "s/^--vault[= ]+//; s/^[\"']//; s/[\"']\$//")
case "$arg" in
  '' | *'$'*) ;;
  *) [ "$(realpath -m "${arg/#\~/$HOME}")" = "$(realpath -m "$vault")" ] || exit 0 ;;
esac
git -C "$vault" rev-parse --git-dir >/dev/null 2>&1 || exit 0

if [ "$mode" = pre ]; then
  dirty=$(git -C "$vault" status --porcelain --untracked-files=all)
  [ -z "$dirty" ] && exit 0
  since=$(git -C "$vault" log -1 --format=%ct)
  pending=$(for d in "$vault"/.vault-meta/transactions/*/; do
    [ -f "$d/checkpoint.json" ] && continue
    [ "$(stat -c %Y "$d")" -gt "$since" ] && basename "$d"
  done)
  jq -n --arg vault "$vault" --arg dirty "$dirty" --arg pending "${pending:-none found}" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: ("[llm-wiki] One checkpoint per transaction: the vault has uncommitted changes, so an earlier transaction is not checkpointed yet. Run `claude-obsidian.py checkpoint <operation_id> --vault " + $vault + "` for it, then retry this apply. If the changes did not come from a transaction, ask the user.\nTransactions without a checkpoint since the last commit: " + $pending + "\nUncommitted paths:\n" + $dirty)
    }}'
  exit 0
fi

out=$(jq -r '.tool_response | if type == "object" then (.stdout // "") else tostring end' <<<"$input")
printf '%s' "$out" | grep -Eq '"status": *"complete"' || exit 0
op=$(printf '%s' "$out" | grep -oE '"operation_id": *"[^"]+"' | head -1 | cut -d'"' -f4)
type=$(printf '%s' "$out" | grep -oE '"operation_type": *"[^"]+"' | head -1 | cut -d'"' -f4)
[ -n "$op" ] || exit 0
[ -f "$vault/.vault-meta/transactions/$op/checkpoint.json" ] && exit 0
jq -n --arg vault "$vault" --arg op "$op" --arg type "${type:-operation}" --arg today "$(date -u +%F)" '{
  hookSpecificOutput: {
    hookEventName: "PostToolUse",
    additionalContext: ("[llm-wiki] Transaction " + $op + " applied. Checkpoint it now, before any other vault write: `claude-obsidian.py checkpoint " + $op + " --vault " + $vault + " --as-of " + $today + " --message \"wiki: " + $type + " " + $op + "\"`, adding this session'"'"'s commit trailer to the message. One checkpoint per transaction.")
  }}'
