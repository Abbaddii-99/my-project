#!/data/data/com.termux/files/usr/bin/bash

# Security Audit Skill - Main Script
# Usage: ./security-audit.sh [dependencies|secrets|config|report]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$SCRIPT_DIR/reports/audit_${TIMESTAMP}.md"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

MODE="${1:-full}"
VULN_COUNT=0
WARN_COUNT=0

echo -e "\n${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║        🔒 SECURITY AUDIT               ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo -e "Timestamp: ${YELLOW}${TIMESTAMP}${NC}\n"

# Check dependencies
check_dependencies() {
    echo -e "${BLUE}📦 Dependency Vulnerability Check:${NC}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [ -f "package.json" ]; then
        echo -e "  Scanning npm packages..."
        VULNS=$(npm audit --json 2>/dev/null | grep -o '"vulnerabilities":[^}]*' | head -1 || echo "")
        
        if [ -n "$VULNS" ]; then
            VULN_COUNT=$(npm audit 2>/dev/null | grep -c "high\|critical" || echo "0")
            echo -e "  ${RED}⚠ Found ${VULN_COUNT} high/critical vulnerabilities${NC}"
            echo -e "  Run: ${CYAN}npm audit fix${NC}"
        else
            echo -e "  ${GREEN}✅ No known vulnerabilities${NC}"
        fi
    fi
    
    if command -v pip &>/dev/null && [ -f "requirements.txt" ]; then
        echo -e "  Scanning Python packages..."
        if command -v safety &>/dev/null; then
            safety check 2>/dev/null || VULN_COUNT=$((VULN_COUNT+1))
        else
            echo -e "  ${YELLOW}⚠ Install 'safety' for Python vulnerability scanning${NC}"
        fi
    fi
    
    if command -v go &>/dev/null; then
        echo -e "  Scanning Go modules..."
        go list -m -u 2>/dev/null | grep -q "\\[" && echo -e "  ${YELLOW}⚠ Updates available${NC}" || echo -e "  ${GREEN}✅ Go modules up to date${NC}"
    fi
    echo ""
}

# Check for secrets
check_secrets() {
    echo -e "${BLUE}🔑 Secret Exposure Scan:${NC}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    PATTERNS=(
        "API_KEY|api_secret|private_key|password|token"
        "AKIA[0-9A-Z]{16}"
        "sk-[a-zA-Z0-9]{20,}"
        "-----BEGIN (RSA|DSA|EC|OPENSSH|PGP) PRIVATE KEY-----"
        "ghp_[a-zA-Z0-9]{36}"
    )
    
    FOUND=0
    for pattern in "${PATTERNS[@]}"; do
        RESULTS=$(grep -r --include="*.js" --include="*.py" --include="*.ts" --include="*.env" -l "$pattern" . 2>/dev/null | head -5 || true)
        if [ -n "$RESULTS" ]; then
            echo -e "  ${RED}⚠ Potential secrets in:${NC}"
            while IFS= read -r file; do
                echo -e "    - $file"
                FOUND=$((FOUND+1))
            done <<< "$RESULTS"
        fi
    done
    
    if [ $FOUND -eq 0 ]; then
        echo -e "  ${GREEN}✅ No obvious secrets detected${NC}"
    else
        echo -e "  ${RED}⚠ Review ${FOUND} files for exposed secrets${NC}"
        WARN_COUNT=$((WARN_COUNT+FOUND))
    fi
    
    # Check .env files
    if [ -f ".env" ]; then
        echo -e "  ${YELLOW}⚠ .env file found - ensure it's in .gitignore${NC}"
    fi
    echo ""
}

# Check configuration
check_config() {
    echo -e "${BLUE}⚙️  Configuration Security:${NC}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check file permissions
    SENSITIVE_FILES=(
        "id_rsa:id_dsa:id_ecdsa:id_ed25519"
        ".env:.env.local"
        "config.json:config.yaml"
    )
    
    IFS=':' read -ra FILES <<< "$SENSITIVE_FILES"
    for files in "${FILES[@]}"; do
        IFS=':' read -ra FILE_ARRAY <<< "$files"
        for file in "${FILE_ARRAY[@]}"; do
            if [ -f "$file" ]; then
                PERMS=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%Lp" "$file" 2>/dev/null)
                if [ "$PERMS" != "600" ] && [ "$PERMS" != "400" ]; then
                    echo -e "  ${YELLOW}⚠ $file permissions: $PERMS (should be 600 or 400)${NC}"
                    WARN_COUNT=$((WARN_COUNT+1))
                fi
            fi
        done
    done
    
    # Check for debug mode in production configs
    if grep -r "DEBUG.*=.*[Tt]rue" . --include="*.js" --include="*.ts" --include="*.py" 2>/dev/null | head -1 &>/dev/null; then
        echo -e "  ${YELLOW}⚠ Debug mode may be enabled in production files${NC}"
        WARN_COUNT=$((WARN_COUNT+1))
    else
        echo -e "  ${GREEN}✅ Debug mode not detected${NC}"
    fi
    
    # Check gitignore
    if [ -f ".gitignore" ]; then
        if grep -q "\.env" .gitignore 2>/dev/null; then
            echo -e "  ${GREEN}✅ .env in .gitignore${NC}"
        else
            echo -e "  ${RED}⚠ .env NOT in .gitignore${NC}"
            WARN_COUNT=$((WARN_COUNT+1))
        fi
    fi
    echo ""
}

# Generate report
generate_report() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📊 Audit Summary:${NC}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [ $VULN_COUNT -eq 0 ] && [ $WARN_COUNT -eq 0 ]; then
        echo -e "${GREEN}✅ No critical issues found${NC}"
    else
        echo -e "${RED}❌ Vulnerabilities: ${VULN_COUNT}${NC}"
        echo -e "${YELLOW}⚠ Warnings: ${WARN_COUNT}${NC}"
    fi
    
    # Save report
    cat > "$REPORT_FILE" << EOF
# Security Audit Report
**Date:** ${TIMESTAMP}
**Vulnerabilities:** ${VULN_COUNT}
**Warnings:** ${WARN_COUNT}
EOF
    
    echo -e "\n  Report saved: ${REPORT_FILE}"
    echo ""
}

# Execute based on mode
case "$MODE" in
    dependencies)
        check_dependencies
        ;;
    secrets)
        check_secrets
        ;;
    config)
        check_config
        ;;
    report|full)
        check_dependencies
        check_secrets
        check_config
        generate_report
        ;;
    *)
        echo -e "${YELLOW}Usage: $0 [dependencies|secrets|config|report|full]${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}✅ Security audit complete${NC}\n"
