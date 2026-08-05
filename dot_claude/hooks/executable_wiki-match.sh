#!/bin/sh
# UserPromptSubmit hook — surface wiki pages whose slug appears in the prompt.
#
# Read side of the personal AI/LLM wiki. The write side is the wiki-harvest
# skill; the retrieval and citation discipline lives in the wiki-search skill.
# This script only makes the agent aware that pages exist.
#
# Tuned for precision, not recall. A false positive is noise on every prompt;
# a miss is picked up by the wiki-search skill's own description trigger.
#
# Never blocks: every failure path exits 0 with no output.

set -u

CACHE="$HOME/.claude/cache/wiki-path"

# chezmoi is the single source of truth for the wiki path, but it costs
# 10s-100s of ms and this runs on every prompt — so resolve once and cache.
# Delete the cache file to re-resolve.
resolve_wiki() {
	if [ -s "$CACHE" ]; then
		cat "$CACHE"
		return 0
	fi
	path=$(chezmoi execute-template '{{ .wikiPath }}' 2>/dev/null) || return 1
	[ -n "$path" ] || return 1
	mkdir -p "$(dirname "$CACHE")" 2>/dev/null || return 1
	printf '%s' "$path" >"$CACHE" 2>/dev/null || return 1
	printf '%s' "$path"
}

WIKI=$(resolve_wiki) || exit 0
INDEX="$WIKI/wiki/index.md"
[ -r "$INDEX" ] || exit 0

INPUT=$(cat)
PROMPT=$(printf '%s' "$INPUT" | jq -r '.prompt // ""' 2>/dev/null) || exit 0
[ -n "$PROMPT" ] || exit 0

# Inside the wiki repo the agent already has index.md and CLAUDE.md at hand.
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // ""' 2>/dev/null)
[ -n "$CWD" ] || CWD="$PWD"
case "$CWD" in
"$WIKI" | "$WIKI"/*) exit 0 ;;
esac

# Slugs are English kebab-case by convention, so both the hyphenated form and
# the spaced form are plausible in a prompt: "speculative-decoding" and
# "speculative decoding". Match case-insensitively as fixed strings.
MATCHES=$(PROMPT="$PROMPT" awk '
BEGIN {
	p = tolower(ENVIRON["PROMPT"])
	gsub(/[\n\r\t]/, " ", p)
	total = 0
	kept = 0
	LIMIT = 5
}
{
	# The dot in the class is what makes dotted source stems reachable
	# ("arxiv-2302.01318.md"); without it those pages are invisible here.
	if (match($0, /\]\([a-z0-9.-]+\.md\)/) == 0) next
	slug = substr($0, RSTART + 2, RLENGTH - 6)
	# Short slugs match too much of ordinary prose to be worth the noise.
	if (length(slug) < 4) next
	spaced = slug
	gsub(/-/, " ", spaced)
	if (index(p, slug) == 0 && index(p, spaced) == 0) next
	total++
	if (kept < LIMIT) {
		kept++
		line[kept] = $0
	}
}
END {
	if (kept == 0) exit 0
	for (i = 1; i <= kept; i++) print line[i]
	if (total > kept) printf "(+%d more in the index)\n", total - kept
}
' "$INDEX" 2>/dev/null) || exit 0

[ -n "$MATCHES" ] || exit 0

printf '%s\n' "$MATCHES" | jq -Rs '{
	hookSpecificOutput: {
		hookEventName: "UserPromptSubmit",
		additionalContext: (
			"[wiki] The personal AI/LLM wiki already holds pages on this topic:\n"
			+ .
			+ "\nUse the wiki-search skill to read the bodies and cite them before answering from your own knowledge. Do not treat these one-line index summaries as evidence.\n"
		)
	}
}' 2>/dev/null || exit 0
