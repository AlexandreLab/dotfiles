#!/usr/bin/env bash
# install.sh — set up symlinks from ~/.claude/ to this dotfiles repo
#
# Run once after cloning:
#   git clone https://github.com/AlexandreLab/dotfiles.git ~/dotfiles
#   cd ~/dotfiles && ./install.sh

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
CLAUDE_SRC="$DOTFILES_DIR/claude"

echo "→ Setting up Claude Code config from $DOTFILES_DIR"

# Ensure ~/.claude exists
mkdir -p "$CLAUDE_DIR"

# Files and directories to symlink
# Format: "source_in_repo:target_in_~/.claude"
LINKS=(
  "CLAUDE.md:CLAUDE.md"
  "settings.json:settings.json"
  "workspace-efficiency-guide.md:workspace-efficiency-guide.md"
  "commands:commands"
  "skills:skills"
)

for entry in "${LINKS[@]}"; do
  src="$CLAUDE_SRC/${entry%%:*}"
  dst="$CLAUDE_DIR/${entry##*:}"

  if [ ! -e "$src" ]; then
    echo "  ⚠ skipping $src (not found in dotfiles)"
    continue
  fi

  if [ -L "$dst" ]; then
    echo "  ✓ $dst already symlinked"
  elif [ -e "$dst" ]; then
    backup="$dst.bak.$(date +%Y%m%d%H%M%S)"
    echo "  ⚠ backing up existing $dst → $backup"
    mv "$dst" "$backup"
    ln -s "$src" "$dst"
    echo "  ✓ linked $dst → $src"
  else
    ln -s "$src" "$dst"
    echo "  ✓ linked $dst → $src"
  fi
done

echo ""
echo "Done. Verify with: ls -la ~/.claude/"
echo ""
echo "Note: ~/.claude/skills/gstack/ and gstack/ostack/ are large binary skills"
echo "excluded from this repo. Reinstall them separately if needed."
