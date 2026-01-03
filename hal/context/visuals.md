# Visual Design - HAL Ecosystem

## CLI Output Style

### Menu Boxes

```
╔═══════════════════════════════════════════╗
║           HAL - Session Manager          ║
╠═══════════════════════════════════════════╣
║  1. Init    → Bootstrap Context Ecosystem ║
║  2. New     → Create Track (Spec → Plan)  ║
║  3. Resume  → Load Active Track           ║
╚═══════════════════════════════════════════╝
```

### Status Indicators

| Symbol | Meaning |
|--------|---------|
| `[x]` | Completed |
| `[ ]` | Pending |
| `[>]` | In Progress |
| `✓` | Success |
| `✗` | Failed |
| `→` | Leads to |

### Headers

```markdown
## HAL Session Manager

**Status**: Active track loaded
**Track**: feat-auth (Phase 2)
```

### Progress Display

```
Progress: ████████░░░░░░░░ 4/10 tasks
```

## Markdown Conventions

### Plan Files

```markdown
## Phase 1: Foundation
- [ ] Task description <!-- commit: -->
- [x] Completed task <!-- commit: abc1234 -->

## Phase 2: Implementation
- [ ] Next phase tasks
```

### Quick Track Files

```markdown
# Quick: fix-typo
Started: 2025-01-03T10:00:00

## Tasks
- [ ] Task 1
- [ ] Task 2

## Notes
Optional scratchpad
```

### Context Files

```markdown
# Section Name - Project Name

## Subsection

Content with tables, lists, code blocks as needed.
```

## Emoji Usage

Minimal - only where meaningful:
- Commit messages: None (keep clean for parsing)
- README: Sparingly for visual interest
- CLI output: None (stick to ASCII box drawing)
