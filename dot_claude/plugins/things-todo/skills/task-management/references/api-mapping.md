# Things API Parameter Mapping Reference

## Date Parameter Rules

### `when` Parameter (Scheduling)

Use `when` for scheduling when a todo should be worked on:

| User Says | Maps To |
|-----------|---------|
| "tomorrow" | `when: "tomorrow"` |
| "today" | `when: "today"` |
| "tonight" / "this evening" | `when: "evening"` |
| "on March 15" | `when: "2024-03-15"` |
| "next Tuesday" | `when: "YYYY-MM-DD"` (calculated date) |
| "do next week" | `when: "YYYY-MM-DD"` (calculated date) |
| "someday" / "eventually" | `when: "someday"` |
| "anytime" | `when: "anytime"` |

**Keywords triggering `when`:** "on", "do", "for", "tomorrow", "today", "tonight", "someday"

**Reminder format:** Append `@HH:MM` for reminders, e.g., `when: "2024-03-15@14:30"`

### `deadline` Parameter (Hard Due Dates)

Use `deadline` for hard due dates that cannot be missed:

| User Says | Maps To |
|-----------|---------|
| "due Friday" | `deadline: "YYYY-MM-DD"` |
| "deadline March 20" | `deadline: "2024-03-20"` |
| "due by end of month" | `deadline: "YYYY-MM-DD"` (last day) |

**Keywords triggering `deadline`:** "due", "deadline", "due by"

## Location Parameters

### Project/Area Resolution Order

When user says "in [name]":

1. **First:** Search projects using `get_projects` for matching name
2. **Then:** If no project found, search areas using `get_areas`
3. **Use:** `list_id` (preferred) or `list_title` parameter

### Parameters

| Parameter | Use Case |
|-----------|----------|
| `list_id` | UUID of project/area (most reliable) |
| `list_title` | Name of project/area (convenience) |
| `heading` | Heading title within a project |
| `heading_id` | Heading UUID (takes precedence) |

### Default Behavior

- No location specified → Goes to Inbox
- Headings only when explicitly requested

## Todo Operations

### Adding Todos (`add_todo`)

```
title: Required - the todo text
notes: Optional - additional details
when: Optional - scheduling date
deadline: Optional - hard due date
checklist_items: Optional - array of strings
list_id/list_title: Optional - project or area
heading/heading_id: Optional - heading within project
```

### Updating Todos (`update_todo`)

```
id: Required - todo UUID (from search/list)
title: Optional - new title
notes: Optional - new notes
when: Optional - new schedule
deadline: Optional - new deadline
completed: Optional - true to mark done
canceled: Optional - true to cancel
list/list_id: Optional - move to project/area
heading/heading_id: Optional - move under heading
```

### Finding Todos

For fuzzy name matching:
1. Use `search_todos` with query parameter
2. Or use `get_todos` and filter results
3. Match against title (case-insensitive, partial match OK)

## Retrieval Operations

| Operation | Tool | Notes |
|-----------|------|-------|
| Today's todos | `get_today` | Shows scheduled for today |
| Inbox | `get_inbox` | Unprocessed items |
| Upcoming | `get_upcoming` | Future scheduled items |
| Anytime | `get_anytime` | No specific date |
| Someday | `get_someday` | Deferred items |
| Project todos | `get_todos` | Pass `project_uuid` |
| Recent completions | `get_logbook` | Pass `period` like "7d" |
| Search | `search_todos` | By title/notes |
| Advanced search | `search_advanced` | Multiple filters |

## Checklist Items

When user mentions sub-tasks or checklist items:

```
checklist_items: ["Item 1", "Item 2", "Item 3"]
```

Keywords: "with items", "checklist", "subtasks", "steps"

## Natural Language Date Parsing

| Expression | Interpretation |
|------------|----------------|
| "today" | Current date |
| "tomorrow" | Current date + 1 |
| "next [day]" | Next occurrence of that weekday |
| "this [day]" | This week's occurrence |
| "end of week" | Friday or Sunday (context) |
| "end of month" | Last day of current month |
| "in X days" | Current date + X |
| "next week" | Monday of next week |
