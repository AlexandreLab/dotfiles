#!/usr/bin/env python3
"""Claude Code statusline: model · effort · context % · 5h rate limit · folder · worktree.

Reads the statusline JSON payload on stdin. Wire it up in settings.json:
  "statusLine": {"type": "command", "command": "python3 \"$HOME/.claude/tools/statusline.py\"", "padding": 0}
"""
import json, os, sys, time

D, R, B = "\033[2m", "\033[0m", "\033[1m"
CY, YE, RD, GN = "\033[36m", "\033[33m", "\033[31m", "\033[32m"


def level(p):
    return GN if p < 50 else (YE if p < 80 else RD)


def main():
    try:
        d = json.load(sys.stdin)
    except Exception:
        return

    parts = []

    model = (d.get("model") or {}).get("display_name") or "?"
    eff = (d.get("effort") or {}).get("level")
    parts.append(f"{B}{CY}{model}{R}" + (f"{D}/{eff}{R}" if eff else ""))

    cw = d.get("context_window") or {}
    used = cw.get("used_percentage")
    if used is not None:
        size = cw.get("context_window_size") or 0
        tot = cw.get("total_input_tokens") or 0
        parts.append(f"{level(used)}ctx {used:.0f}%{R}{D} ({tot/1000:.0f}k/{size/1000:.0f}k){R}")

    rl = (d.get("rate_limits") or {}).get("five_hour") or {}
    p = rl.get("used_percentage")
    if p is not None:
        left = (rl.get("resets_at") or 0) - time.time()
        parts.append(f"{D}5h {R}{level(p)}{p:.0f}%{R}"
                     + (f"{D} ({left/3600:.1f}h){R}" if left > 0 else ""))

    ws = d.get("workspace") or {}
    cur = ws.get("current_dir") or d.get("cwd") or ""
    if cur:
        parts.append(f"{D}{os.path.basename(cur)}{R}")

    wt = (d.get("worktree") or {}).get("branch")
    if wt:
        parts.append(f"{D}⎇ {wt}{R}")

    print(f"{D} · {R}".join(parts))


main()
