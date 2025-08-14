---
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git commit:*)
argument-hint: [message]
description: Create a git commit with conventional commit format and emoji
---

# Claude Command: Commit

Create well-formatted commits with conventional commit messages and emoji.

## What This Command Does

1. Performs `git diff --cached` to understand what changes are being committed
2. Creates a commit message using emoji conventional commit format
3. Always performs the commit (no checking for staged files)
4. If a message argument is provided, uses it as guidance for the commit message

## Commit Message Guidelines

### Format

```text
<emoji> <type>: <description>

[optional body]
[optional footer]
```

### Commit Types and Emojis

**Core Types:**

- ✨ `feat`: A new feature
- 🐛 `fix`: A bug fix  
- 📝 `docs`: Documentation changes
- 💄 `style`: Code style changes (formatting, etc)
- ♻️ `refactor`: Code changes that neither fix bugs nor add features
- ⚡️ `perf`: Performance improvements
- ✅ `test`: Adding or fixing tests
- 🔧 `chore`: Changes to the build process, tools, etc

### Message Best Practices

- **Present tense, imperative mood**: Write as commands (e.g., "add feature" not "added feature")
- **Concise first line**: Keep under 72 characters
- **Lowercase**: Start with lowercase letter after emoji and type
- **No period**: Don't end the subject line with a period

### Extended Emoji Reference

**Features & Improvements:**

- 💥 `feat`: Introduce breaking changes
- 🏷️ `feat`: Add or update types
- 👔 `feat`: Add or update business logic
- 🚸 `feat`: Improve user experience/usability
- ♿️ `feat`: Improve accessibility
- 🌐 `feat`: Internationalization and localization
- 📱 `feat`: Work on responsive design
- 📈 `feat`: Add or update analytics or tracking
- 🔍️ `feat`: Improve SEO
- 🦺 `feat`: Add or update validation
- 🚩 `feat`: Add, update, or remove feature flags
- 🧵 `feat`: Multithreading or concurrency
- 🔊 `feat`: Add or update logs
- 💬 `feat`: Add or update text and literals
- ✈️ `feat`: Improve offline support
- 🥚 `feat`: Add or update an easter egg

**Bug Fixes & Hotfixes:**

- 🚑️ `fix`: Critical hotfix
- 🩹 `fix`: Simple fix for non-critical issue
- 🚨 `fix`: Fix compiler/linter warnings
- 🔒️ `fix`: Fix security issues
- 💚 `fix`: Fix CI build
- 🥅 `fix`: Catch errors
- 👽️ `fix`: Update code due to external API changes
- ✏️ `fix`: Fix typos
- 🔇 `fix`: Remove logs
- 🔥 `fix`: Remove code or files

**Code Quality & Refactoring:**

- 🎨 `style`: Improve structure/format of code
- 🚚 `refactor`: Move or rename resources
- 🏗️ `refactor`: Make architectural changes
- ⚰️ `refactor`: Remove dead code

**Development & Operations:**

- 🎉 `chore`: Begin a project
- 🔖 `chore`: Release/Version tags
- 📦️ `chore`: Update compiled files or packages
- ➕ `chore`: Add a dependency
- ➖ `chore`: Remove a dependency
- 📌 `chore`: Pin dependencies to specific versions
- 🔀 `chore`: Merge branches
- 🙈 `chore`: Add or update .gitignore file
- 👥 `chore`: Add or update contributors
- 📄 `chore`: Add or update license
- 🌱 `chore`: Add or update seed files
- 🧑‍💻 `chore`: Improve developer experience

**CI/CD & Testing:**

- 🚀 `ci`: CI/CD improvements
- 👷 `ci`: Add or update CI build system
- 🧪 `test`: Add a failing test
- 🤡 `test`: Mock things
- 📸 `test`: Add or update snapshots

**Documentation:**

- 💡 `docs`: Add or update comments in source code

**UI/UX:**

- 💫 `ui`: Add or update animations and transitions
- 🍱 `assets`: Add or update assets

**Database:**

- 🗃️ `db`: Perform database related changes

**Other:**

- 🚧 `wip`: Work in progress
- ⏪️ `revert`: Revert changes
- ⚗️ `experiment`: Perform experiments

## Examples

### Good Commit Messages

**Simple commits:**

- ✨ feat: add user authentication system
- 🐛 fix: resolve memory leak in rendering process
- 📝 docs: update API documentation with new endpoints
- ♻️ refactor: simplify error handling logic in parser
- ⚡️ perf: optimize database query performance
- ✅ test: add unit tests for user service

**More specific commits:**

- 🚑️ fix: patch critical security vulnerability in auth flow
- 🩹 fix: address minor styling inconsistency in header
- 🎨 style: reorganize component structure for better readability
- 🔒️ fix: strengthen authentication password requirements
- 👔 feat: implement business logic for transaction validation
- 🦺 feat: add input validation for user registration form
- 💚 fix: resolve failing CI pipeline tests
- 📈 feat: implement analytics tracking for user engagement
- ♿️ feat: improve form accessibility for screen readers
- 🧑‍💻 chore: improve developer tooling setup process
- 🔥 fix: remove deprecated legacy code
- 🏗️ refactor: restructure API layer for better separation of concerns

### Commit with body example

```text
✨ feat: add user authentication system

- Implement JWT-based authentication
- Add login and logout endpoints
- Create middleware for protected routes
- Include refresh token mechanism
```
