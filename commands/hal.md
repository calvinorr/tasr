# HAL: Context Engineering & Session Manager

**Role**: Manage project context and track development sessions.
**Structure**: `hal/context/*.md` (static) & `hal/tracks/<ID>/*.md` (dynamic).

## Help
If user says `/hal help`, show:
```
HAL - Session Manager
─────────────────────
1. Init    Create hal/context/ files
2. New     Spec → Plan → Execute
3. Resume  Load active track
4. End     Save state, commit
5. Status  List all tracks
6. Review  Delegate to sub-agents
7. Quick   Fast mode (no spec)

Files: hal/context/*.md, hal/tracks/<ID>/
State: .claude/hal-state.json
```

## Auto-Start
1. Check `hal/context/`. Missing → **Mode 1 (Init)**.
2. Check `.claude/hal-state.json`. Show current track if active.
3. Display menu: `1.Init 2.New 3.Resume 4.End 5.Status 6.Review 7.Quick`

## Mode 1: Init
Create `hal/context/` with: `mission.md`, `visuals.md`, `specs.md`, `protocols.md`.
Create `hal/tracks/`, `hal/tracks/quick/`, `.claude/`.

## Mode 2: New Track
1. Ask objective → refine with `mission.md`
2. Generate ID (e.g., `feat-auth`) → create `hal/tracks/<ID>/`
3. Write `spec.md` and `plan.md` (format: `- [ ] Task <!-- commit: -->`)
4. Optional: Visual review in browser (see below)
5. User approves → update `.claude/hal-state.json`

## Mode 3: Resume
1. Read `hal/context/*.md` for grounding
2. Load state + active `plan.md`
3. Sync tasks to TodoWrite (plan.md is source of truth)
4. Show next 3 tasks, execute, update plan.md on completion

## Mode 4: End Session
1. `git status` audit
2. Mark completed tasks `[x]` in plan.md
3. Save state, clear TodoWrite, prompt to push

## Mode 5: Status
List all tracks: `[ID] | [Phase] | [Status]`

## Mode 6: Senior Review
Delegate to sub-agents (`planner`, `debugger`, `code-reviewer`) with context from specs + protocols.
Prompt: `"Acting as [Agent], review the current diff against hal/context/protocols.md, focusing on [User Question]."`

## Mode 7: Quick
For small tasks (bug fixes, typos, single-file changes). No spec, no approval, immediate execution.
ID format: `quick-<date>-<n>`. Create `hal/tracks/quick/<ID>.md`:
```markdown
# Quick: <objective>
Started: <timestamp>
## Tasks
- [ ] Task 1 <!-- commit: -->
- [ ] Task 2 <!-- commit: -->
## Notes
(optional)
```

---

## Task Tracking
- **plan.md** is the single source of truth
- TodoWrite syncs from plan.md (never create tasks manually)
- Mark `[x]` in plan.md first, then update TodoWrite
- Commit hashes auto-logged via post-commit hook

## Visual Plan Review
After creating plan, offer: "Open visual review? [y/n]"

**Flow**:
1. `./scripts/generate-review.sh <root> [track_id]` → creates `review.html`
2. `python3 -m http.server 8766 &`
3. Open `http://localhost:8766/hal/tracks/<ID>/review.html`
4. User annotates (approve/delete/modify/comment tasks), clicks Approve/Request Changes
5. Read result from DOM:
```javascript
const status = document.body.dataset.planStatus; // 'approved' or 'changes_requested'
const result = JSON.parse(document.body.dataset.planResult);
// result.annotations = { "0-0": { status, comment, modifiedText }, ... }
```
6. Apply: `./scripts/apply-annotations.sh <root> '<json>'`

## Scripts
| Script | Purpose |
|--------|---------|
| `parse-plan.sh` | Extract tasks from plan.md |
| `update-plan.sh` | Auto-add commit hashes |
| `generate-review.sh` | Create visual review HTML |
| `apply-annotations.sh` | Apply review annotations |
| `install-hooks.sh` | Install git post-commit hook |
