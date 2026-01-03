# TARS - Context Engineering & Session Manager

A Claude Code skill ecosystem for managing development sessions, tracking progress, preventing scope creep, and maintaining project context across conversations.

## Overview

TARS (Task & Resource System) is a comprehensive session management system that helps you:

- **Maintain Context**: Project context persists across Claude Code sessions
- **Track Progress**: Tasks and commits are logged to markdown files
- **Prevent Drift**: Scope guardrails keep you focused on current objectives
- **Delegate Wisely**: Built-in integration with Claude Code subagents

## Architecture

```
TARS Ecosystem
├── /tars (main command) ─────── Session management & planning
├── /jarvis ──────────────────── Alternative session manager (epic-based)
├── /test ────────────────────── Visual/E2E testing with Chrome
├── /db ──────────────────────── Database management (Turso/SQLite)
├── /senior-review ───────────── Code review & architecture advice
└── /new-project ─────────────── Project scaffolding with docs structure
```

## Installation

### Quick Install (User-Level)

Copy commands and skills to your Claude Code config:

```bash
# Create directories
mkdir -p ~/.claude/commands ~/.claude/skills/tars-assistant

# Copy commands
cp commands/*.md ~/.claude/commands/

# Copy skill
cp skills/tars-assistant/SKILL.md ~/.claude/skills/tars-assistant/

# Make scripts available globally (optional)
mkdir -p ~/.claude/tars/scripts
cp scripts/*.sh ~/.claude/tars/scripts/
chmod +x ~/.claude/tars/scripts/*.sh
```

### Project-Level Install

For per-project installation with git hooks:

```bash
# From your project directory
/path/to/tasr/scripts/install-hooks.sh .

# This creates:
# - tars/scripts/ (helper scripts)
# - tars/hooks/ (git hooks)
# - .git/hooks/post-commit (auto-logging)
```

## Usage

### Starting TARS

```bash
# In Claude Code, invoke the command
/tars
```

TARS will display a menu:

```
1. Init (Bootstrap Context Ecosystem)
2. New Track (Spec -> Plan)
3. Resume (Load Active Track)
4. End Session (Save, Commit, & Report)
5. Status (Tracks & Git)
6. Senior Review (Delegate to Sub-Agents)
7. Quick (Lightweight Mode - Skip Ceremony)
```

### Mode 1: Init (First-Time Setup)

Creates the context ecosystem for your project:

```
tars/
├── context/
│   ├── mission.md      # Product goals, user personas
│   ├── visuals.md      # Design system, UI patterns
│   ├── specs.md        # Tech stack, constraints
│   └── protocols.md    # Git conventions, testing standards
├── tracks/
│   └── quick/          # Lightweight task tracking
└── scripts/            # Helper scripts
```

### Mode 2: New Track (Planning)

Creates a spec and plan for a new feature:

```
tars/tracks/feat-auth/
├── spec.md    # What we're building and why
└── plan.md    # Phased tasks with commit tracking
```

Plan format:
```markdown
## Phase 1: Foundation
- [ ] Create user model <!-- commit: -->
- [ ] Add auth routes <!-- commit: -->
- [x] Setup JWT tokens <!-- commit: abc1234 -->
```

### Visual Plan Review (Optional)

After creating a plan, TARS can open a browser-based review UI:

```
User: "y" to visual review prompt
TARS: Opens http://localhost:8766/tars/tracks/<ID>/review.html
```

In the visual review UI, you can:
- **Approve** individual tasks (checkmark)
- **Delete** tasks you don't need (X)
- **Modify** task descriptions (edit icon)
- **Comment** on tasks (speech bubble)

Keyboard shortcuts:
- `Enter`: Approve entire plan
- `Escape`: Close modals

After approval, annotations are applied back to `plan.md`.

### Mode 3: Resume (Continue Work)

Loads context and active track, syncs tasks to TodoWrite:

1. Reads all `tars/context/*.md` files
2. Loads active track from `.claude/tars-state.json`
3. Extracts tasks from `plan.md` → populates TodoWrite
4. Shows next 3 pending tasks

### Mode 4: End Session

Before clearing context:

1. Audits git status
2. Marks completed tasks in plan.md
3. Saves state to `.claude/tars-state.json`
4. Prompts for commit/push

### Mode 7: Quick Mode

For small tasks that don't need full ceremony:

```markdown
# Quick: fix-typo-readme
Started: 2025-01-03T10:00:00

## Tasks
- [ ] Fix typo in README.md <!-- commit: -->
- [ ] Update version number <!-- commit: -->

## Notes
(optional scratchpad)
```

## File Structure

### State File (`.claude/tars-state.json`)

```json
{
  "activeTrack": "feat-auth",
  "lastTrack": "feat-login",
  "lastTrackStatus": "complete",
  "completedTracks": ["feat-login", "fix-bug-123"],
  "currentStage": "stage-1",
  "futureIdeas": ["idea for later"],
  "initialized": "2025-01-01T00:00:00Z",
  "lastSession": "2025-01-03T10:00:00Z"
}
```

### Context Files

