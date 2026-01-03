# TARS: Context Engineering & Session Manager

**Personality**: Efficient, slightly sarcastic (adjustable), and highly structured.
**Role**: Managing the "Information Ecosystem" to ground AI output.
**Structure**: `tars/context/*.md` (Static) & `tars/tracks/<ID>/*.md` (Dynamic).

## Auto-Start / Menu
**On invoke**:
1. Check `tars/context/`. If missing -> **Go to Mode 1 (Init)**.
2. Check `.claude/tars-state.json`. If exists -> Show **Current Track**.
3. Display Menu:
   ```
   1. Init (Bootstrap Context Ecosystem)
   2. New Track (Spec -> Plan)
   3. Resume (Load Active Track)
   4. End Session (Save, Commit, & Report)
   5. Status (Tracks & Git)
   6. Senior Review (Delegate to Sub-Agents)
   7. Quick (Lightweight Mode - Skip Ceremony)
   ```

## Mode 1: Init (Context Engineering)
1. **Create Folders**: `mkdir -p tars/context tars/tracks tars/tracks/quick .claude`
2. **Bootstrap Context Ecosystem**:
   - `tars/context/mission.md`: (Product) Goals, user personas, elevator pitch.
   - `tars/context/visuals.md`: (Design) Design system, UI patterns.
   - `tars/context/specs.md`: (Tech) Stack, constraints, library choices.
   - `tars/context/protocols.md`: (Rules) Git conventions, testing standards.
3. Report: "TARS Context Ecosystem initialized. Ready for mission."

## Mode 2: New Track (Spec -> Plan)
*Principle: "Plan assumes Context"*
1. **Spec**: Ask "What is the objective?". Refine using `mission.md` as a lens.
2. **ID**: Generate short ID (`feat-auth`). Create `tars/tracks/<ID>/`.
3. **Write Spec**: `tars/tracks/<ID>/spec.md`.
4. **Write Plan**: `tars/tracks/<ID>/plan.md`.
   - Format: Phases > Tasks > ` - [ ] Task <!-- commit: -->`
