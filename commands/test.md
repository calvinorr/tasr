# Modular Testing Skill

Execute visual/E2E tests using the Claude Chrome extension as the test runner.

## Description

This skill runs browser-based tests defined in markdown files. Each test file contains steps that Claude executes using Chrome automation tools, then logs results to `TEST_PROGRESS.md`.

## Arguments

`$ARGUMENTS` - Path to a test file (e.g., `tests/homepage.md`) or special commands:
- `all` - Run all tests in `tests/` directory
- `failed` - Re-run only previously failed tests
- `status` - Show test progress summary

## Execution Flow

### Step 1: Parse Arguments

```
Argument received: $ARGUMENTS
```

**If no argument or empty:**
```
Usage: /test <test-file|all|failed|status>

Examples:
  /test tests/homepage.md    Run single test
  /test all                  Run all tests in tests/
  /test failed               Re-run failed tests
  /test status               Show test summary

Available tests:
  [List files in tests/*.md]
```

**If `status`:**
Skip to Step 6 (Show Summary).

**If `failed`:**
Read TEST_PROGRESS.md, find tests with FAIL status, run those.

**If `all`:**
```bash
ls tests/*.md
```
Queue all found test files.

**If specific file:**
Verify file exists, queue that single test.

### Step 2: Prepare Browser

Before running tests, ensure browser is ready:

1. Get tab context:
```
Use mcp__claude-in-chrome__tabs_context_mcp to get available tabs
```

2. Create a fresh tab for testing:
```
Use mcp__claude-in-chrome__tabs_create_mcp to create new tab
```

3. Store the tab ID for all subsequent operations.

### Step 3: Execute Test File

For each test file in the queue:

#### 3a: Read Test Definition

Read the markdown test file. Expected format:

```markdown
# Test: [Test Name]

## Setup
[Optional setup steps]

## Steps
1. Navigate to [URL]
2. Find element: [description]
3. Click: [element description]
4. Verify: [expected state]
5. Type in [field]: [text]

## Expected
- [Expected outcome 1]
- [Expected outcome 2]

## Cleanup
[Optional cleanup steps]
```

#### 3b: Parse Steps

Extract each step and determine the action:
- **Navigate to [URL]** → Use `mcp__claude-in-chrome__navigate`
- **Find element: [desc]** → Use `mcp__claude-in-chrome__find`
- **Click: [element]** → Use `mcp__claude-in-chrome__computer` with action: left_click
- **Verify: [state]** → Use `mcp__claude-in-chrome__read_page` or `find` to confirm
- **Type in [field]: [text]** → Use `mcp__claude-in-chrome__form_input`
- **Wait [N] seconds** → Use `mcp__claude-in-chrome__computer` with action: wait
- **Screenshot** → Use `mcp__claude-in-chrome__computer` with action: screenshot
- **Check console for errors** → Use `mcp__claude-in-chrome__read_console_messages`

#### 3c: Execute Each Step

For each step:
1. Log: `Executing: [step description]`
2. Perform the action using appropriate Chrome tool
3. Check result
4. If step fails, mark test as FAILED and capture details

#### 3d: Verify Expected Outcomes

After all steps, verify each expected outcome:
- Use `read_page` or `find` to confirm expected state
- Use `read_console_messages` to check for JavaScript errors

### Step 4: Handle Failures

If any step fails or expected outcome not met:

1. **Capture screenshot:**
```
Use mcp__claude-in-chrome__computer with action: screenshot
```

2. **Save screenshot:**
The screenshot will be captured. Note the failure for the report.

3. **Capture console errors:**
```
Use mcp__claude-in-chrome__read_console_messages with onlyErrors: true
```

4. **Record failure details:**
- Step that failed
- Expected vs actual
- Console errors
- Screenshot reference

### Step 5: Log Results

Append results to `TEST_PROGRESS.md`:

```markdown
## [TIMESTAMP]

### [Test Name]
- **File:** [test file path]
- **Status:** PASS | FAIL
- **Duration:** [X] seconds
- **Steps:** [N]/[Total] completed

[If FAIL:]
#### Failure Details
- **Failed Step:** [Step N: description]
- **Expected:** [expected]
- **Actual:** [actual]
- **Console Errors:** [errors or "None"]
- **Screenshot:** `test-failures/[timestamp]-[test-name].png`

---
```

