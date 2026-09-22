#!/bin/bash
# ============================================================================
# Awesome Statusline - DEFAULT Mode
# ============================================================================
# Line 1: 🤖 Model | 🎨 Style | 📂 path 🌿(branch)✅
# Line 2: 🧠 Context bar % | 5H bar % (time) | 7D bar % (day)
# % numbers use gradient end color + Bold
# ============================================================================
# v2.1.1 - Updated from v2.1.0
# ============================================================================

# Ensure a bundled jq (copied next to this script by the installer) is found,
# even when Claude Code launches the statusline with a minimal PATH — common on
# Windows / GUI launches where a winget-installed jq is not on PATH yet.
export PATH="$(dirname "$0"):$PATH"

input=$(cat)

# Parse JSON input
MODEL=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // "."')
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
CURRENT_USAGE=$(echo "$input" | jq -r '.context_window.current_usage // null')
OUTPUT_STYLE=$(echo "$input" | jq -r '.output_style.name // ""')

# Rate limits (official API - available for Pro/Max subscribers)
FIVE_HOUR_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
FIVE_HOUR_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
SEVEN_DAY_PCT=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
SEVEN_DAY_RESET=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# ============================================================================
# Colors (variables instead of functions to avoid newline issues)
# ============================================================================
RESET="\033[0m"
BOLD="\033[1m"
CLR="\033[K" # Clear to end of line

C_TEAL="\033[38;2;148;226;213m"
C_PINK="\033[38;2;245;194;231m"
C_PEACH="\033[38;2;250;179;135m"
C_GREEN="\033[38;2;166;227;161m"
C_SUBTEXT="\033[38;2;166;173;200m"
C_LAVENDER="\033[38;2;180;190;254m"
C_YELLOW="\033[38;2;249;226;175m"
C_OVERLAY="\033[38;2;108;112;134m"
C_LATTE_GREEN="\033[38;2;64;160;43m"
C_LATTE_RED="\033[38;2;210;15;57m"
C_LATTE_YELLOW="\033[38;2;223;142;29m"
C_LATTE_PINK="\033[38;2;234;118;203m"
C_LATTE_SKY="\033[38;2;4;165;229m"
C_LATTE_BLUE="\033[38;2;30;102;245m"

# ============================================================================
# Gradient Functions
# ============================================================================
get_context_gradient_color() {
  local pct=$1
  local r g b
  if [[ $pct -lt 30 ]]; then
    local t=$((pct * 100 / 30))
    r=$((245 + (230 - 245) * t / 100))
    g=$((194 + (69 - 194) * t / 100))
    b=$((231 + (83 - 231) * t / 100))
  elif [[ $pct -lt 70 ]]; then
    local t=$(((pct - 30) * 100 / 40))
    r=$((230 + (210 - 230) * t / 100))
    g=$((69 + (15 - 69) * t / 100))
    b=$((83 + (57 - 83) * t / 100))
  else
    r=210
    g=15
    b=57
  fi
  echo "$r;$g;$b"
}

# 5H: Mocha Lavender → Latte Blue → Latte Red
get_usage_gradient_color() {
  local pct=$1
  local r g b
  if [[ $pct -lt 50 ]]; then
    local t=$((pct * 2))
    r=$((180 + (30 - 180) * t / 100))
    g=$((190 + (102 - 190) * t / 100))
    b=$((254 + (245 - 254) * t / 100))
  else
    local t=$(((pct - 50) * 2))
    r=$((30 + (210 - 30) * t / 100))
    g=$((102 + (15 - 102) * t / 100))
    b=$((245 + (57 - 245) * t / 100))
  fi
  echo "$r;$g;$b"
}

# 7D: Mocha Yellow → Latte Peach → Latte Red
get_usage_7d_gradient_color() {
  local pct=$1
  local r g b
  if [[ $pct -lt 50 ]]; then
    local t=$((pct * 2))
    r=$((249 + (254 - 249) * t / 100))
    g=$((226 + (100 - 226) * t / 100))
    b=$((175 + (11 - 175) * t / 100))
  else
    local t=$(((pct - 50) * 2))
    r=$((254 + (210 - 254) * t / 100))
    g=$((100 + (15 - 100) * t / 100))
    b=$((11 + (57 - 11) * t / 100))
  fi
  echo "$r;$g;$b"
}

