# Git Workflow Patterns

**Purpose**: Define Git practices for SSD projects
**Version**: 1.0.0

---

## 🎯 Git Principles

| Principle | Description |
|-----------|-------------|
| **Atomic Commits** | One logical change per commit |
| **Clear Messages** | Descriptive, imperative mood |
| **Protected Main** | Main branch cannot be pushed to directly |
| **Small PRs** | Review quickly, merge often |

---

## 📝 Commit Message Format

### Conventional Commits
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types
| Type | Description |
|------|-------------|
| feat | New feature |
| fix | Bug fix |
| docs | Documentation |
| style | Formatting |
| refactor | Code restructure |
| test | Adding tests |
| chore | Maintenance |

### Examples
```
feat(auth): add password reset flow
fix(api): handle null response from user endpoint
docs(readme): update installation instructions
refactor(users): extract validation into separate module
```

---

## 🔀 Branching Strategy

```
main (protected)
    │
    ├── feature/user-authentication
    │       │
    │       ├── feature/user-authentication/login
    │       └── feature/user-authentication/tokens
    │
    ├── fix/payment-validation
    └── refactor/database-layer
```

### Branch Naming
```
✅ GOOD: feature/add-user-authentication
✅ GOOD: fix/login-redirect-issue
✅ GOOD: docs/update-api-reference
❌ BAD: my changes
❌ BAD: fixstuff
```

---

## 🔒 Security in Git

### Never Commit
```gitignore
# Secrets
.env
*.pem
*.key

# Dependencies (use package manager)
node_modules/
vendor/

# IDE
.idea/
.vscode/

# OS
.DS_Store
Thumbs.db

# Build output
dist/
build/
```

### Sensitive Data Removal
```bash
# Remove from history (if committed)
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch secrets.json' \
  --prune-empty --tag-name-filter cat -- --all

# Or use BFG Repo-Cleaner
bfg --delete-files secrets.json
```

---

## ✅ Pull Request Checklist

- [ ] Tests pass locally
- [ ] Code formatted (lint check)
- [ ] No merge conflicts
- [ ] Documentation updated
- [ ] Related issue linked
- [ ] At least one approval

---

## 🔄 Release Process

```bash
# Version bump
npm version patch  # 1.0.0 → 1.0.1
npm version minor  # 1.0.0 → 1.1.0
npm version major  # 1.0.0 → 2.0.0

# Tag
git tag -a v1.0.0 -m "Release v1.0.0"

# Push with tags
git push && git push --tags
```

---

*Git patterns v1.0.0 - Updated 2026-04-17*