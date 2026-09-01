#!/usr/bin/env bash
cmd=$(jq -r '.tool_input.command')

# Block rm when both recursive and force flags are present, in any order or spelling
# (rm -rf, rm -fr, rm -r -f, rm -R --force, ...).
if echo "$cmd" | grep -qE '\brm\b' \
   && echo "$cmd" | grep -qE '(^|[[:space:]])-[A-Za-z]*[rR]|[[:space:]]--recursive\b' \
   && echo "$cmd" | grep -qE '(^|[[:space:]])-[A-Za-z]*f|[[:space:]]--force\b'; then
  echo "BLOCKED: recursive+force rm detected. Use 'trash' or confirm the exact path manually." >&2
  exit 2
fi

# Block force-push.
if echo "$cmd" | grep -qE 'git\s+push\s+.*--force|git\s+push\s+.*-f\b'; then
  echo "BLOCKED: force-push detected. Use --force-with-lease or push a feature branch." >&2
  exit 2
fi

exit 0
