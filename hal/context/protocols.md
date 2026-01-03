# Protocols - HAL Ecosystem

## Git Conventions

### Branch Naming

```
feat/[track-id]-[short-description]
fix/[track-id]-[short-description]
docs/[description]
```

Examples:
- `feat/quick-mode-archive`
- `fix/parse-plan-edge-case`
- `docs/installation-guide`

### Commit Messages

Format: `[type]: [description]`

Types:
- `feat`: New feature or command
- `fix`: Bug fix
- `refactor`: Code improvement
- `docs`: Documentation
- `chore`: Maintenance

Examples:
- `feat: add Quick mode to tars command`
- `fix: parse-plan.sh handles empty tasks`
- `docs: update README with installation steps`

## File Conventions

### Command Files (`commands/*.md`)
- Start with `# Command Name`
- Include `## Auto-Start / Menu` for menu-based commands
- Use `## Mode N: Name` for mode sections

### Skill Files (`skills/*/SKILL.md`)
- Must be named `SKILL.md` exactly
- Include frontmatter with name/description
- Define triggers for auto-invocation

### Script Files (`scripts/*.sh`)
- Include usage comments at top
- Use `set -e` for error handling
- Accept project path as first argument

## Testing Standards

### Before Commit

1. Test commands manually in Claude Code
2. Verify scripts work: `./scripts/script.sh /test/path`
3. Check examples still valid

### Documentation

- Keep README.md updated
- Examples should be runnable
- Include troubleshooting section

## Review Process

1. Self-review command logic before commit
2. Test in fresh Claude Code session
3. Verify examples work after changes