generate_bar() {
  local pct=$1
  local width=$2
  local type=$3
  local bar=""
  local filled=$(((pct * width + 50) / 100))
  [[ $filled -gt $width ]] && filled=$width

  local end_color
  case "$type" in
  context) end_color=$(get_context_gradient_color "$pct") ;;
  7d) end_color=$(get_usage_7d_gradient_color "$pct") ;;
  *) end_color=$(get_usage_gradient_color "$pct") ;;
  esac

  for ((i = 0; i < filled; i++)); do
    local block_pct=$((i * 100 / width))
    local color
    case "$type" in
    context) color=$(get_context_gradient_color "$block_pct") ;;
    7d) color=$(get_usage_7d_gradient_color "$block_pct") ;;
    *) color=$(get_usage_gradient_color "$block_pct") ;;
    esac
    bar+="\033[38;2;${color}m█"
  done

  for ((i = 0; i < width - filled; i++)); do
    bar+="\033[38;2;${end_color}m░"
  done

  printf "%b%b" "$bar" "$RESET"
}

# ============================================================================
# Line 1: Model | Style | Directory
# ============================================================================

# Model (bold)
MODEL_DISPLAY="🤖 ${BOLD}${C_TEAL}${MODEL}${RESET}"

# Reasoning effort + extended thinking (effort.level: low|medium|high|xhigh|max; absent if model lacks effort param)
EFFORT=$(echo "$input" | jq -r '.effort.level // empty')
THINKING=$(echo "$input" | jq -r '.thinking.enabled // empty')
[ -n "$EFFORT" ] && MODEL_DISPLAY="${MODEL_DISPLAY} \033[38;2;250;179;135m⚡${EFFORT}${RESET}"
[ "$THINKING" = "true" ] && MODEL_DISPLAY="${MODEL_DISPLAY} \033[38;2;249;226;175m💡${RESET}"

