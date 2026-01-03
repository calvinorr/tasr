# Technical Specifications - TARS Ecosystem

## Stack

| Layer | Technology |
|-------|------------|
| Runtime | Claude Code CLI |
| Language | Markdown (skills, plans) + Bash (scripts) |
| Storage | Local filesystem (markdown files) |
| Hooks | Git post-commit hooks |

## Architecture

```
tasr/
├── commands/          # User-invocable slash commands
│   ├── tars.md       # Main session manager
│   ├── jarvis.md     # Alternative epic-based manager
│   ├── test.md       # Visual testing
│   ├── db.md         # Database management
│   ├── senior-review.md
│   └── new-project.md
├── skills/
│   └── tars-assistant/
│       └── SKILL.md  # Auto-invoked skill
├── scripts/          # Helper bash scripts
│   ├── parse-plan.sh
│   ├── update-plan.sh
│   └── install-hooks.sh
├── hooks/            # Git hooks
│   └── post-commit
└── examples/         # Reference implementations
    ├── context/
    └── tracks/
```

## Architecture Decisions

### ADR-001: Markdown-based storage
**Decision**: Store plans and context in markdown files.
**Rationale**: Git-trackable, human-readable, no dependencies.

### ADR-002: State file in .claude
**Decision**: Store session state in `.claude/tars-state.json`.
**Rationale**: Project-local, gitignore-able, JSON for parsing.

### ADR-003: User-level installation
**Decision**: Copy to `~/.claude/commands/` and `~/.claude/skills/`.
**Rationale**: Works across all projects without per-project setup.

## Constraints

1. Must work offline (local files only)
2. No external services required
3. Compatible with any project type
4. Minimal setup overhead
5. Claude Code native (no custom runtime)

## Dependencies

```json
{
  "runtime": "Claude Code CLI",
  "required": ["bash", "git"],
  "optional": ["jq"]
}
```
