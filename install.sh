#!/usr/bin/env bash
#
# claude-dotfiles installer
#   Symlinks each machine to the real files in this repository.
#   Any existing real file is moved aside to *.bak.<timestamp> before replacing.
#   Safe to run any number of times (idempotent).
#
set -euo pipefail

# The directory this script lives in (= the repository root)
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BIN_DIR="$HOME/.local/bin"
CLAUDE_DIR="$HOME/.claude"
STAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BIN_DIR" "$CLAUDE_DIR"

# link <src> <dst>
#   Skip if dst is already a symlink pointing at the repo.
#   If it is a different symlink / real file, move it aside to .bak, then relink.
link() {
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
    echo "  ok    $dst (already linked)"
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    local bak="$dst.bak.$STAMP"
    mv "$dst" "$bak"
    echo "  backup $dst -> $bak"
  fi
  ln -s "$src" "$dst"
  echo "  link  $dst -> $src"
}

echo "Repository: $REPO"
echo ""
echo "[1/2] Executables -> $BIN_DIR"
for f in "$REPO"/bin/*; do
  [ -f "$f" ] || continue   # ignore directories such as __pycache__
  link "$f" "$BIN_DIR/$(basename "$f")"
done

echo ""
echo "[2/2] settings.json -> $CLAUDE_DIR"
link "$REPO/claude/settings.json" "$CLAUDE_DIR/settings.json"

echo ""
echo "Done. Please verify the following:"
echo "  - '$BIN_DIR' is on your PATH"
echo "  - python3 is installed (required command)"
echo "  - machine-specific / secret settings go in $CLAUDE_DIR/settings.local.json (gitignored)"
