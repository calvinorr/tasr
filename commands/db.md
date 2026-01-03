# Database Management Skill

Manage Turso/SQLite databases for herbarium-dyeworks and other projects.

## Description

This skill provides database management commands for development, testing, and production environments. It supports Turso (remote LibSQL) and local SQLite databases.

## Arguments

`$ARGUMENTS` - Command to execute:
- `status` - Show current DB connection and table counts
- `compare` - Compare local vs production schema
- `backup [name]` - Create named backup
- `restore [name]` - Restore from backup
- `migrate [name]` - Run a migration script
- `seed` - Seed from Shopify data
- `reset` - Reset dev database from golden backup

## Known Databases

### herbarium-dyeworks

| Name | Purpose | URL |
|------|---------|-----|
| `herbarium-dyeworks-db` | Primary database | `libsql://herbarium-dyeworks-db-calvinorr.aws-eu-west-1.turso.io` |
| `herbarium-dyeworks-golden` | Immutable backup | `libsql://herbarium-dyeworks-golden-calvinorr.aws-eu-west-1.turso.io` |

## Execution Flow

### Step 1: Parse Arguments

```
Argument received: $ARGUMENTS
```

**If no argument or empty:**
```
Usage: /db <command> [options]

Commands:
  status              Show DB connection and table counts
  compare             Compare local vs production schema
  backup [name]       Create named backup (default: timestamped)
  restore [name]      Restore from backup
  migrate [name]      Run migration script
  seed                Seed from Shopify export data
  reset               Reset dev DB from golden backup

Examples:
  /db status
  /db backup pre-migration
  /db restore pre-migration
  /db migrate e16-remove-variants
```

### Step 2: Load Environment

Read database configuration from environment:

1. Check for `.env.local` in current project:
```bash
cat .env.local 2>/dev/null | grep -E "^(DATABASE_URL|DATABASE_AUTH_TOKEN)="
```

2. Determine database type:
   - If `DATABASE_URL` starts with `file:` → Local SQLite
   - If `DATABASE_URL` starts with `libsql://` → Turso remote

3. Display connection info:
```
Database Configuration:
  Type: [Local SQLite | Turso Remote]
  URL: [masked URL showing only host]
  Auth: [Configured | Not configured]
```

---

## Command: status

Show current database connection and table statistics.

### Execution

1. **Connect and verify:**
```bash
# For Turso, use turso CLI
turso db shell [db-name] "SELECT 'connected' as status;"
```

2. **Get table counts:**
```sql
SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE '_litestream%' AND name NOT LIKE '__drizzle%';
```

3. **For each table, count rows:**
```sql
SELECT '[table]' as tbl, COUNT(*) as cnt FROM [table];
```

4. **Display results:**
```
Database Status: herbarium-dyeworks-db
═══════════════════════════════════════

Connection: OK
Type: Turso Remote
Region: aws-eu-west-1

Tables:
┌─────────────────────────┬─────────┐
│ Table                   │ Rows    │
├─────────────────────────┼─────────┤
│ products                │ 198     │
│ product_images          │ 281     │
│ categories              │ 17      │
│ customers               │ 0       │
│ orders                  │ 0       │
│ order_items             │ 0       │
│ shipping_zones          │ 5       │
│ shipping_rates          │ 15      │
│ ...                     │ ...     │
└─────────────────────────┴─────────┘

Total: [N] tables, [N] rows
```

---

## Command: compare

Compare schema between environments.

### Execution

1. **Get local schema:**
```bash
# From drizzle schema file
cat lib/db/schema.ts
```

2. **Get production schema:**
```bash
turso db shell herbarium-dyeworks-db ".schema"
```

3. **Parse and compare:**
   - Extract table definitions from both
   - Identify missing tables
   - Identify column differences
   - Identify index differences

4. **Display diff:**
```
Schema Comparison: Local vs Production
══════════════════════════════════════

Local (Drizzle schema): lib/db/schema.ts
Production: herbarium-dyeworks-db

Differences Found: [N]

Tables only in Local:
  - [table_name]

Tables only in Production:
  - [table_name]

Column Differences:
  products:
    - Local has: colorHex (text)
    - Production missing: colorHex

  [table]:
    - [difference]

Indexes:
  - [index differences]

Recommendation:
  Run `npm run db:push` to sync schema to production
  Or run `/db migrate [name]` for controlled migration
```

---

## Command: backup [name]

Create a named backup of the database.

### Execution

1. **Determine backup name:**
   - If name provided: use `[name]`
   - If no name: use `backup-[YYYY-MM-DD-HHMMSS]`

2. **Create backup directory:**
```bash
mkdir -p backups
```

3. **Export database:**
```bash
# For Turso
turso db shell herbarium-dyeworks-db .dump > backups/[name].sql
```

4. **Verify backup:**
```bash
wc -l backups/[name].sql
head -20 backups/[name].sql
```

