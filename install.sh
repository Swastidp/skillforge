#!/usr/bin/env bash
# skillforge installer (macOS / Linux / Git-Bash)
#
#   Install everything:
#     curl -fsSL https://raw.githubusercontent.com/Swastidp/skillforge/main/install.sh | bash
#
#   Install selected skills only (space-separated names):
#     curl -fsSL https://raw.githubusercontent.com/Swastidp/skillforge/main/install.sh | bash -s -- find-context save-context
#
#   From a local clone: ./install.sh            (all)
#                       ./install.sh find-context (selected)
set -euo pipefail

REPO_URL="https://github.com/Swastidp/skillforge.git"
DEST="${HOME}/.claude/skills"

# Find the skills source: a local checkout if we're running from one, else clone.
SRC=""
if [ -n "${BASH_SOURCE:-}" ] && [ -f "${BASH_SOURCE[0]:-}" ]; then
  here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  [ -d "$here/skills" ] && SRC="$here/skills"
fi
if [ -z "$SRC" ]; then
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  echo "Fetching skillforge..."
  git clone --depth 1 "$REPO_URL" "$tmp/skillforge" >/dev/null 2>&1
  SRC="$tmp/skillforge/skills"
fi

mkdir -p "$DEST"

# Which skills? Positional args, or all folders under skills/.
if [ "$#" -gt 0 ]; then
  skills=("$@")
else
  skills=()
  for d in "$SRC"/*/; do skills+=("$(basename "$d")"); done
fi

for s in "${skills[@]}"; do
  if [ -d "$SRC/$s" ]; then
    rm -rf "${DEST:?}/$s"
    cp -r "$SRC/$s" "$DEST/$s"
    echo "  installed  $s"
  else
    echo "  skipped    $s (not found in collection)" >&2
  fi
done

echo "Done -> $DEST"
