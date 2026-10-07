#!/usr/bin/env python3
# chezmoi modify script: set the [tui] status line, preserve everything else.
# Codex writes project trust levels and hook hashes into the same file, so only
# the managed keys are rewritten, in place, and every other line passes through.
import re
import sys

# Closest built-in items to ~/.claude/awesome-statusline.sh. Codex has no
# command-based status line, so the item ids are all it can be given.
STATUS_LINE_ITEMS = [
    "model-with-reasoning",
    "current-dir",
    "project-name",
    "git-branch",
    "branch-changes",
    "context-used",
    "five-hour-limit",
    "weekly-limit",
]

MANAGED = {
    "status_line": "[" + ", ".join(f'"{item}"' for item in STATUS_LINE_ITEMS) + "]",
    "status_line_use_colors": "true",
}
MANAGED_LINES = [f"{key} = {value}" for key, value in MANAGED.items()]

TABLE_HEADER = re.compile(r"\s*\[")
TUI_HEADER = re.compile(r"\s*\[tui\]\s*(#.*)?$")
MANAGED_KEY = re.compile(r"\s*(" + "|".join(MANAGED) + r")\s*=\s*(.*)$")

output = []
in_tui = False
found_tui = False
skipping_array = False
for line in sys.stdin.read().splitlines():
    if skipping_array:
        skipping_array = "]" not in line
        continue
    if TUI_HEADER.match(line):
        output.append(line)
        output.extend(MANAGED_LINES)
        in_tui = found_tui = True
        continue
    if TABLE_HEADER.match(line):
        in_tui = False
    elif in_tui and (match := MANAGED_KEY.match(line)):
        value = match.group(2)
        skipping_array = value.startswith("[") and "]" not in value
        continue
    output.append(line)

if not found_tui:
    if output:
        output.append("")
    output.append("[tui]")
    output.extend(MANAGED_LINES)

print("\n".join(output))
