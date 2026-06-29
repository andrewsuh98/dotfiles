---
name: copy-slack
description: >-
  Copy a Claude Code response to the macOS clipboard, converted from
  GitHub-flavored Markdown into Slack's message markup (mrkdwn) so it pastes
  cleanly into the Slack composer. Use when the user says things like "copy
  this to Slack", "copy that for Slack", "/copy-slack", or otherwise wants a
  response put on the clipboard formatted for Slack.
---

# Copy response to clipboard as Slack markup

Convert a Claude Code response from standard (GitHub-flavored) Markdown into
Slack's message formatting and place it on the macOS clipboard with `pbcopy`,
ready to paste into the Slack message composer.

## Which message to copy

- Default: the **most recent assistant response** in this conversation (the
  message immediately before the user invoked this skill).
- If the user points at a different message ("the one about X", "your first
  reply", "everything since ..."), use that instead.
- Copy the message *content* only. Omit tool-call chatter, this skill's own
  status output, and surrounding commentary unless the user asks to include it.

## Conversion rules (GitHub Markdown → Slack markup)

Slack supports only a small set of formatting. Apply these transforms:

| Markdown (input)              | Slack (output)                                        |
|-------------------------------|-------------------------------------------------------|
| `**bold**` / `__bold__`       | `*bold*` — single asterisks                           |
| `*italic*` / `_italic_`       | `_italic_` — underscores                              |
| `***bold italic***`           | `*_bold italic_*`                                     |
| `~~strikethrough~~`           | `~strikethrough~` — single tildes                     |
| `# Heading` (any level)       | `*Heading*` on its own line — Slack has no headings   |
| `` `inline code` ``           | unchanged — `` `inline code` ``                       |
| ` ```lang … ``` ` fenced block| ` ``` … ``` ` — drop the language tag                 |
| `> quote`                     | unchanged — `> quote`                                 |
| `- item` / `* item` bullet    | `• item` — literal bullet char + space                |
| `1. item` ordered             | unchanged — `1. item`                                 |
| nested list item              | indent with spaces before the `•` / number            |
| `- [ ]` / `- [x]` task item   | `• [ ] ` / `• [x] ` — Slack has no real checkboxes    |
| `[text](url)` link            | unchanged — `[text](url)` (composer converts it)      |
| `![alt](url)` image           | `[alt](url)` — drop the leading `!`                   |
| `---` / `***` horizontal rule | a row of dashes — `- - - - - - - - - -` (no native rule) |
| table                         | wrap the whole table in a ` ``` ` code block so columns align in monospace |

Notes:

- Slack has **no headings** — the strongest emphasis is bold. Make headings
  bold text on their own line and keep them short.
- Slack has **no task lists and no horizontal rules**. Render task items as
  plain `• [ ] ` / `• [x] ` text, and render a horizontal rule as a row of
  dashes on its own line. Do not use checkbox glyphs (☐/☑) or box-drawing
  divider characters (──────────) — they look out of place in Slack.
- Inside ` ``` ` code blocks and `` ` `` inline code, copy contents **verbatim**
  — do not apply any of the transforms above to code.
- Only convert formatting markers. Leave literal `*`, `_`, `~`, and backticks
  that appear inside code spans/blocks untouched.
- Preserve blank lines and paragraph spacing.

## Procedure

1. Convert the target message using the rules above.
2. Write the converted Slack text to a fresh temp file with the Write tool —
   this avoids shell-quoting problems with backticks, quotes, `$`, etc. Use a
   path like `/tmp/claude-slack-clip.txt`.
3. Copy it to the clipboard and remove the temp file:

   ```bash
   pbcopy < /tmp/claude-slack-clip.txt && rm -f /tmp/claude-slack-clip.txt
   ```

4. Confirm briefly, e.g. "Copied to clipboard in Slack format." Do not echo the
   full converted text back into the chat unless the user asks to see it.
