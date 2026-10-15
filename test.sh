#!/bin/sh
# Simple smoke tests for the static site
set -e
F=app/index.html
[ -f "$F" ] && echo "PASS: index.html exists"
for s in "PERT" "Gantt" "Critical path" "SDG 9"; do
  grep -qi "$s" "$F" && echo "PASS: found '$s'" || { echo "FAIL: missing '$s'"; exit 1; }
done
echo "All tests passed"
