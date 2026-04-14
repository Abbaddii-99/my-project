# Abbaddii Workspace

**Type:** Multi-Project Container
**Mode:** Abbaddii Skills Mode (Active)

---

## Structure

```
/workspace/
├── projects/        # Independent project directories
│   ├── project-1/
│   ├── project-2/
│   └── ...
├── shared/          # Shared utilities (if needed)
├── config/          # Global settings
│   ├── skills/      # Abbaddii Skills
│   ├── scripts/     # Automation scripts
│   └── .opencode/  # Opencode config
└── logs/            # Workspace logs
```

---

## Rules

1. Each project lives in its own directory under `/projects/`
2. NO mixing of files or logic between projects
3. Global skills apply to all projects (via config)
4. New projects → create in `/workspace/projects/[name]/`
5. Clean isolation between all projects

---

## Global Skills (Abbaddii Skills Mode)

Skills are installed globally and available to all projects:
- Deploy, Monitor, Test Runner, Security Audit, Doc Gen, Notifications
- Unified CLI: `skills status`, `skills pre-deploy`, etc.

---

## GitHub Integration

- Owner: Abbaddii-99
- Token: Configured
- Auto-sync: Active (60s interval)

---

*Workspace initialized: 2026-04-14*
