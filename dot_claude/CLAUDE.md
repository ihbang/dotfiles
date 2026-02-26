# Command Execution Rules
## ⚠️ MANDATORY: Fish Shell for ALL Commands

> **CRITICAL RULE — READ BEFORE ANY COMMAND EXECUTION**

The Bash tool executes in zsh/bash. Your environment (fnm, pyenv, bun, etc.) exists ONLY in fish.

### 🐟 THE RULE: ALWAYS use `fish -c "command"`

**EVERY command. No exceptions. No thinking required.**

```bash
# Pattern
fish -c "your command here"

# Examples
fish -c "node -v"
fish -c "pnpm install"
fish -c "bun run dev"
fish -c "python --version"
fish -c "git status"
fish -c "ls -la"
```

### Why This Matters
- `node`, `bun`, `pnpm` → Managed by `fnm` → Only in fish PATH
- `python`, `uv`, `pip` → Managed by `pyenv` → Only in fish PATH
- `ruby`, `gem`, `bundle` → Managed by `rbenv` → Only in fish PATH
- Environment variables → Set in `~/.config/fish/config.fish`

### DO NOT
❌ `node -v` → Will fail: "command not found"
❌ `pnpm install` → Will fail: "command not found"
❌ Run any command without `fish -c` wrapper

### DO
✅ `fish -c "node -v"`
✅ `fish -c "pnpm install"`
✅ `fish -c "ls -la"` (even simple commands - consistency matters)

# Language Rules
## English
Every comment in codes must be written in English.

## 한국어
질문 혹은 요청에 대한 모든 답변은 한국어로 작성되어야 한다.
문서 혹은 .md 파일을 작성할 때도 작성 언어가 특별히 명시되어 있지 않은 경우 한국어로 작성한다.