| File | Purpose |
|------|---------|
| `tars/context/mission.md` | Product vision, goals, user personas |
| `tars/context/visuals.md` | Design system, UI patterns, colors |
| `tars/context/specs.md` | Tech stack, architecture decisions |
| `tars/context/protocols.md` | Git workflow, testing standards, code style |

## Scripts

### parse-plan.sh

Extract tasks from the active plan:

```bash
# Summary view
./scripts/parse-plan.sh /path/to/project --summary

# JSON output (for programmatic use)
./scripts/parse-plan.sh /path/to/project --json

# Just pending tasks
./scripts/parse-plan.sh /path/to/project --pending
```

### update-plan.sh

Auto-called by post-commit hook. Adds commit hashes to completed tasks:

```bash
# Manual run (usually automatic via hook)
./scripts/update-plan.sh /path/to/project
```

### install-hooks.sh

Install git hooks in a project:

```bash
./scripts/install-hooks.sh /path/to/your/project
```

## Related Commands

### /jarvis - Alternative Session Manager

Epic-based session management with docs structure:

```
docs/
├── PROJECT_PLAN.md         # Overall project status
├── epics/
│   ├── E1-feature.md       # Epic with user stories
│   └── E2-another.md
└── tests/
    └── homepage.md         # Visual test definitions
```

Use `/jarvis` if you prefer:
- Epic/User Story structure
- Detailed progress tracking
- Parking lot for ideas

### /test - Visual Testing

Browser-based E2E testing using Claude Chrome extension:

```bash
/test tests/homepage.md    # Run single test
/test all                  # Run all tests
/test failed               # Re-run failed tests
/test status               # Show test summary
```

### /db - Database Management

Turso/SQLite database operations:

```bash
/db status              # Show connection and table counts
/db compare             # Compare local vs production schema
/db backup pre-deploy   # Create named backup
/db restore pre-deploy  # Restore from backup
/db migrate migration-1 # Run migration script
/db seed                # Seed from Shopify data
/db reset               # Reset dev DB from golden backup
```

### /senior-review - Code Review

Get honest technical feedback:

```bash
/senior-review          # Review current changes
/senior-review schema   # Review database schema
/senior-review arch     # Architecture assessment
```

### /new-project - Project Scaffolding

Create new projects with Jarvis-compatible docs:

```bash
/new-project
```

Creates:
- Next.js/Vite project
- GitHub repo
- Vercel project
- Turso database
- docs/epics/ structure
- TEST_PROGRESS.md

## Scope Guardrails

TARS prevents scope creep with guardrails defined in CLAUDE.md:

```markdown
## Current Stage: Stage 1
### In Scope:
- User authentication
- Basic profile page

### Out of Scope:
- Payment processing
- Admin dashboard
```

When you drift, TARS will:
1. Acknowledge the idea
2. Offer to save it to `tars/tracks/future-ideas.md`
3. Redirect to current scope
4. Ask if you want to switch focus

## Unified Task Tracking

**Key Principle**: `plan.md` is the single source of truth.

```
plan.md (Source of Truth)
    │
    ├──> Read at session start
    │
    └──> Populate TodoWrite automatically

TodoWrite = Live view of plan.md
```

Rules:
1. Never create TodoWrite tasks manually
2. Mark `[x]` in plan.md first, then update TodoWrite
3. Commit hashes auto-logged via post-commit hook
4. Only plan.md matters for session handoff

## Integration with Claude Code Features

### Subagent Delegation (Mode 6)

TARS suggests appropriate subagents:

| Task Type | Subagent |
|-----------|----------|
| Architecture | `Plan` |
| Code Review | `superpowers:code-reviewer` |
| Exploration | `Explore` |
| Implementation | `general-purpose` |
| Debugging | `superpowers:systematic-debugging` |

### Skill Awareness

Before tasks, TARS checks for applicable skills:

| Task Type | Skill |
|-----------|-------|
| New feature | `superpowers:brainstorming` |
| Implementation | `superpowers:subagent-driven-development` |
| Bug fix | `superpowers:systematic-debugging` |
| UI/Frontend | `frontend-design:frontend-design` |
| Testing | `superpowers:test-driven-development` |

## Tips

1. **Always end sessions properly** - Run `/tars` option 4 before clearing context
2. **Use Quick mode for small tasks** - Don't over-engineer simple fixes
3. **Keep context files updated** - They're read at every session start
4. **Trust the process** - Scope guardrails are there to help

## Troubleshooting

### "No tars-state.json found"

Run `/tars` and choose option 1 (Init) to bootstrap the project.

### Tasks not syncing to TodoWrite

Check that:
1. `.claude/tars-state.json` has `activeTrack` set
2. The plan file exists at the expected path
3. Tasks use the `- [ ]` checkbox format

### Commit hashes not logging

Ensure git hooks are installed:
```bash
./scripts/install-hooks.sh .
```

### Lost progress after session crash

TARS stores `verifiedCriteria` in state file. On next session start, it will offer to recover.

## License

MIT

## Contributing

This is a personal tool ecosystem. Feel free to fork and adapt for your own workflow.
