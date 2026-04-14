# 🛠️ Unified Skills System

## Quick Start

```bash
# Show all commands
skills --help

# Check system status
skills status

# Run pre-deployment pipeline
skills pre-deploy

# Start continuous monitoring
skills watch 300

# Generate documentation
skills docs

# Run security audit
skills security
```

---

## 📦 Available Commands

### Individual Skills
| Command | Description |
|---------|-------------|
| `skills deploy` | Deploy application |
| `skills monitor [mode]` | System health check |
| `skills test [options]` | Run test suite |
| `skills security [mode]` | Security audit |
| `skills docs [mode]` | Generate documentation |

### Pipelines
| Command | Description |
|---------|-------------|
| `skills pre-deploy` | Tests → Security → Docs → Deploy |
| `skills ci` | Continuous integration pipeline |
| `skills daily-report` | Daily status summary |

### Monitoring
| Command | Description |
|---------|-------------|
| `skills watch [seconds]` | Continuous monitoring loop |
| `skills status` | Overview of all skills |

### Notifications
| Command | Description |
|---------|-------------|
| `skills notify setup` | Configure notifications |
| `skills notify test` | Test notification system |
| `skills notify logs` | View notification history |

---

## 🔔 Notification Setup

### Telegram
1. Message [@BotFather](https://t.me/BotFather) on Telegram
2. Create new bot: `/newbot`
3. Copy bot token
4. Message [@userinfobot](https://t.me/userinfobot) to get chat ID
5. Edit `~/.qwen/skills/notifications/config.json`:
   ```json
   {
     "telegram_enabled": true,
     "bot_token": "YOUR_TOKEN",
     "chat_id": "YOUR_CHAT_ID"
   }
   ```

### Email
```json
{
  "email_enabled": true,
  "email_to": "your@email.com"
}
```

---

## 🔄 Continuous Monitoring

### Start monitoring (foreground)
```bash
skills watch 300  # Check every 5 minutes
```

### Start monitoring (background)
```bash
~/.qwen/skills/monitor/monitor-loop.sh 300 &
```

### Stop monitoring
```bash
kill $(cat ~/.qwen/skills/monitor/monitor-loop.pid)
```

---

## 📁 Directory Structure

```
~/.qwen/skills/
├── README.md                 ← You are here
├── unified-cli/
│   └── skills.sh             ← Main CLI
├── deploy/                   ← Deployment automation
├── monitor/                  ← System monitoring
│   ├── monitor.sh
│   └── monitor-loop.sh       ← Background loop
├── test-runner/              ← Test execution
├── security-audit/           ← Security scanning
├── doc-gen/                  ← Documentation generation
└── notifications/            ← Notification service
    ├── notify.sh
    └── config.json
```

---

## 🚀 Common Workflows

### Pre-Deployment Pipeline
```bash
skills pre-deploy
# Runs: Tests → Security Audit → Docs → Deploy
```

### Daily Check
```bash
skills daily-report
# Shows: System health, services, deployments, security
```

### Development Cycle
```bash
skills test              # Run tests
skills security secrets  # Check for exposed secrets
skills docs functions    # Update function docs
skills deploy            # Deploy
```

### Emergency Response
```bash
skills monitor services  # Check what's running
skills security config   # Check for issues
skills notify test       # Verify alerts work
```

---

## 🔧 Configuration

All skills can be configured via their `config.json` files:

| Skill | Config File | Key Settings |
|-------|-------------|--------------|
| deploy | `~/.qwen/skills/deploy/config.json` | Environments, backup settings |
| monitor | `~/.qwen/skills/monitor/config.json` | Thresholds, check intervals |
| test-runner | `~/.qwen/skills/test-runner/config.json` | Coverage thresholds |
| security-audit | `~/.qwen/skills/security-audit/config.json` | Scan patterns, severity |
| notifications | `~/.qwen/skills/notifications/config.json` | Channels, events |

---

*Created: 2026-04-13 | Version: 1.0.0*