# Directory (shorten $HOME to ~). Built with a case match rather than
# ${CURRENT_DIR/$HOME/~}: bash 5.2+ tilde-expands the replacement, turning ~
# back into $HOME and silently disabling the shortening.
case "$CURRENT_DIR" in
"$HOME") DIR_PATH="~" ;;
"$HOME"/*) DIR_PATH="~${CURRENT_DIR#$HOME}" ;;
*) DIR_PATH="$CURRENT_DIR" ;;
esac
DIR_DISPLAY="📂 ${C_SUBTEXT}${DIR_PATH}${RESET}"

LINE1="${MODEL_DISPLAY}${STYLE_DISPLAY} │ ${DIR_DISPLAY}"

# ============================================================================
# Line 2: Git
# ============================================================================

# Git status with ahead/behind arrows
GIT_STATUS_DISPLAY=""
REPO_DISPLAY=""
cd "$CURRENT_DIR" 2>/dev/null
if git rev-parse --git-dir >/dev/null 2>&1; then
  # Git repo name as owner/repo
  ORIGIN_URL=$(git remote get-url origin 2>/dev/null)
  if [[ -n "$ORIGIN_URL" ]]; then
    REPO_PATH="${ORIGIN_URL%.git}"
    case "$REPO_PATH" in
    *://*)
      REPO_PATH="${REPO_PATH#*://}"
      REPO_PATH="${REPO_PATH#*/}"
      ;;
    *:*) REPO_PATH="${REPO_PATH#*:}" ;;
    esac
    [[ -n "$REPO_PATH" ]] && REPO_DISPLAY="📦 ${C_PEACH}${REPO_PATH}${RESET}"
  fi

  # Git branch
  BRANCH_DISPLAY=""
  cd "$CURRENT_DIR" 2>/dev/null
  if git rev-parse --git-dir >/dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    [[ -n "$BRANCH" ]] && BRANCH_DISPLAY="${C_LATTE_GREEN}🌿 ${BRANCH}${RESET}"
  fi

  STAGED=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
  UNSTAGED=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
  UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

  # Get ahead/behind count relative to upstream
  AHEAD_BEHIND=""
  if git rev-parse --abbrev-ref '@{upstream}' &>/dev/null; then
    COUNTS=$(git rev-list --left-right --count HEAD...'@{upstream}' 2>/dev/null)
    if [[ -n "$COUNTS" ]]; then
      AHEAD=$(echo "$COUNTS" | awk '{print $1}')
      BEHIND=$(echo "$COUNTS" | awk '{print $2}')
      [[ "$AHEAD" -gt 0 ]] && AHEAD_BEHIND="${AHEAD_BEHIND}${C_LATTE_SKY}↑${AHEAD}${RESET}"
      [[ "$BEHIND" -gt 0 ]] && AHEAD_BEHIND="${AHEAD_BEHIND}${C_LATTE_PINK}↓${BEHIND}${RESET}"
    fi
  fi

  if [[ "$STAGED" -eq 0 && "$UNSTAGED" -eq 0 && "$UNTRACKED" -eq 0 ]]; then
    GIT_STATUS_DISPLAY="${C_GREEN}✅${RESET}"
    [[ -n "$AHEAD_BEHIND" ]] && GIT_STATUS_DISPLAY="${GIT_STATUS_DISPLAY} ${AHEAD_BEHIND}"
  else
    STATUS=""
    [[ "$STAGED" -gt 0 ]] && STATUS="${STATUS}+${STAGED}"
    [[ "$UNSTAGED" -gt 0 ]] && STATUS="${STATUS}!${UNSTAGED}"
    [[ "$UNTRACKED" -gt 0 ]] && STATUS="${STATUS}?${UNTRACKED}"
    GIT_STATUS_DISPLAY="${C_LATTE_YELLOW}📝 ${STATUS}${RESET}"
    [[ -n "$AHEAD_BEHIND" ]] && GIT_STATUS_DISPLAY="${GIT_STATUS_DISPLAY} ${AHEAD_BEHIND}"

    # Diff stat (lines added/deleted): working tree vs HEAD (staged + unstaged, untracked excluded)
    DIFFSTAT=$(git diff --numstat HEAD 2>/dev/null | awk '{add+=$1; del+=$2} END {printf "%d %d", add+0, del+0}')
    DIFF_ADDED=$(echo "$DIFFSTAT" | awk '{print $1+0}')
    DIFF_DELETED=$(echo "$DIFFSTAT" | awk '{print $2+0}')
    ADDED_DELETED=""
    [[ "$DIFF_ADDED" -gt 0 ]] && ADDED_DELETED="${C_LATTE_GREEN}+${DIFF_ADDED}${RESET}"
    if [[ "$DIFF_DELETED" -gt 0 ]]; then
      [[ -n "$ADDED_DELETED" ]] && ADDED_DELETED="${ADDED_DELETED} "
      ADDED_DELETED="${ADDED_DELETED}${C_LATTE_RED}-${DIFF_DELETED}${RESET}"
    fi
    [[ -n "$ADDED_DELETED" ]] && GIT_STATUS_DISPLAY="${GIT_STATUS_DISPLAY} ${ADDED_DELETED}"
  fi

  LINE2="${REPO_DISPLAY} ${BRANCH_DISPLAY} ${GIT_STATUS_DISPLAY}"
else
  GIT_STATUS_DISPLAY="${C_OVERLAY}no git${RESET}"
  LINE2="${GIT_STATUS_DISPLAY}"
fi

# ============================================================================
# Line 3: Context + 5H + 7D
# ============================================================================

# Context
CONTEXT_PERCENT=0
if [[ "$CURRENT_USAGE" != "null" && -n "$CURRENT_USAGE" ]]; then
  INPUT_TOKENS=$(echo "$CURRENT_USAGE" | jq -r '.input_tokens // 0')
  CACHE_CREATE=$(echo "$CURRENT_USAGE" | jq -r '.cache_creation_input_tokens // 0')
  CACHE_READ=$(echo "$CURRENT_USAGE" | jq -r '.cache_read_input_tokens // 0')
  CURRENT_TOKENS=$((INPUT_TOKENS + CACHE_CREATE + CACHE_READ))
  [[ "$CONTEXT_SIZE" -gt 0 ]] && CONTEXT_PERCENT=$((CURRENT_TOKENS * 100 / CONTEXT_SIZE))
fi

