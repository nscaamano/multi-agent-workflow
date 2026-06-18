#!/usr/bin/env bash
# install.sh — copy this repo's skills into a Claude Code skills directory.
#
#   ./install.sh                  install globally to ~/.claude/skills/
#   ./install.sh <project-dir>    install into <project-dir>/.claude/skills/
#   ./install.sh -h | --help      show this help
#
# Skills already present at the destination are overwritten.
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
SRC="$SCRIPT_DIR/.claude/skills"

if [ ! -d "$SRC" ]; then
  echo "error: no skills found at $SRC" >&2
  exit 1
fi

# Destination: global by default, or <project-dir>/.claude/skills if an arg is given.
if [ -n "${1:-}" ]; then
  TARGET_ROOT="$1"
  if [ ! -d "$TARGET_ROOT" ]; then
    echo "error: target directory does not exist: $TARGET_ROOT" >&2
    exit 1
  fi
  DEST="$TARGET_ROOT/.claude/skills"
  SCOPE="project ($TARGET_ROOT)"
else
  DEST="$HOME/.claude/skills"
  SCOPE="global"
fi

mkdir -p "$DEST"

installed=0
for skill in "$SRC"/*/; do
  [ -d "$skill" ] || continue
  name="$(basename "$skill")"
  rm -rf "$DEST/$name"
  cp -R "$skill" "$DEST/$name"
  # Ensure helper scripts stay executable.
  find "$DEST/$name" -type f -name '*.sh' -exec chmod +x {} +
  echo "  installed: $name"
  installed=$((installed + 1))
done

if [ "$installed" -eq 0 ]; then
  echo "no skills to install (none found in $SRC)" >&2
  exit 1
fi

echo
echo "Installed $installed skill(s) [$SCOPE] -> $DEST"
echo "Invoke from Claude Code with /<skill-name>, e.g. /watch-agents"
