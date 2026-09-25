#!/usr/bin/env bash
# Trims noisy command output before it reaches the model's context.
# Keeps: first HEAD lines, every error/warning line from the middle, last TAIL lines.
# Reads stdin, writes trimmed stdout, always exits 0 (pipefail carries the real status).
HEAD=${TRIM_HEAD:-5}
TAIL=${TRIM_TAIL:-30}
MAXERR=${TRIM_MAXERR:-40}

awk -v head="$HEAD" -v tail="$TAIL" -v maxerr="$MAXERR" '
{ line[NR] = $0 }
END {
  if (NR <= head + tail) { for (i = 1; i <= NR; i++) print line[i]; exit }

  for (i = 1; i <= head; i++) print line[i]

  ne = 0; over = 0
  for (i = head + 1; i <= NR - tail; i++) {
    if (line[i] ~ /error|Error|ERROR|FAIL|Failed|failed|fatal|Traceback|Exception|panic:|npm ERR|ELIFECYCLE|warning:|WARN|TS[0-9][0-9][0-9][0-9]|✗|✘|✖/) {
      if (ne < maxerr) err[++ne] = i; else over++
    }
  }

  printf "\n\033[2m... [trim-output] %d middle lines hidden", NR - head - tail
  if (ne > 0) printf "; %d error/warning lines surfaced below", ne
  printf " ...\033[0m\n"

  for (j = 1; j <= ne; j++) printf "L%d: %s\n", err[j], line[err[j]]
  if (over > 0) printf "... (+%d more matching lines suppressed) ...\n", over

  printf "\033[2m... [trim-output] last %d lines ...\033[0m\n", tail
  for (i = NR - tail + 1; i <= NR; i++) print line[i]
}'
