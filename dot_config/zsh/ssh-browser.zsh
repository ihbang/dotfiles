# ssh-browser.zsh — Set BROWSER for remote sessions to use opener socket forwarding

_is_remote_session() {
  # Direct SSH session
  [[ -n "$SSH_CONNECTION" || -n "$SSH_TTY" || -n "$SSH_CLIENT" ]] && return 0
  # Inside tmux on a remote host: check if opener socket exists
  [[ -S "${OPENER_SOCK:-$HOME/.opener.sock}" ]] && return 0
  return 1
}

if _is_remote_session; then
  export BROWSER="$HOME/.local/bin/open-browser"
fi

# Diagnostic function for opener socket status
opener-status() {
  local sock="${OPENER_SOCK:-$HOME/.opener.sock}"
  echo "Opener socket: $sock"
  if [[ -S "$sock" ]]; then
    echo "Status: socket exists"
    if printf 'about:blank' | nc -w2 -U "$sock" 2>/dev/null; then
      echo "Connection: OK (opener daemon reachable)"
    else
      echo "Connection: FAILED (socket exists but daemon not responding)"
    fi
  else
    echo "Status: socket not found"
    echo "Hint: Ensure SSH RemoteForward is configured and opener daemon is running on local machine"
  fi
}
