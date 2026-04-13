#!/usr/bin/env bash
# sync.sh — auto-commit and push any changes to the dotfiles repo
# Run by launchd daily. Only commits when there are actual changes.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG="$DOTFILES_DIR/.sync.log"

cd "$DOTFILES_DIR"

# Check for changes (staged, unstaged, or untracked)
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
  echo "$(date '+%Y-%m-%d %H:%M') no changes" >> "$LOG"
  exit 0
fi

git add -A
git commit -m "chore: auto-sync claude config $(date '+%Y-%m-%d')"
git push

echo "$(date '+%Y-%m-%d %H:%M') synced" >> "$LOG"
