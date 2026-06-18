#!/usr/bin/env bash
# install.sh — copy this repo's skills and agents into a Claude Code config dir.
#
#   ./install.sh                  install globally to ~/.claude/ (skills + agents)
#   ./install.sh <project-dir>    install into <project-dir>/.claude/
#   ./install.sh -h | --help      show this help
#
# Items already present at the destination are overwritten, so re-run to update.
set -euo pipefail

usage() {
  sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

case "${1:-}" in
  -h|--help) usage 0 ;;
esac

# Resolve the directory this script lives in, so it works from any cwd.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_ROOT="$SCRIPT_DIR/.claude"

if [ ! -d "$SRC_ROOT" ]; then
  echo "error: no .claude/ directory found at $SRC_ROOT" >&2
  exit 1
fi

# Destination root: global by default, or <project-dir>/.claude if an arg is given.
if [ -n "${1:-}" ]; then
  TARGET="$1"
  if [ ! -d "$TARGET" ]; then
    echo "error: target directory does not exist: $TARGET" >&2
    exit 1
  fi
  DEST_ROOT="$TARGET/.claude"
  SCOPE="project ($TARGET)"
else
  DEST_ROOT="$HOME/.claude"
  SCOPE="global"
fi

total=0

# Copy every entry (skill dirs or agent files) from one category into the destination.
install_category() {
  local category="$1"
  local src="$SRC_ROOT/$category"
  [ -d "$src" ] || return 0
  local dest="$DEST_ROOT/$category"
  mkdir -p "$dest"
  local entry name
  for entry in "$src"/*; do
    [ -e "$entry" ] || continue   # nothing matched the glob
    name="$(basename "$entry")"
    rm -rf "$dest/$name"
    cp -R "$entry" "$dest/$name"
    # Keep any helper scripts executable.
    find "$dest/$name" -type f -name '*.sh' -exec chmod +x {} + 2>/dev/null || true
    echo "  $category: $name"
    total=$((total + 1))
  done
}

install_category skills
install_category agents

if [ "$total" -eq 0 ]; then
  echo "no skills or agents found under $SRC_ROOT" >&2
  exit 1
fi

echo
echo "Installed $total item(s) [$SCOPE] -> $DEST_ROOT"
echo "Skills: invoke with /<skill-name> (e.g. /watch-agents)."
echo "Agents: spawn via the Agent tool with subagent_type (e.g. implementer)."
echo
echo "Next: generate a project CLAUDE.md with the setup wizard ->"
echo "  $SCRIPT_DIR/setup.sh [project-dir]"
