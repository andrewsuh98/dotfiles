# Claude.md

## Response Conventions

- When writing math in the chat response, use ASCII characters so I can view the symbols in the terminal.
- Never use double dashes (--) in responses or in written content. Use alternative phrasing or punctuation instead (e.g., a colon, a period, or restructure the sentence).

## File Handling

- When the Read tool fails on a PDF due to a naming issue (special characters, curly quotes, etc.), ask the user to rename the file and then retry with the Read tool. Do not install packages or run Python/shell scripts to read PDFs as a workaround.
- When asked to convert markdown to PDF, use `pandoc <input>.md -o <output>.pdf -V geometry:margin=1in -V papersize=letter -V linestretch=1.15`, then open the PDF with `open <output>.pdf`.
- When writing consecutive **plain lines** (no bullet markers) that should render on separate lines (e.g., name/course/date metadata at the top of a document), end each line with `\` for a hard line break. Single newlines in markdown are treated as spaces by pandoc. Do **not** add `\` to bullet point lines (`- item`), since each bullet is already a separate block element.

## File Management

Three systems, no overlap. Each file has exactly one canonical home.

| File type | Canonical home | Sync mechanism |
|---|---|---|
| Source code | `~/dev/` | Git / GitHub |
| Markdown notes | `~/notes/` | Obsidian Sync |
| Slides, PDFs, scans, media | `~/Dropbox/` | Dropbox |
| Assignment PDF (coding) | `~/dev/.../docs/` inside the repo | Git / GitHub |
| Dotfiles | `~/.local/share/chezmoi/` | chezmoi / GitHub |

- Code never goes in Dropbox. Git repos contain venvs, node_modules, .git internals that conflict with cloud sync.
- Non-markdown files (PDFs, PPTX, spreadsheets) never go in the Obsidian vault.
- PARA folder names (`00-inbox/`, `01-projects/`, `02-areas/`, `03-resources/`, `04-archive/`) are mirrored between `~/notes/` and `~/Dropbox/`.

### ~/dev/ Structure

```
~/dev/
├── work/          # Employer projects
├── columbia/      # Coursework and class projects
├── personal/      # Side projects, personal tools
├── forks/         # Cloned repos owned by others
└── sandbox/       # Throwaway experiments, learning
```

### Naming Conventions

- **Directories and repos**: `kebab-case` (lowercase, hyphens). No spaces in directory paths.
- **Note filenames**: Regular wording with spaces or `underscore_case`.
- **Special files**: Underscore prefix for sort ordering (e.g., `_moc.md`).

## Coding Conventions

- No emojis ever
- Always use straight quotes, never curly quotes.
- Don't touch requirements.txt. Install packages using `pip install`, then use `pip freeze > requirements.txt` to generate the file.
- When creating visualizations using Python, use Plotly by default (not Matplotlib), unless otherwise specified.

### Markdown

These instructions below are for when writing/editing markdown files.

- Have blanklines between headers
- When writing math, surround with single `$` for in-line math, and surround with double `$$` for block math.
- When writing math in the chat output, don't use the latex format but show using unicode symbols.
- When writing notes, separate clear sections by horizontal lines using `---`.
