# Protocols - Example Project

## Git Conventions

### Branch Naming

```
feat/[track-id]-[short-description]
fix/[track-id]-[short-description]
quick/[date]-[description]
```

Examples:
- `feat/auth-user-login`
- `fix/cart-quantity-bug`
- `quick/2025-01-03-typo`

### Commit Messages

Format: `[type]: [description]`

Types:
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code improvement
- `docs`: Documentation
- `test`: Tests
- `chore`: Maintenance

Examples:
- `feat: add user authentication`
- `fix: cart quantity not updating`
- `docs: update README installation`

### PR Template

```markdown
## Summary
[1-3 bullet points]

## Test Plan
- [ ] Manual testing completed
- [ ] All existing tests pass
- [ ] New tests added (if applicable)

## Screenshots
[If UI changes]
```

## Testing Standards

### Before Commit

1. Run `npm run build` (type checking)
2. Run `npm test` (if tests exist)
3. Run `/test all` (visual tests, if applicable)

### Test Coverage

- Critical paths: Required
- Edge cases: Encouraged
- UI components: Visual tests

## Code Style

- TypeScript: Strict mode
- Formatting: Prettier
- Linting: ESLint
- Imports: Absolute paths (`@/`)

## Review Process

1. Self-review diff before commit
2. Use `/senior-review` for architecture decisions
3. PR review for main branch merges
