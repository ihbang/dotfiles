# ssh-browser.zsh — Set BROWSER for remote sessions to use opener TCP forwarding

_is_remote_session() {
  # Direct SSH session
  [[ -n "$SSH_CONNECTION" || -n "$SSH_TTY" || -n "$SSH_CLIENT" ]] && return 0
  # Inside tmux on a remote host: check if opener TCP port is reachable
  (echo > /dev/tcp/127.0.0.1/${OPENER_PORT:-12345}) 2>/dev/null && return 0
  return 1
}

if _is_remote_session; then
  export BROWSER="$HOME/.local/bin/open-browser"
fi

# Diagnostic function for opener connection status
opener-status() {
  local port="${OPENER_PORT:-12345}"
  echo "Opener: TCP 127.0.0.1:$port"
  if (echo > /dev/tcp/127.0.0.1/$port) 2>/dev/null; then
    echo "Status: port reachable"
    if printf 'about:blank' | nc -w2 127.0.0.1 "$port" 2>/dev/null; then
      echo "Connection: OK (opener daemon reachable)"
    else
      echo "Connection: FAILED (port open but opener not responding)"
    fi
  else
    echo "Status: port not reachable"
    echo "Hint: Ensure SSH RemoteForward $port is configured and opener daemon is running locally"
  fi
}
