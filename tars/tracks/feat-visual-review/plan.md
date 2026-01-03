# Plan: Visual Plan Review

**Track ID**: feat-visual-review
**Created**: 2026-01-03
**Status**: Draft

---

## Phase 1: HTML Template

Build the static HTML template that renders a plan visually.

- [x] Create `templates/plan-review.html` base structure <!-- commit: -->
- [x] Add Tailwind CSS via CDN for styling <!-- commit: -->
- [x] Build phase/task card components <!-- commit: -->
- [x] Add task action buttons (approve, delete, modify, comment) <!-- commit: -->
- [x] Add global approve/reject buttons <!-- commit: -->
- [x] Style states: pending, approved, flagged, deleted <!-- commit: -->

## Phase 2: Plan Parser

Convert plan.md to data structure the HTML can render.

- [x] Create `scripts/plan-to-json.sh` parser <!-- commit: -->
- [x] Parse phases from `## Phase N:` headers <!-- commit: -->
- [x] Parse tasks from `- [ ]` / `- [x]` checkboxes <!-- commit: -->
- [x] Extract existing commit hashes <!-- commit: -->
- [x] Output JSON structure for HTML injection <!-- commit: -->

## Phase 3: HTML Generator

Generate the review HTML from plan data.

- [x] Create `scripts/generate-review.sh` <!-- commit: -->
- [x] Inject plan JSON into HTML template <!-- commit: -->
- [x] Handle special characters / escaping <!-- commit: -->
- [x] Write to `tars/tracks/<id>/review.html` <!-- commit: -->

## Phase 4: Browser Integration

Open review in browser and capture results.

- [x] Add review trigger to tars.md Mode 2 (after plan creation) <!-- commit: -->
- [x] Open review.html via Claude-in-Chrome navigate <!-- commit: -->
- [x] Wait for user interaction (approve/reject button click) <!-- commit: -->
- [x] Read annotation state from DOM <!-- commit: -->
- [x] Parse annotations back to structured data <!-- commit: -->

## Phase 5: Plan Update

Apply annotations back to plan.md.

- [x] Create `scripts/apply-annotations.sh` <!-- commit: -->
- [x] Handle deleted tasks (remove from plan) <!-- commit: -->
- [x] Handle modified tasks (update description) <!-- commit: -->
- [x] Handle comments (add as HTML comments or notes section) <!-- commit: -->
- [x] Preserve commit hashes on approved tasks <!-- commit: -->

## Phase 6: Polish & Documentation

- [x] Add keyboard shortcuts (Enter=approve, Esc=cancel) <!-- commit: -->
- [ ] Add confirmation dialog before destructive actions <!-- commit: -->
- [x] Update README with visual review workflow <!-- commit: -->
- [ ] Add example screenshots to docs <!-- commit: -->
- [x] Test full flow end-to-end <!-- commit: -->

---

## Notes

- Keep HTML self-contained (inline styles/scripts) for offline use
- Consider dark mode support (detect system preference)
- Future: could extend to quick track review too
