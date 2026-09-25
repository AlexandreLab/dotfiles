#!/usr/bin/env bash
# install-skills.sh – install the third-party skills and plugins that are not stored in this repo.
#
# Run after ./install.sh (which links ~/.claude/skills to claude/skills/ here, where the
# user's own skills already live). Safe to re-run: each step skips what is already there.
# See SKILLS.md for what each piece is and how to check the result.

set -uo pipefail

SKILLS_DIR="$HOME/.claude/skills"
failed=()

step() { printf '\n→ %s\n' "$1"; }
need() { command -v "$1" >/dev/null 2>&1 || { echo "  ✗ '$1' not found: $2"; failed+=("$1"); return 1; }; }

need git "install git" || exit 1
need node "install Node.js 22+ (npx is needed for the skills CLI)" || exit 1

# 1. gstack – cloned into the skills dir; its setup script creates the gstack-* skill folders.
step "gstack (garrytan/gstack)"
if [ -d "$SKILLS_DIR/gstack/.git" ]; then
  echo "  ✓ already cloned; updating"
  git -C "$SKILLS_DIR/gstack" pull --ff-only --quiet || failed+=("gstack pull")
else
  git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git "$SKILLS_DIR/gstack" || failed+=("gstack clone")
fi
if [ -x "$SKILLS_DIR/gstack/setup" ]; then
  (cd "$SKILLS_DIR/gstack" && ./setup --prefix) || failed+=("gstack setup")
fi

# 2. Skills from GitHub, via the skills CLI. --copy matters: ~/.claude/skills is itself a symlink into
#    this repo, so the relative links the CLI writes by default point nowhere.
#    Format: "<github owner/repo>:<skill name>"
GITHUB_SKILLS=(
  "herdrdev/herdr:herdr"
  "stripe/ai:stripe-best-practices"
)
for entry in "${GITHUB_SKILLS[@]}"; do
  repo="${entry%%:*}"; skill="${entry##*:}"
  step "$skill ($repo)"
  if [ -e "$SKILLS_DIR/$skill/SKILL.md" ]; then
    echo "  ✓ already installed"
  else
    npx -y skills add "$repo" --skill "$skill" -g -a claude-code -y --copy || failed+=("$skill")
  fi
done

# 3. SEO – the skill ships inside the `seo` npm CLI, not on GitHub.
step "seo (npm package 'seo')"
if ! command -v seo >/dev/null 2>&1; then
  npm i -g seo || failed+=("seo cli")
fi
if command -v seo >/dev/null 2>&1; then
  [ -e "$SKILLS_DIR/seo/SKILL.md" ] && echo "  ✓ skill already installed" || seo skill install || failed+=("seo skill")
  seo mcp install --claude-code || failed+=("seo mcp")
fi

# 4. Claude Code plugins – marketplaces first, then the enabled plugins listed in settings.json.
need claude "install Claude Code first: https://claude.ai/install.sh" && {
  step "plugin marketplaces"
  for m in anthropics/claude-plugins-official thedotmack/claude-mem bradautomates/claude-video typesafe-ai/skills; do
    claude plugin marketplace add "$m" >/dev/null 2>&1 && echo "  ✓ $m" || echo "  · $m (already added or failed; check 'claude plugin marketplace list')"
  done
  step "plugins"
  for p in supabase@claude-plugins-official vercel@claude-plugins-official frontend-design@claude-plugins-official \
           claude-mem@thedotmack watch@claude-video typesafe@typesafe-ai; do
    claude plugin install "$p" >/dev/null 2>&1 && echo "  ✓ $p" || { echo "  ✗ $p"; failed+=("$p"); }
  done
}

echo ""
if [ ${#failed[@]} -eq 0 ]; then
  echo "Done. Start a new Claude Code session and check the skill list (see SKILLS.md, 'Check the result')."
else
  echo "Finished with problems: ${failed[*]}"
  echo "See SKILLS.md for the manual command for each one."
  exit 1
fi
