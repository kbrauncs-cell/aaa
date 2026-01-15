# CLAUDE.md - AI Assistant Guide

**Last Updated:** 2026-01-15
**Repository:** aaa

This document provides comprehensive guidance for AI assistants (like Claude) working on this repository. It covers codebase structure, development workflows, conventions, and best practices.

---

## Table of Contents

1. [Repository Overview](#repository-overview)
2. [Codebase Structure](#codebase-structure)
3. [Development Workflows](#development-workflows)
4. [Git Conventions](#git-conventions)
5. [Code Style & Conventions](#code-style--conventions)
6. [Testing Guidelines](#testing-guidelines)
7. [Key Files & Locations](#key-files--locations)
8. [Common Tasks](#common-tasks)
9. [Important Notes for AI Assistants](#important-notes-for-ai-assistants)

---

## Repository Overview

### About
This is the `aaa` repository - currently in its initial state.

### Technology Stack
- **Version Control:** Git
- **Platform:** Linux (4.4.0)
- **Status:** Early development phase

### Current State
- Repository initialized with basic README
- Main development branch: `claude/claude-md-mkf8k6zxvn2xu311-U0Oif`
- Clean working directory

---

## Codebase Structure

```
/home/user/aaa/
├── .git/              # Git version control
├── README.md          # Project documentation
└── CLAUDE.md          # This file - AI assistant guide
```

### Directory Layout (Template for Future Growth)

When the project grows, organize code as follows:

```
/home/user/aaa/
├── src/               # Source code
│   ├── components/    # Reusable components
│   ├── services/      # Business logic
│   ├── utils/         # Utility functions
│   └── index.*        # Main entry point
├── tests/             # Test files
├── docs/              # Additional documentation
├── config/            # Configuration files
├── scripts/           # Build/deployment scripts
└── dist/              # Build output (gitignored)
```

---

## Development Workflows

### Branch Strategy

**Feature Branch Pattern:**
- All development happens on feature branches
- Branch naming: `claude/claude-md-<session-id>-<unique-id>`
- Current branch: `claude/claude-md-mkf8k6zxvn2xu311-U0Oif`

**Branch Requirements:**
- Always develop on the designated feature branch
- NEVER push to branches without `claude/` prefix
- NEVER push to main/master without explicit permission

### Standard Development Flow

1. **Start Work**
   ```bash
   # Verify current branch
   git branch --show-current

   # Pull latest changes
   git fetch origin <branch-name>
   git pull origin <branch-name>
   ```

2. **Make Changes**
   - Read existing code before modifying
   - Follow established patterns
   - Keep changes focused and minimal
   - Avoid over-engineering

3. **Commit Changes**
   ```bash
   # Check status
   git status

   # Review changes
   git diff

   # Stage files
   git add <files>

   # Commit with descriptive message
   git commit -m "$(cat <<'EOF'
   Brief summary of changes

   - Detail 1
   - Detail 2
   EOF
   )"
   ```

4. **Push Changes**
   ```bash
   # Always use -u flag for tracking
   git push -u origin <branch-name>

   # Retry logic: If network fails, retry up to 4 times
   # with exponential backoff (2s, 4s, 8s, 16s)
   ```

---

## Git Conventions

### Commit Messages

**Format:**
```
<type>: <short summary>

<optional detailed description>
- Specific change 1
- Specific change 2
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Test additions/changes
- `chore`: Build/tooling changes
- `style`: Code style changes

**Best Practices:**
- Keep first line under 72 characters
- Focus on "why" rather than "what"
- Use imperative mood ("add" not "added")
- Reference issues/PRs when relevant

### Push/Pull Practices

**For git push:**
- Always use `git push -u origin <branch-name>`
- CRITICAL: Branch must start with `claude/` and end with matching session ID
- Push will fail with 403 if branch naming is incorrect
- Retry on network errors: up to 4 times with exponential backoff (2s, 4s, 8s, 16s)

**For git fetch/pull:**
- Prefer fetching specific branches: `git fetch origin <branch-name>`
- Retry on network failures: up to 4 times with exponential backoff
- For pulls: `git pull origin <branch-name>`

### Protected Operations

**NEVER:**
- Update git config without permission
- Run destructive commands (force push, hard reset) without explicit request
- Skip hooks (--no-verify, --no-gpg-sign) without permission
- Force push to main/master branches
- Amend commits that have been pushed (unless explicitly requested)
- Commit changes unless explicitly asked

---

## Code Style & Conventions

### General Principles

1. **Simplicity First**
   - Only make changes that are directly requested or clearly necessary
   - Avoid over-engineering and premature abstractions
   - Don't add features beyond what was asked

2. **Code Quality**
   - Write clean, self-documenting code
   - Add comments only where logic isn't self-evident
   - Avoid backwards-compatibility hacks
   - Delete unused code completely (no `_vars` or `// removed` comments)

3. **Error Handling**
   - Only validate at system boundaries (user input, external APIs)
   - Trust internal code and framework guarantees
   - Avoid handling scenarios that can't happen

4. **Security**
   - Prevent command injection, XSS, SQL injection
   - Follow OWASP top 10 guidelines
   - Fix security issues immediately when discovered

### Naming Conventions

**General Rules:**
- Use descriptive, meaningful names
- Follow language-specific conventions
- Be consistent with existing codebase

**To Be Defined:**
- Variable naming style
- Function naming style
- File naming conventions
- Class naming patterns

---

## Testing Guidelines

### Test Organization

```
tests/
├── unit/          # Unit tests
├── integration/   # Integration tests
└── e2e/          # End-to-end tests
```

### Testing Principles

1. **Coverage**
   - Write tests for new features
   - Add tests when fixing bugs
   - Maintain existing test coverage

2. **Test Quality**
   - Tests should be readable and maintainable
   - Use descriptive test names
   - Test behavior, not implementation

3. **Running Tests**
   ```bash
   # To be defined based on project setup
   # Examples: npm test, pytest, cargo test, etc.
   ```

---

## Key Files & Locations

### Documentation
- `README.md` - Project overview and setup instructions
- `CLAUDE.md` - This file, AI assistant guide

### Configuration
*(To be added as project grows)*
- Package manager config (package.json, Cargo.toml, etc.)
- Build configuration
- Environment files (.env templates)

### Entry Points
*(To be added as project grows)*
- Main application entry point
- Test entry points

---

## Common Tasks

### Adding New Features

1. **Before Starting:**
   - Read relevant existing code
   - Understand current patterns
   - Use TodoWrite tool to plan tasks

2. **Implementation:**
   - Follow existing code style
   - Keep changes minimal and focused
   - Write tests for new functionality

3. **After Implementation:**
   - Run tests
   - Review changes
   - Commit with descriptive message

### Debugging

1. **Investigate:**
   - Use Task tool with Explore agent for codebase exploration
   - Read error messages carefully
   - Check recent changes

2. **Fix:**
   - Address root cause, not symptoms
   - Add tests to prevent regression
   - Document if issue was non-obvious

### Code Review

1. **Self-Review:**
   - Check git diff before committing
   - Verify no unintended changes
   - Ensure tests pass

2. **Creating Pull Requests:**
   - Analyze all commits in the branch
   - Write comprehensive PR description
   - Include test plan

---

## Important Notes for AI Assistants

### Tool Usage Priorities

1. **File Operations:**
   - Use `Read` tool for reading files (not `cat`)
   - Use `Edit` tool for editing files (not `sed/awk`)
   - Use `Write` tool for new files (not `echo >`)
   - Use `Glob` for finding files by pattern
   - Use `Grep` for searching file contents

2. **Exploration:**
   - Use Task tool with `Explore` agent for codebase exploration
   - Use Task tool for multi-step operations
   - Run independent operations in parallel

3. **Communication:**
   - Output text directly to user (not via `echo` or comments)
   - Use TodoWrite tool for task planning and tracking
   - Ask questions with AskUserQuestion tool when needed

### Best Practices

1. **Always Read Before Writing:**
   - Read existing files before modifying
   - Understand context before making changes
   - Never propose changes to unread code

2. **Task Management:**
   - Use TodoWrite tool frequently for complex tasks
   - Mark todos as completed immediately after finishing
   - Keep only ONE task in_progress at a time

3. **Error Handling:**
   - Fix errors immediately when discovered
   - Don't mark tasks complete if errors exist
   - Create new todos for blockers

4. **Code References:**
   - Use `file_path:line_number` format when referencing code
   - Example: "Error handling is in `src/services/process.ts:712`"

5. **Parallel Operations:**
   - Run independent tool calls in parallel
   - Use sequential calls only when there are dependencies
   - Never use placeholders for missing parameters

### Common Pitfalls to Avoid

❌ **Don't:**
- Create files unnecessarily (prefer editing existing files)
- Add features not requested
- Use git commands with `-i` flag (interactive mode not supported)
- Commit without explicit user request
- Use emojis unless user requests them
- Include time estimates in plans
- Guess at URLs or file paths

✅ **Do:**
- Keep solutions simple and focused
- Follow existing patterns
- Ask questions when uncertain
- Use specialized tools over bash commands
- Maintain clean working directory
- Write clear, descriptive commit messages

---

## Future Sections

As the project grows, add sections for:

- **Dependencies Management:** How to add/update dependencies
- **Build System:** Build commands and processes
- **Deployment:** Deployment procedures and environments
- **API Documentation:** API endpoints and usage
- **Database Schema:** Database structure and migrations
- **Environment Setup:** Local development setup
- **Troubleshooting:** Common issues and solutions
- **Performance:** Performance considerations and benchmarks
- **Security:** Security policies and practices

---

## Maintenance

This document should be updated:
- When new development patterns are established
- When technology stack changes
- When new conventions are adopted
- When directory structure evolves
- After major refactorings

**Update Procedure:**
1. Read current CLAUDE.md
2. Identify outdated sections
3. Update with current information
4. Verify accuracy with codebase exploration
5. Commit changes with descriptive message

---

*This document is a living guide. Keep it updated as the project evolves.*
