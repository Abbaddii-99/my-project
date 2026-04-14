# Abbaddii Skills Mode - System Behavior Rules

**STATUS: ACTIVE**
**MODE: Abbaddii Skills Mode**

## Activated Skills
All skills from `Abbaddii-99/Qwen-Skills-Settings` are now NATIVE capabilities.

---

## Core Principle
When Abbaddii Skills Mode is active, these skills override default behavior patterns and take priority in all relevant operations.

---

## Skill Execution Rules

### 1. DEPLOY SKILL
**Trigger:** Any deployment request
**Rules:**
- ALWAYS run pre-flight checks first
- Create backup before deployment (unless --dry-run)
- Verify health endpoint after deployment
- Support rollback via --rollback flag
- Pre-flight: Check Node.js, npm, backend script

### 2. MONITOR SKILL
**Trigger:** System health, resource checks, status reports
**Rules:**
- Report CPU, Memory, Disk usage
- Alert on threshold violations (configurable)
- Detect zombie processes
- Check service health (ports)
- Support continuous watch mode

### 3. TEST RUNNER
**Trigger:** Test execution, coverage reports
**Rules:**
- Auto-detect framework (Jest/Mocha/Vitest/Pytest/Go)
- Run tests before production deployments
- Generate coverage reports
- Support watch mode for TDD

### 4. SECURITY AUDIT
**Trigger:** Before commits, deployments, code changes
**Rules:**
- Scan for exposed secrets before git operations
- Check .env in .gitignore
- Validate file permissions (600/400 for sensitive files)
- Run dependency vulnerability checks (npm audit)
- Block commits with detected secrets

### 5. DOC GENERATOR
**Trigger:** Documentation requests, feature completion
**Rules:**
- Generate/update README.md
- Document functions and APIs
- Backup existing docs before overwrite
- Support multiple formats (markdown primary)

### 6. NOTIFICATIONS
**Trigger:** Deployment completion, alerts, critical issues
**Rules:**
- Send Telegram/email alerts on events
- Always log to local file
- Support priority levels (low/normal/high/critical)

### 7. AUTO-SYNC
**Trigger:** File changes in project
**Rules:**
- Watch for changes in skills/configs
- Auto-commit with descriptive messages
- Auto-push to GitHub
- Log all sync activity

---

## Pipeline Behaviors

### Pre-Deploy Pipeline
1. Run tests → FAIL → Abort
2. Security audit → WARN → Continue
3. Update docs → WARN → Continue  
4. Deploy → FAIL → Alert + Abort

### CI Pipeline
1. Tests with coverage
2. Linting (npm run lint)
3. Security scan
4. Build (npm run build)

---

## GitHub Integration
- Remote: https://github.com/Abbaddii-99/my-project
- Auth: Token-based (cached)
- Branch: main
- Auto-push on sync

---

## File Locations
- Skills: `skills/*/`
- Scripts: `scripts/`
- Logs: `skills/*/logs/`
- Config: `skills/*/config.json`
- Auto-sync: `scripts/auto-sync.sh`

---

*These rules take PRIORITY over default behaviors when relevant operations are detected.*
