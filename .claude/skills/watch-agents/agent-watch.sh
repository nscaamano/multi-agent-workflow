#!/usr/bin/env bash
# agent-watch.sh — locate and snapshot spawned worker-agent output.
# Used by the `watch-agents` skill. Bounded output only; never follows (-f).
#
#   agent-watch.sh list              list running agents + available logs
#   agent-watch.sh tail [file] [n]   snapshot last n lines (default: newest .agent-logs/*, 50)
set -euo pipefail

LOG_DIR=".agent-logs"

newest_log() {
  # Newest regular file under .agent-logs, if any.
  [ -d "$LOG_DIR" ] || return 1
  find "$LOG_DIR" -type f -name '*.log' -print0 2>/dev/null \
    | xargs -0 ls -t 2>/dev/null \
    | head -n 1
}

cmd_list() {
  echo "== running agent processes =="
  # -f matches the full command line; ignore this script and the grep itself.
  if pgrep -fl 'codex exec|gemini|claude ' 2>/dev/null | grep -v 'agent-watch.sh'; then :; else
    echo "(none found via pgrep)"
  fi

  echo
  echo "== logs in $LOG_DIR =="
  if [ -d "$LOG_DIR" ]; then
    ls -lt "$LOG_DIR" 2>/dev/null | tail -n +2 || echo "(empty)"
  else
    echo "(no $LOG_DIR/ — launch workers with > $LOG_DIR/<name>.log 2>&1 &)"
  fi

  echo
  echo "== Claude Code background-task outputs (best effort) =="
  # Harness-internal location; may not exist / may differ across versions.
  found=$(ls -t /tmp/claude-*/*/*/tasks/*.output 2>/dev/null | head -n 10 || true)
  if [ -n "$found" ]; then echo "$found"; else echo "(none found)"; fi
}

cmd_tail() {
  local file="${1:-}" n="${2:-50}"
  if [ -z "$file" ]; then
    file="$(newest_log || true)"
    if [ -z "$file" ]; then
      echo "No log file given and nothing in $LOG_DIR/. Run: agent-watch.sh list" >&2
      exit 1
    fi
    echo "# newest log: $file" >&2
  fi
  if [ ! -f "$file" ]; then
    echo "Not a file: $file" >&2
    exit 1
  fi
  tail -n "$n" "$file"
}

case "${1:-list}" in
  list) cmd_list ;;
  tail) shift; cmd_tail "$@" ;;
  *) echo "usage: agent-watch.sh [list|tail [file] [n]]" >&2; exit 2 ;;
esac
