#!/usr/bin/env bash
# PreToolUse(Bash): capture command output to a temp file, then emit a trimmed
# view, so oversized output never enters context (and is never re-sent each turn).
#
# Why not PostToolUse: it has no `updatedOutput` field. Only PreToolUse can
# rewrite a tool call, via hookSpecificOutput.updatedInput.
#
# Why a temp file and not a pipe: the left side of a pipe runs in a SUBSHELL,
# which would silently break `cd` and variable assignments persisting across
# Bash tool calls. Redirecting a brace group keeps everything in the live shell.
#
# Output <= 35 lines passes through byte-for-byte untouched.
# Escape hatch: put NO_TRIM=1 in the command, or export CLAUDE_NO_TRIM=1.
#
# Also never rewritten:
# - Commands run from an agent worktree (cwd under /.claude/worktrees/). The
#   rewritten brace group trips the worktree guard, which then refuses every
#   command; agents there had to discover NO_TRIM=1 on their own.
# - Deliberate file reads: a command whose first word (after any leading
#   `cd … &&`) is sed -n, cat, grep or rg. The caller chose those lines, and
#   trimming their middle only forces a narrower re-read. Logs, builds and test
#   runs are still trimmed.
set -uo pipefail
TRIMMER="$HOME/.claude/tools/hooks/trim-output.sh"
payload=$(cat)

[ "${CLAUDE_NO_TRIM:-}" = "1" ] && exit 0
[ -x "$TRIMMER" ] || exit 0

cwd=$(printf '%s' "$payload" | jq -r '.cwd // empty')
case "$cwd" in */.claude/worktrees/*) exit 0 ;; esac

tool=$(printf '%s' "$payload" | jq -r '.tool_name // empty')
[ "$tool" = "Bash" ] || exit 0
cmd=$(printf '%s' "$payload" | jq -r '.tool_input.command // empty')
[ -n "$cmd" ] || exit 0

# Never rewrite these: heredocs (brace-group quoting is fragile), backgrounded
# commands, anything already trimmed or already limited by the caller, exec/
# recursion, and explicit opt-outs.
case "$cmd" in
  *trim-output*|*NO_TRIM=1*|*'<<'*|*'exec '*) exit 0 ;;
esac
printf '%s' "$cmd" | grep -qE '&[[:space:]]*$' && exit 0
# Deliberate reads: strip any leading `cd <dir> &&` chain, then test the first word.
first=$(printf '%s' "$cmd" | sed -E 's/^[[:space:]]*(cd[[:space:]]+[^;&|]+&&[[:space:]]*)*//')
printf '%s' "$first" | grep -qE '^(sed[[:space:]]+-n|cat|grep|rg)([[:space:]]|$)' && exit 0
printf '%s' "$cmd" | grep -qE '\|[[:space:]]*(head|tail)([[:space:]]|$)' && exit 0

wrapped="__tf=\$(mktemp); { ${cmd}
} > \"\$__tf\" 2>&1; __rc=\$?; \"$TRIMMER\" < \"\$__tf\"; rm -f \"\$__tf\"; ( exit \$__rc )"

jq -n --arg c "$wrapped" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    updatedInput: { command: $c }
  }
}'
exit 0