Format for TEST_PROGRESS.md header (create if doesn't exist):

```markdown
# Test Progress

Last run: [TIMESTAMP]
Total: [N] tests | Passed: [N] | Failed: [N]

---

[Individual test results below]
```

### Step 6: Show Summary

After all tests complete (or for `status` command):

```
Test Results
============

[DATE TIME]

┌─────────────────────┬────────┬──────────┐
│ Test                │ Status │ Duration │
├─────────────────────┼────────┼──────────┤
│ homepage.md         │ PASS   │ 2.3s     │
│ cart-add.md         │ FAIL   │ 5.1s     │
│ checkout.md         │ PASS   │ 8.2s     │
└─────────────────────┴────────┴──────────┘

Summary: 2/3 passed (67%)

[If failures:]
Failed Tests:
  - cart-add.md: Element "Add to Cart" not found
    Screenshot: test-failures/2024-12-27-cart-add.png

Run `/test failed` to re-run failed tests.
```

## Test File Format

Test files should follow this structure:

```markdown
# Test: [Descriptive Name]

> Brief description of what this test verifies

## URL
[Starting URL for the test]

## Steps
1. [First action]
2. [Second action]
3. [Third action]

## Verify
- [ ] [First verification]
- [ ] [Second verification]

## Console
- Errors allowed: none | [specific patterns to ignore]
```

### Supported Step Types

| Step Syntax | Action |
|-------------|--------|
| `Navigate to [URL]` | Go to URL |
| `Click [element description]` | Find and click element |
| `Click button "[text]"` | Click button with text |
| `Click link "[text]"` | Click link with text |
| `Type "[text]" in [field]` | Enter text in input |
| `Wait [N] seconds` | Pause execution |
| `Scroll to [element]` | Scroll element into view |
| `Verify [element] exists` | Check element present |
| `Verify text "[text]" visible` | Check text on page |
| `Verify URL contains "[path]"` | Check current URL |
| `Take screenshot` | Capture current state |

### Verification Syntax

| Verify Syntax | Check |
|---------------|-------|
| `[element] is visible` | Element exists and visible |
| `[element] contains "[text]"` | Element has text content |
| `Page title is "[title]"` | Document title matches |
| `URL is "[url]"` | Exact URL match |
| `URL contains "[path]"` | URL includes substring |
| `No console errors` | Console has no errors |

## Integration with Jarvis

When `/jarvis` runs end-session (option 2), it should ask:

```
Tests: Did you run /test before clearing?
  - Last test run: [timestamp] or "Never"
  - Test status: [N] passed, [N] failed

Run tests now? (y/n)
```

## Error Handling

### Test File Not Found
```
Error: Test file not found: [path]

Available tests:
  [List tests/*.md files]
```

### Browser Not Available
```
Error: Chrome extension not responding.

Make sure:
1. Claude Chrome extension is installed
2. Browser window is open
3. Extension is connected

Try refreshing the browser and running again.
```

### Step Timeout
If a step takes more than 30 seconds:
```
Warning: Step timed out after 30s
  Step: [description]

Marking test as FAILED and continuing.
```

## Example Test Run

```
$ /test tests/homepage.md

Running: tests/homepage.md
  Test: Homepage Loads Correctly

  [1/4] Navigate to http://localhost:3000... OK
  [2/4] Verify heading "Herbarium Dyeworks" visible... OK
  [3/4] Verify navigation links exist... OK
  [4/4] Check console for errors... OK (0 errors)

  Result: PASS (3.2s)

Logged to TEST_PROGRESS.md
```

## Best Practices

1. **Keep tests focused** - One test file = one user flow
2. **Use descriptive names** - `checkout-guest.md` not `test1.md`
3. **Include cleanup** - Reset state for next test
4. **Check console** - Always verify no JS errors
5. **Run before commits** - Use `/test all` before pushing

Begin by parsing the arguments.
