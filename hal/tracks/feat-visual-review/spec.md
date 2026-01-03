# Spec: Visual Plan Review

## Objective

Add a browser-based visual review step to HAL plan approval, inspired by Plannotator. Users can annotate plans (delete, modify, comment) before execution begins.

## Problem

Current HAL flow shows plans as markdown text in the terminal. Users must:
- Read through walls of text
- Mentally track what they want to change
- Verbally communicate modifications back

This creates friction and makes plan review feel like a chore rather than collaboration.

## Solution

When HAL creates a plan, offer to open a visual review UI in the browser (via Claude-in-Chrome). The UI displays:
- Plan phases and tasks in a clean layout
- Interactive controls for each task (approve, delete, modify, comment)
- Clear approve/reject buttons at the bottom

Annotations are captured and fed back to update the plan.

## User Flow

```
1. User: "Build auth system"
2. HAL: Creates spec.md and plan.md
3. HAL: "Open visual review? [y/n]"
4. User: "y"
5. HAL: Opens plan-review.html in browser
6. User: Clicks to annotate tasks, adds comments
7. User: Clicks "Approve" or "Request Changes"
8. HAL: Updates plan.md with annotations, proceeds or iterates
```

## UI Requirements

### Plan Display
- Phase headers (collapsible)
- Task cards with checkbox, description, actions
- Visual distinction: pending (white), approved (green), flagged (yellow), deleted (red strikethrough)

### Actions Per Task
- **Approve**: Task proceeds as-is
- **Delete**: Remove from plan (with optional reason)
- **Modify**: Edit task description inline
- **Comment**: Add note for context

### Global Actions
- **Approve All**: Accept plan, begin execution
- **Request Changes**: Send annotations back, iterate on plan
- **Cancel**: Abort without changes

## Technical Approach

### Option A: Static HTML + Claude-in-Chrome
- Generate `plan-review.html` from plan.md
- Open via `mcp__claude-in-chrome__navigate`
- Read user interactions via DOM/form state
- Parse results back to markdown

### Option B: Local Dev Server
- Spin up simple HTTP server (Node/Python)
- Serve interactive SPA
- POST annotations back

**Recommendation**: Option A (simpler, no server dependency)

## Out of Scope (v1)

- Team collaboration / sharing
- Real-time sync
- Obsidian integration
- Persistent annotation history

## Success Criteria

1. User can visually review a plan in browser
2. User can annotate tasks (approve/delete/modify/comment)
3. Annotations update plan.md correctly
4. Clear approve/reject flow
5. Works offline (local HTML file)
