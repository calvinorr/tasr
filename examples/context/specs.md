# Technical Specifications - Example Project

## Stack

| Layer | Technology |
|-------|------------|
| Frontend | Next.js 14 (App Router) |
| Styling | Tailwind CSS |
| Components | shadcn/ui |
| Database | Turso (SQLite edge) |
| ORM | Drizzle |
| Auth | Clerk |

## Architecture Decisions

### ADR-001: Markdown-based storage

**Decision**: Store plans and context in markdown files rather than database.

**Rationale**:
- Git-trackable
- Human-readable
- No external dependencies
- Easy to edit manually

### ADR-002: State file in .claude

**Decision**: Store session state in `.claude/tars-state.json`

**Rationale**:
- Project-local
- Can be gitignored
- JSON for easy parsing

## Constraints

1. Must work offline (local files only)
2. No external services required
3. Compatible with any project type
4. Minimal setup overhead

## Dependencies

```json
{
  "runtime": "Node.js 20+",
  "required": [],
  "optional": [
    "turso-cli",
    "gh-cli"
  ]
}
```
