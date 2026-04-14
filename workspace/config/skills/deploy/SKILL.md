# Deploy Skill

## Overview
Automated deployment skill for backend services, web apps, and cloud infrastructure.

## Usage
```
/deploy                    # Deploy to detected environment
/deploy staging            # Deploy to staging
/deploy production         # Deploy to production (requires confirmation)
/deploy --dry-run          # Preview deployment steps
/deploy --rollback         # Rollback to previous deployment
/deploy status             # Check deployment status
```

## Workflow
1. **Environment Detection** - Detect target environment (local, staging, production)
2. **Pre-flight Checks** - Run tests, linting, and build validation
3. **Backup** - Create backup before deployment
4. **Deploy** - Execute deployment script
5. **Health Check** - Verify service is running post-deployment
6. **Report** - Generate deployment summary

## Configuration
Edit `~/.qwen/skills/deploy/config.json` for custom settings.

## Supported Environments
- Local (Termux)
- Remote SSH servers
- Docker containers
- Cloud providers (AWS, GCP, Vercel, Railway)
