---
name: Task Management
description: This skill should be used when the user asks to "add todo", "add a task", "things inbox", "todo inbox", "show today's todos", "mark todo done", "complete todo", "reschedule todo", "change date", "move todo", "edit todo", "modify todo", "update todo", "things today", "upcoming todos", "what did I complete", or mentions "things" or "todo" in the context of personal task management. Handles all Things app operations via MCP server.
---

# Task Management with Things

This skill provides personal task management using the Things app via the Things MCP server. It handles adding, viewing, editing, completing, and organizing todos across projects and areas.

## Core Concepts

### Date Parameters: `when` vs `deadline`

**Critical distinction** - these are different fields in Things:

| User Language                                      | Parameter  | Purpose            |
| -------------------------------------------------- | ---------- | ------------------ |
| "tomorrow", "on [date]", "do [date]", "for [date]" | `when`     | When to work on it |
| "due [date]", "deadline [date]"                    | `deadline` | Hard due date      |

Example: "Add todo 'submit report' do Monday with deadline Friday"

- `when: "Monday's date"` (when to start)
- `deadline: "Friday's date"` (must be done by)

### Location: Projects and Areas

When user says "in [name]":

1. Search projects first using `mcp__things__get_projects`
2. If no match, search areas using `mcp__things__get_areas`
3. Use the `list_id` or `list_title` parameter

**Default:** If no location specified, todo goes to Inbox.

**Headings:** Only use heading parameters when user explicitly requests placement under a heading.

### Fuzzy Name Matching

When referencing existing todos by name:

1. Use `mcp__things__search_todos` with the query
2. Match results case-insensitively
3. Partial matches are acceptable
4. If ambiguous, show options and ask for clarification

## Common Workflows

### Adding Todos

Parse the request for:

- **Title:** The main task text
- **When:** Scheduling date (keywords: "tomorrow", "on", "do", "for")
- **Deadline:** Hard due date (keywords: "due", "deadline")
- **Location:** Project or area (keyword: "in")
- **Checklist items:** Subtasks (keywords: "with items", "checklist", "steps")
- **Notes:** Additional details

```
User: "Add todo 'prepare slides' in Work for tomorrow with deadline Friday"

Action: mcp__things__add_todo
  title: "prepare slides"
  when: "tomorrow"
  deadline: "YYYY-MM-DD" (Friday)
  list_title: "Work" (or list_id if found)
```

```
User: "Add task 'buy groceries' with items milk, eggs, bread"

Action: mcp__things__add_todo
  title: "buy groceries"
  checklist_items: ["milk", "eggs", "bread"]
```

### Viewing Todos

| User Request                             | Tool                                       |
| ---------------------------------------- | ------------------------------------------ |
| "things today" / "tasks today"           | `mcp__things__get_today`                   |
| "things inbox" / "todo inbox"            | `mcp__things__get_inbox`                   |
| "upcoming todos" / "what's coming up"    | `mcp__things__get_upcoming`                |
| "someday list"                           | `mcp__things__get_someday`                 |
| "anytime todos"                          | `mcp__things__get_anytime`                 |
| "what did I complete" / "done this week" | `mcp__things__get_logbook`                 |
| "todos in [project]"                     | `mcp__things__get_todos` with project_uuid |
| "find [query]" / "search for [query]"    | `mcp__things__search_todos`                |

When displaying todos, format clearly with:

- Todo title
- Project/area context if relevant
- When date and deadline if set
- Checklist progress if applicable

### Completing Todos

1. Search for the todo using `mcp__things__search_todos`
2. If single match, mark complete with `mcp__things__update_todo` setting `completed: true`
3. If multiple matches, show options and ask which one
4. Confirm completion to user

```
User: "Mark 'call dentist' done"

Steps:
1. search_todos(query: "call dentist")
2. Find matching todo, get its id
3. update_todo(id: "xxx", completed: true)
4. Confirm: "Marked 'Call dentist' as complete"
```

### Rescheduling Todos

1. Find the todo using search
2. Parse the new date from user request
3. Determine if it's `when` or `deadline` based on keywords
4. Update with `mcp__things__update_todo`

```
User: "Move 'team meeting prep' to next Tuesday"

Steps:
1. search_todos(query: "team meeting prep")
2. Calculate next Tuesday's date
3. update_todo(id: "xxx", when: "YYYY-MM-DD")
```

```
User: "Change deadline for 'submit report' to Friday"

Steps:
1. search_todos(query: "submit report")
2. Calculate Friday's date
3. update_todo(id: "xxx", deadline: "YYYY-MM-DD")
```

### Moving Todos Between Projects

1. Find the todo
2. Find the destination project/area
3. Update with `list_id` or `list` parameter

```
User: "Move 'research competitors' to Entrepreneurship"

Steps:
1. search_todos(query: "research competitors")
2. get_projects() and find "Entrepreneurship"
3. update_todo(id: "xxx", list_id: "project-uuid")
```

### Editing Todos

Parse what needs to change:

- Title changes: `title` parameter
- Notes changes: `notes` parameter
- Date changes: `when` or `deadline`
- Location changes: `list_id` or `list`

```
User: "Rename 'call john' to 'call John about project'"

Steps:
1. search_todos(query: "call john")
2. update_todo(id: "xxx", title: "call John about project")
```

## Natural Language Date Handling

Convert natural language to proper date formats:

| Expression                 | Format                                 |
| -------------------------- | -------------------------------------- |
| "today"                    | `"today"` (Things keyword)             |
| "tomorrow"                 | `"tomorrow"` (Things keyword)          |
| "tonight" / "this evening" | `"evening"` (Things keyword)           |
| "someday"                  | `"someday"` (Things keyword)           |
| "next Tuesday"             | Calculate and use `"YYYY-MM-DD"`       |
| "in 3 days"                | Calculate and use `"YYYY-MM-DD"`       |
| "end of month"             | Calculate last day, use `"YYYY-MM-DD"` |
| "next week"                | Calculate Monday, use `"YYYY-MM-DD"`   |

For reminders, append time: `"YYYY-MM-DD@HH:MM"`

## Response Guidelines

### After Adding

Confirm with the created todo details:

- Title
- Location (project/area or Inbox)
- When date if set
- Deadline if set
- Checklist items if any

### After Viewing

Present todos in a clean, scannable format. Group by project/area if showing mixed results.

### After Completing

Confirm what was completed. If from today's list, optionally mention remaining count.

### After Modifying

Confirm the specific change made:

- "Rescheduled 'X' to Tuesday"
- "Moved 'X' to Project Y"
- "Updated deadline for 'X' to March 15"

## Error Handling

### No Matches Found

If search returns no results:

- Confirm the search term used
- Suggest checking spelling or using different keywords
- Offer to show inbox or today's list instead

### Multiple Matches

If search returns multiple similar todos:

- List the options with distinguishing details (project, dates)
- Ask user to clarify which one
- Use numbering for easy selection

### Project/Area Not Found

If specified location doesn't exist:

- List similar-sounding projects/areas
- Offer to add to Inbox instead
- Ask if user wants to create the project

## Additional Resources

For detailed parameter mappings and API reference:

- **`references/api-mapping.md`** - Complete parameter rules, date formats, and tool reference
