# Abbaddii Skills Mode - Reference Guide

## Mode Status
**ACTIVATED** - All skills are native to this session.

---

## Skill Commands

### Deploy
```bash
/deploy                    # Deploy to local
/deploy staging           # Deploy to staging
/deploy production        # Deploy to production (requires confirmation)
/deploy --dry-run         # Preview deployment steps
/deploy --rollback        # Rollback to previous deployment
/deploy --status          # Check deployment status
```

**Capabilities:**
- Pre-flight checks (Node.js, npm, backend script)
- Automatic backup before deployment
- Health check verification
- Rollback support
- Multi-environment support (local, staging, production)

---

### Monitor
```bash
/monitor                   # Full system health check
/monitor services         # Check running services
/monitor resources        # CPU, memory, disk usage
/monitor logs             # Recent error logs
/monitor report           # Generate health report
```

**Capabilities:**
- Service health monitoring (ports 80, 443, 3000, 5432, 6379, 27017, 8080)
- CPU usage tracking
- Memory usage tracking
- Disk space monitoring
- Battery monitoring (Termux)
- Process monitoring (top consumers)
- Zombie process detection
- Continuous watch mode

**Thresholds:**
- CPU Warning: 80%, Critical: 95%
- Memory Warning: 75%, Critical: 90%
- Disk Warning: 80%, Critical: 95%

---

### Test Runner
```bash
/test-runner               # Auto-detect and run tests
/test-runner unit          # Run unit tests only
/test-runner integration   # Run integration tests only
/test-runner coverage      # Run tests with coverage report
/test-runner watch         # Watch mode for TDD
```

**Supported Frameworks:**
- Jest, Mocha, Vitest (Node.js)
- Pytest, Unittest (Python)
- Go test (Golang)

**Capabilities:**
- Auto-detect test framework
- Parallel test execution
- Coverage reporting (threshold: 80%)
- Test result caching
- Watch mode for TDD

---

### Security Audit
```bash
/security-audit            # Full security scan
/security-audit dependencies  # Check vulnerable packages
/security-audit secrets   # Scan for exposed secrets
/security-audit config     # Check insecure configurations
/security-audit report    # Generate security report
```

**Scans:**
- **Dependencies**: CVE checking (npm audit, safety, go list)
- **Secrets**: API keys, tokens, private keys, GitHub tokens
- **Config**: File permissions (600/400), debug mode, .gitignore

**Secret Patterns Detected:**
- `AKIA[0-9A-Z]{16}` (AWS keys)
- `sk-[a-zA-Z0-9]{20,}` (OpenAI keys)
- `ghp_[a-zA-Z0-9]{36}` (GitHub tokens)
- `-----BEGIN.*PRIVATE KEY-----` (Private keys)

---

### Doc Generator
```bash
/doc-gen                   # Generate full project docs
/doc-gen readme           # Generate/update README.md
/doc-gen functions        # Document all functions
/doc-gen architecture     # Document system architecture
/doc-gen api              # Document API endpoints
```

**Capabilities:**
- README generation with backup
- Function signature extraction
- JSDoc/Python docstring parsing
- Route detection
- Dependency documentation
- Auto-update existing docs

---

### Notifications
```bash
skills notify setup       # Configure notifications
skills notify test         # Test notification system
skills notify logs         # View notification history
```

**Channels:**
- Telegram (bot token + chat ID)
- Email
- Local logs

**Event Triggers:**
- deploy_success, deploy_failure
- security_alert, critical_resource
- daily_report

---

### Unified CLI (Master)
```bash
skills status             # Show all skills status
skills pre-deploy         # Tests → Security → Docs → Deploy
skills ci                 # CI pipeline
skills daily-report       # Daily status summary
skills watch [interval]   # Continuous monitoring
```

---

## Pipelines

### Pre-Deploy Pipeline
```
1. Run tests (abort if fails)
2. Run security audit
3. Update documentation
4. Deploy application
```

### CI Pipeline
```
1. Run tests with coverage
2. Run linting
3. Security scan
4. Build
```

---

## Auto-Sync
- Monitors project for changes
- Auto-commits with timestamp
- Auto-pushes to GitHub
- Check interval: 60 seconds

---

## GitHub Integration
- Owner: Abbaddii-99
- Repo: my-project
- Token: Cached for push operations

---

*Mode activated: Abbaddii Skills Mode (Active)*