CTX_BAR=$(generate_bar "$CONTEXT_PERCENT" 10 "context")
CTX_END_COLOR=$(get_context_gradient_color "$CONTEXT_PERCENT")
CTX_DISPLAY="🧠 ${C_PINK}Context${RESET} ${CTX_BAR} ${BOLD}\033[38;2;${CTX_END_COLOR}m${CONTEXT_PERCENT}%${RESET}"

# Format 5H reset as "1h2m"
format_time_remaining() {
  local reset_epoch="$1"
  [[ -z "$reset_epoch" || "$reset_epoch" == "null" ]] && return
  local now_epoch=$(date +%s)
  local remaining=$((reset_epoch - now_epoch))
  [[ $remaining -lt 0 ]] && remaining=0
  local hours=$((remaining / 3600))
  local minutes=$(((remaining % 3600) / 60))
  echo "${hours}h${minutes}m"
}

# Cross-platform date formatting (BSD/macOS vs GNU/Linux)
_date_fmt() {
  local epoch="$1" fmt="$2"
  local out=""
  out=$(date -j -f "%s" "$epoch" "+$fmt" 2>/dev/null) && [[ -n "$out" ]] && {
    echo "$out"
    return
  }
  out=$(date -r "$epoch" "+$fmt" 2>/dev/null) && [[ -n "$out" ]] && {
    echo "$out"
    return
  }
  date -d "@$epoch" "+$fmt" 2>/dev/null
}

# Format 7D reset as "Mon"
format_reset_day() {
  local reset_epoch="$1"
  [[ -z "$reset_epoch" || "$reset_epoch" == "null" ]] && return
  _date_fmt "$reset_epoch" "%a"
}

# Usage from rate_limits
if [[ -n "$FIVE_HOUR_PCT" ]]; then
  FIVE_HOUR=$(printf "%.0f" "$FIVE_HOUR_PCT")
  SEVEN_DAY=$(printf "%.0f" "${SEVEN_DAY_PCT:-0}")

  FIVE_RESET_FMT=$(format_time_remaining "$FIVE_HOUR_RESET")
  SEVEN_RESET_FMT=$(format_reset_day "$SEVEN_DAY_RESET")

  FIVE_BAR=$(generate_bar "$FIVE_HOUR" 10 "5h")
  SEVEN_BAR=$(generate_bar "$SEVEN_DAY" 10 "7d")

  FIVE_END_COLOR=$(get_usage_gradient_color "$FIVE_HOUR")
  SEVEN_END_COLOR=$(get_usage_7d_gradient_color "$SEVEN_DAY")

  FIVE_DISPLAY="${C_LAVENDER}5H${RESET} ${FIVE_BAR} ${BOLD}\033[38;2;${FIVE_END_COLOR}m${FIVE_HOUR}%${RESET} (${FIVE_RESET_FMT})"
  SEVEN_DISPLAY="${C_YELLOW}7D${RESET} ${SEVEN_BAR} ${BOLD}\033[38;2;${SEVEN_END_COLOR}m${SEVEN_DAY}%${RESET} (${SEVEN_RESET_FMT})"

  LINE3="${CTX_DISPLAY} │ ${FIVE_DISPLAY} │ ${SEVEN_DISPLAY}"
else
  FIVE_BAR=$(generate_bar 0 10 "5h")
  SEVEN_BAR=$(generate_bar 0 10 "7d")
  FIVE_END_COLOR=$(get_usage_gradient_color 0)
  SEVEN_END_COLOR=$(get_usage_7d_gradient_color 0)
  FIVE_DISPLAY="${C_LAVENDER}5H${RESET} ${FIVE_BAR} ${BOLD}\033[38;2;${FIVE_END_COLOR}m0%${RESET}"
  SEVEN_DISPLAY="${C_YELLOW}7D${RESET} ${SEVEN_BAR} ${BOLD}\033[38;2;${SEVEN_END_COLOR}m0%${RESET}"
  LINE3="${CTX_DISPLAY} │ ${FIVE_DISPLAY} │ ${SEVEN_DISPLAY} ${C_OVERLAY}(loading..)${RESET}"
fi

# ============================================================================
# Output (using printf with line clear)
# ============================================================================
printf "%b%b\n" "$LINE1" "$CLR"
printf "%b%b\n" "$LINE2" "$CLR"
printf "%b%b\n" "$LINE3" "$CLR"
