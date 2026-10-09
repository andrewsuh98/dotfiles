#!/bin/bash
# Even out pane sizes in the active herdr tab, bound to prefix+= in config.toml.
# Like tmux's `select-layout -E`, but for the whole tab: the arrangement is kept
# and only split ratios change, so running processes are untouched.
#
# Each split is sized by how many panes line up along its own direction: a
# left/right split by columns, a top/bottom split by rows. Panes stacked
# across the split's direction count as one, so A | (B over C) stays 50/50.
set -euo pipefail

sock="${HERDR_SOCKET_PATH:?equalize.sh: HERDR_SOCKET_PATH not set}"
tab="${HERDR_ACTIVE_TAB_ID:-${HERDR_TAB_ID:?equalize.sh: no active tab}}"

# herdr's socket answers one newline-delimited JSON request per connection
request() {
  printf '%s\n' "$1" | nc -U -w 2 "$sock"
}

layout=$(request "$(jq -cn --arg tab "$tab" \
  '{id: "equalize_export", method: "layout.export", params: {tab_id: $tab}}')")

echo "$layout" | jq -c --arg tab "$tab" '
  # Panes lined up along direction $d within this subtree
  def span($d):
    if .type == "pane" then 1
    elif .direction == $d then (.first | span($d)) + (.second | span($d))
    else [(.first | span($d)), (.second | span($d))] | max
    end;

  # One set_split_ratio request per split; path entries: false = first, true = second
  def ratios($path):
    if .type == "split" then
      .direction as $d
      | (.first | span($d)) as $a
      | (.second | span($d)) as $b
      | {id: "equalize", method: "layout.set_split_ratio",
         params: {tab_id: $tab, path: $path, ratio: ($a / ($a + $b))}},
        (.first | ratios($path + [false])),
        (.second | ratios($path + [true]))
    else empty
    end;

  .result.layout.root | ratios([])
' | while IFS= read -r req; do
  request "$req" >/dev/null
done