5. **Display result:**
```
Backup Created
══════════════

Name: [name]
File: backups/[name].sql
Size: [N] KB
Tables: [N]
Rows: [N] (estimated from INSERT count)

To restore: /db restore [name]
```

---

## Command: restore [name]

Restore database from a backup.

### Execution

1. **Verify backup exists:**
```bash
ls -la backups/[name].sql
```

2. **Show backup info:**
```
Backup: [name]
Created: [file date]
Size: [N] KB

WARNING: This will REPLACE all data in the target database.
```

3. **Confirm with user:**
```
Restore [name] to [database]?
This action cannot be undone.

Type 'yes' to confirm:
```

4. **If confirmed, restore:**
```bash
turso db shell [db-name] < backups/[name].sql
```

5. **Verify restore:**
Run `/db status` to show new table counts.

---

## Command: migrate [name]

Run a named migration script.

### Execution

1. **Find migration script:**
```bash
ls scripts/migrations/[name].ts 2>/dev/null || ls scripts/migrations/[name].sql
```

2. **If not found:**
```
Migration not found: [name]

Available migrations:
  [List scripts/migrations/*.ts and *.sql]

To create a migration:
  Create file: scripts/migrations/[name].ts
```

3. **If found, show preview:**
```
Migration: [name]
File: scripts/migrations/[name].ts

Preview (first 50 lines):
[Show file contents]

Options:
1. Run in dry-run mode (preview only)
2. Run migration
3. Cancel
```

4. **For dry-run:**
Execute with `DRY_RUN=true` environment variable.
Show what would change without modifying data.

5. **For actual run:**
```bash
npx tsx scripts/migrations/[name].ts
```

6. **Log result:**
Append to `migrations.log`:
```
[TIMESTAMP] | [name] | [SUCCESS/FAILED] | [duration] | [rows affected]
```

---

## Command: seed

Seed database from Shopify export data.

### Execution

1. **Check for Shopify data:**
```bash
ls scripts/seed/shopify-*.json 2>/dev/null
ls data/shopify-*.csv 2>/dev/null
```

2. **If no data found:**
```
No Shopify export data found.

Expected locations:
  - scripts/seed/shopify-products.json
  - scripts/seed/shopify-collections.json
  - data/shopify-products.csv

To export from Shopify:
  1. Go to Shopify Admin > Products > Export
  2. Choose CSV format
  3. Save to data/shopify-products.csv

Or use the existing import script:
  npx tsx scripts/import-from-shopify.ts
```

3. **If data exists, show summary:**
```
Shopify Data Found:
  - Products: [N] records
  - Collections: [N] records
  - Customers: [N] records (if available)

This will:
  1. Clear existing products, categories, images
  2. Import all Shopify products
  3. Create category assignments
  4. Download/link product images

Proceed? (y/n)
```

4. **Execute seed:**
```bash
npx tsx scripts/seed-from-shopify.ts
```

---

## Command: reset

Reset development database from golden backup.

### Execution

1. **Verify this is NOT production:**
```
Current database: [DATABASE_URL]

WARNING: This will reset the database to the golden backup state.
All current data will be lost.
```

2. **If production URL detected:**
```
ERROR: Cannot reset production database.
Use /db restore [backup-name] for controlled restoration.
```

3. **Execute reset:**
```bash
# Dump from golden
turso db shell herbarium-dyeworks-golden .dump > /tmp/golden-backup.sql

# Restore to dev
turso db shell herbarium-dyeworks-db < /tmp/golden-backup.sql

# Cleanup
rm /tmp/golden-backup.sql
```

4. **Show new status:**
Run `/db status` to confirm.

---

## Error Handling

### Database Connection Failed
```
Error: Could not connect to database

Troubleshooting:
1. Check DATABASE_URL in .env.local
2. Check DATABASE_AUTH_TOKEN is set
3. Verify Turso database exists: turso db list
4. Check network connectivity
```

### Turso CLI Not Installed
```
Error: turso CLI not found

Install with:
  curl -sSfL https://get.tur.so/install.sh | bash

Or with Homebrew:
  brew install tursodatabase/tap/turso
```

### Permission Denied
```
Error: Permission denied for database operation

For Turso:
  - Check auth token has write permissions
  - Verify database ownership: turso db show [name]

For local SQLite:
  - Check file permissions: ls -la [file]
```

---

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | Database connection URL | `libsql://db-name.turso.io` |
| `DATABASE_AUTH_TOKEN` | Turso auth token | `eyJ...` |
| `TURSO_DB_NAME` | Override database name | `herbarium-dyeworks-db` |

---

## Best Practices

1. **Always backup before migrations** - Run `/db backup pre-[migration-name]`
2. **Use dry-run first** - Preview changes before applying
3. **Keep golden backup updated** - After major imports, update golden
4. **Log all migrations** - Check `migrations.log` for history
5. **Test on copy first** - Use `/db compare` before production changes

Begin by parsing the arguments.
