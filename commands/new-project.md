# New Project Setup

Help me create a new project with proper naming conventions and Jarvis-compatible docs structure.

## Project Details

The user wants to create a new project. Ask them for:

1. **Project Name** - A short, descriptive name (e.g., "task tracker", "recipe finder", "budget app")
2. **Project Type** - What kind of project:
   - Full-stack Next.js app
   - Vite + React frontend only
   - API/Backend only
   - CLI tool
3. **Database** - Does it need a database? If yes, suggest Turso (SQLite edge)
4. **Auth** - Does it need authentication? If yes, suggest Clerk or NextAuth
5. **Vision** - One sentence: what problem does this solve?
6. **First Epic** - What's the first major milestone? (e.g., "Basic product listing", "User authentication")

## Naming Convention

Based on their project name, generate these standardized names:

- **app-name**: lowercase, hyphen-separated (e.g., `task-tracker`)
- **GitHub Repo**: `{app-name}`
- **Vercel Project**: `{app-name}`
- **Production URL**: `{app-name}.warmwetcircles.com`
- **Database**: `{app-name}-db` (if needed)
- **Local Directory**: `~/Dev/Projects/{AppName}` (PascalCase for Finder, but see note below)

## Setup Steps

Once confirmed, help them:

1. Create the project directory
2. Scaffold the project with appropriate template
3. **Fix package.json name** (npm rejects capitals in package names)
4. Initialize git and create GitHub repo
5. Set up Vercel project (optional)
6. Create Turso database (if needed)
7. Push database schema (with env vars)
8. Generate starter CLAUDE.md for the project
9. **Create Jarvis-compatible docs structure** (see below)
10. Add custom domain to Vercel (instructions)

## Jarvis Docs Structure

Create these files so `/jarvis` works immediately:

### docs/PROJECT_PLAN.md
```markdown
# {Project Name} - Project Plan

## Vision
{User's vision statement}

## Current Phase
Phase 1: Foundation

## Epics

| Epic | Description | Status |
|------|-------------|--------|
| E1: {First Epic Name} | {Brief description} | 🚧 In Progress |

## Parking Lot
- (Ideas captured during development)
```

### docs/epics/E1-{epic-slug}.md
```markdown
# E1: {First Epic Name}

> **Status**: 🚧 IN PROGRESS
> **Priority**: P0

## Overview
{Brief description of what this epic delivers}

## User Stories

### US1.1: {First Story}
**As a** user
**I want to** {goal}
**So that** {benefit}

**Acceptance Criteria:**
- [ ] {First criterion}
- [ ] {Second criterion}
- [ ] {Third criterion}

## Parking Lot
- (Ideas for later)
```

### tests/vibe-check.md
```markdown
# Test: Homepage Vibe Check

> Verifies the app loads correctly

## URL
http://localhost:3000

## Steps
1. Navigate to http://localhost:3000
2. Wait 2 seconds

## Verify
- [ ] Page loads without error
- [ ] No console errors

## Console
- Errors allowed: none
```

### TEST_PROGRESS.md
```markdown
# Test Progress

Last run: Never
Total: 0 tests | Passed: 0 | Failed: 0

---
```

### Directory Structure
```bash
mkdir -p docs/epics tests test-failures
```

## Example Output

For a project named "Budget Tracker" with vision "Track personal spending" and first epic "Basic expense logging":

```
Project Setup Summary
─────────────────────
Name:           budget-tracker
GitHub:         github.com/calvinorr/budget-tracker
Vercel:         budget-tracker
URL:            budget-tracker.warmwetcircles.com
Database:       budget-tracker-db
Local Path:     ~/Dev/Projects/BudgetTracker

Jarvis Docs:
├── docs/PROJECT_PLAN.md
├── docs/epics/E1-basic-expense-logging.md
├── tests/vibe-check.md
└── TEST_PROGRESS.md

Ready to proceed? I'll create everything and you can start with /jarvis.
```

## Commands to Run

```bash
# IMPORTANT: create-next-app fails if directory has capitals (npm naming rules)
# Solution: Create in temp dir with lowercase name, then move files

# Create the PascalCase directory for Finder organization
mkdir -p ~/Dev/Projects/{AppName}
cd ~/Dev/Projects

# Create Next.js app in temp directory (lowercase)
npx create-next-app@latest {app-name}-temp --typescript --tailwind --eslint --app --src-dir=false --use-npm --yes

# Move files to PascalCase directory and cleanup
cp -r {app-name}-temp/* {AppName}/
cp {app-name}-temp/.gitignore {AppName}/
cp {app-name}-temp/.eslintrc.json {AppName}/ 2>/dev/null || true
rm -rf {app-name}-temp
cd {AppName}

# Fix the package name (was set to temp dir name)
# Edit package.json: change "name" from "{app-name}-temp" to "{app-name}"

# Initialize git
git init

# Add test-failures to .gitignore
echo "/test-failures" >> .gitignore

gh repo create {app-name} --public --source=. --remote=origin

# Create Turso database (if needed)
turso db create {app-name}-db
turso db show {app-name}-db --url      # Get DATABASE_URL
turso db tokens create {app-name}-db   # Get DATABASE_AUTH_TOKEN

# Install common deps
npm install lucide-react clsx tailwind-merge drizzle-orm @libsql/client
npm install -D drizzle-kit

# IMPORTANT: drizzle-kit doesn't auto-read .env.local
# To push schema, prefix command with env vars:
DATABASE_URL=libsql://... DATABASE_AUTH_TOKEN=... npm run db:push
```

## Known Issues & Workarounds

1. **npm naming rules**: Package names can't have capitals. Always create Next.js app with lowercase name.
2. **Drizzle env vars**: `drizzle-kit` doesn't read `.env.local`. Either:
   - Prefix commands: `DATABASE_URL=... npm run db:push`
   - Or install `dotenv-cli`: `npx dotenv -e .env.local -- npm run db:push`
3. **Node v24+ issues**: If build fails with module errors, try `rm -rf node_modules && npm install`

Start by asking the user about their project idea!
