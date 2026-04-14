# Security Audit Skill

## Overview
Automated vulnerability scanning, dependency checking, and security best practices validation.

## Usage
```
/security-audit                    # Full security scan
/security-audit dependencies       # Check vulnerable packages
/security-audit secrets            # Scan for exposed secrets
/security-audit config             # Check insecure configurations
/security-audit report             # Generate security report
/security-audit fix [package]      # Auto-fix vulnerable packages
```

## Scan Categories
- **Dependencies**: Known CVEs, outdated packages
- **Secrets**: API keys, tokens, passwords in code
- **Config**: Insecure defaults, exposed ports
- **Permissions**: File permissions, sudo access
- **Network**: Open ports, SSL/TLS status

## Configuration
Edit `~/.qwen/skills/security-audit/config.json`