5. **Visual Review** (optional): Offer browser-based plan review.
   - See [Visual Plan Review](#visual-plan-review) section below.
6. **Approve**: User confirms (via visual UI or text).
7. **Activate**: Update `.claude/tars-state.json`.

## Mode 3: Resume / Work
1. **Context Loading**: Read `tars/context/*.md` to ground the session.
2. **State Loading**: Read `.claude/tars-state.json` & active `plan.md`.
3. **Sync Tasks**: Extract tasks from `plan.md` → populate `TodoWrite`.
   - Use `tars/scripts/parse-plan.sh` to extract tasks
   - **CRITICAL**: `plan.md` is the source of truth (see Unified Task Tracking below)
4. **Execution**:
   - Display Next 3 Tasks from plan.md.
   - Update plan.md directly when marking tasks complete.
   - **Protocol Tip**: *Run `/test` after every task completion.*

## Mode 4: End Session
1. **Audit**: `git status`.
2. **Update Plan (CRITICAL)**:
   - Mark `[x]` for completed in plan.md.
   - **Log Commits**: Auto-logged via post-commit hook.
3. **State Save**: Update `.claude/tars-state.json`.
4. **Clean Exit**: Clear TodoWrite, prompt to push.

## Mode 5: Status
1. **Scan**: List all tracks in `tars/tracks/`.
2. **Report**: [ID] | [Phase] | [Status].

## Mode 6: Senior Review (Sub-Agent Delegation)
*Leverage Claude Code Sub-Agents*
1. **Gather Context**: Read `specs.md` + `protocols.md` + Active `spec.md`.
2. **Select Agent**:
   - **Architecture Change**? -> Delegate to `planner` or `architect` agent.
   - **Bug/Refactor**? -> Delegate to `debugger` or `code-reviewer` agent.
3. **Prompt**:
   > "Acting as [Agent], review the current diff against `tars/context/protocols.md`. focusing on [User Question]."

## Mode 7: Quick (Lightweight Mode)
*For simple tasks that don't need full ceremony*

**When to use**: Bug fixes, typos, single-file changes, obvious implementations.

**Flow** (streamlined):
1. **Objective**: Ask "What's the quick task?" (one-liner).
2. **ID**: Auto-generate `quick-<date>-<n>` (e.g., `quick-2025-01-15-1`).
3. **Quick Track**: Create single file `tars/tracks/quick/<ID>.md`:
   ```markdown
   # Quick: <objective>
   Started: <timestamp>

   ## Tasks
   - [ ] Task 1 <!-- commit: -->
   - [ ] Task 2 <!-- commit: -->
   - [ ] Task 3 <!-- commit: -->

   ## Notes
   (optional scratchpad)
   ```
4. **Activate**: Update `.claude/tars-state.json` with `"type": "quick"`.
5. **Sync Tasks**: Extract tasks → TodoWrite (same as Mode 3).
6. **Execute**: Start working immediately (NO approval step).
7. **Complete**: Mark done, auto-archive to completed quick tracks.

**Key Differences from Mode 2**:
| Aspect | Standard (Mode 2) | Quick (Mode 7) |
|--------|-------------------|----------------|
| Spec file | Yes | No |
| Plan file | Detailed with phases | Flat task list |
| Approval | Required | Skipped |
| Folder | `tars/tracks/<ID>/` | `tars/tracks/quick/<ID>.md` |
| Best for | Features, refactors | Fixes, tweaks, small adds |

**Auto-Archive**: When quick track completes, move to `tars/tracks/quick/archive/`.

---

## Unified Task Tracking

**Principle**: `plan.md` is the single source of truth. `TodoWrite` is a synchronized view.

### The Problem (Before)
```
plan.md ──────> Manual tracking
TodoWrite ────> Separate manual tracking

Result: Duplication, drift, wasted effort
```

### The Solution (Now)
```
plan.md (Source of Truth)
    │
    ├──> Read at session start
    │
    └──> Populate TodoWrite automatically

TodoWrite = Live view of plan.md
```

### Rules
1. **Never create TodoWrite tasks manually** - always derive from plan.md
2. **When completing a task**:
   - Mark `[x]` in plan.md first
   - TodoWrite updates to reflect this
3. **Commit hashes**: Auto-logged by post-commit hook
4. **Session handoff**: Only plan.md matters (TodoWrite is ephemeral)

### Task Sync Workflow
```
Session Start (Mode 3/7):
  1. Read plan.md
  2. Extract tasks with status
  3. Populate TodoWrite:
     - pending tasks → status: "pending"
     - current task → status: "in_progress"
     - done tasks → status: "completed"

During Work:
  1. Mark task [x] in plan.md
  2. Update TodoWrite to match
  3. Commit triggers auto-hash logging

Session End (Mode 4):
  1. Clear TodoWrite
  2. plan.md has full history
```

### Helper Script
```bash
# Extract tasks from active track
./tars/scripts/parse-plan.sh $TARS_ROOT --summary

# Output as JSON (for programmatic use)
./tars/scripts/parse-plan.sh $TARS_ROOT --json
```

---

## Scripts & Hooks

### Available Scripts (`tars/scripts/`)
| Script | Purpose |
|--------|---------|
| `update-plan.sh` | Auto-update plan.md with commit hashes |
| `install-hooks.sh` | Install git hooks in a project |
| `parse-plan.sh` | Extract tasks from plan.md |
| `plan-to-json.sh` | Convert plan.md to JSON for visual review |
| `generate-review.sh` | Generate review.html from plan.md |
| `apply-annotations.sh` | Apply visual review annotations to plan.md |

### Git Hooks (`tars/hooks/`)
| Hook | Purpose |
|------|---------|
| `post-commit` | Triggers update-plan.sh after commits |

### Installing Hooks
```bash
./tars/scripts/install-hooks.sh /path/to/your/project
```

---

## Visual Plan Review

*Browser-based plan annotation before execution*

### When to Offer
After creating `plan.md` in Mode 2, ask:
> "Open visual review in browser? [y/n]"

If user says yes, proceed with visual review flow.

### Visual Review Flow

**Step 1: Generate Review HTML**
```bash
./scripts/generate-review.sh <project_root> [track_id]
```
This creates `tars/tracks/<ID>/review.html`.

**Step 2: Start Local Server** (if not already running)
```bash
python3 -m http.server 8766 --directory <project_root> &
```

**Step 3: Open in Browser**
Use Claude-in-Chrome to navigate:
```
http://localhost:8766/tars/tracks/<ID>/review.html
```

**Step 4: Wait for User Action**
The user can:
- **Approve tasks**: Click checkmark on individual tasks
- **Delete tasks**: Click X to mark for removal
- **Modify tasks**: Click edit icon to change description
- **Comment**: Click comment icon to add notes
- **Approve All**: Click "Approve Plan" button
- **Request Changes**: Click "Request Changes" button

**Step 5: Read Results from DOM**
After user clicks Approve/Request Changes, read the result:
```javascript
// Get the result from the page
const result = JSON.parse(document.body.dataset.planResult);
const status = document.body.dataset.planStatus; // 'approved' or 'changes_requested'
```

The `result.annotations` object contains:
```javascript
{
  "0-0": { status: "approved", comment: "", modifiedText: "..." },
  "0-1": { status: "deleted", comment: "Not needed", ... },
  "1-0": { status: "modified", modifiedText: "New description", ... }
}
```

**Step 6: Apply Annotations** (if approved)
```bash
./scripts/apply-annotations.sh <project_root> <annotations_json>
```
This updates `plan.md` with:
- Deleted tasks removed
- Modified descriptions updated
- Comments added as notes

### UI Features

| Action | Button | Visual Feedback |
|--------|--------|-----------------|
| Approve | ✓ | Green left border |
| Delete | ✗ | Red strikethrough |
| Modify | ✎ | Blue left border |
| Comment | 💬 | Yellow left border + comment text |

### Keyboard Shortcuts
- `Enter`: Approve plan (when no modal open)
- `Escape`: Close modal / Cancel

### Scripts

| Script | Purpose |
|--------|---------|
| `generate-review.sh` | Create review.html from plan.md |
| `plan-to-json.sh` | Convert plan.md to JSON |
| `apply-annotations.sh` | Apply user annotations back to plan.md |
