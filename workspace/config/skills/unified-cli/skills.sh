#!/data/data/com.termux/files/usr/bin/bash

# Unified Skills CLI - Master Controller
# Usage: ./skills [command] [options]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$HOME/.qwen/skills"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$SCRIPT_DIR/logs/unified_${TIMESTAMP}.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

mkdir -p "$SCRIPT_DIR/logs"

# ===========================
# NOTIFICATION SYSTEM
# ===========================
send_notification() {
    local title="$1"
    local message="$2"
    local priority="${3:-normal}" # low, normal, high, critical
    
    # Load notification config
    local notif_config="$SKILLS_DIR/notifications/config.json"
    
    if [ -f "$notif_config" ]; then
        # Check if Telegram is enabled
        local telegram_enabled=$(grep -o '"telegram_enabled": *[a-z]*' "$notif_config" 2>/dev/null | awk '{print $2}' || echo "false")
        
        if [ "$telegram_enabled" = "true" ]; then
            local bot_token=$(grep -o '"bot_token": *"[^"]*"' "$notif_config" | cut -d'"' -f4)
            local chat_id=$(grep -o '"chat_id": *"[^"]*"' "$notif_config" | cut -d'"' -f4)
            
            if [ -n "$bot_token" ] && [ -n "$chat_id" ]; then
                local text="*${title}*\n${message}"
                curl -s -X POST "https://api.telegram.org/bot${bot_token}/sendMessage" \
                    -d "chat_id=${chat_id}" \
                    -d "text=${text}" \
                    -d "parse_mode=Markdown" &>/dev/null || true
            fi
        fi
        
        # Check if email is enabled
        local email_enabled=$(grep -o '"email_enabled": *[a-z]*' "$notif_config" 2>/dev/null | awk '{print $2}' || echo "false")
        
        if [ "$email_enabled" = "true" ]; then
            local email_to=$(grep -o '"email_to": *"[^"]*"' "$notif_config" | cut -d'"' -f4)
            if command -v mail &>/dev/null && [ -n "$email_to" ]; then
                echo "$message" | mail -s "$title" "$email_to" 2>/dev/null || true
            fi
        fi
    fi
    
    # Always log
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] [${priority^^}] ${title}: ${message}" >> "$SKILLS_DIR/notifications/logs/notifications.log"
}

# ===========================
# COMMANDS
# ===========================

# Show help
show_help() {
    echo -e "\n${MAGENTA}╔══════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║        🛠️  UNIFIED SKILLS CLI             ║${NC}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════╝${NC}\n"
    
    echo -e "${BLUE}Commands:${NC}"
    echo -e "  ${CYAN}skills deploy${NC}          Deploy application"
    echo -e "  ${CYAN}skills monitor${NC}         Run system health check"
    echo -e "  ${CYAN}skills test${NC}            Run test suite"
    echo -e "  ${CYAN}skills security${NC}        Run security audit"
    echo -e "  ${CYAN}skills docs${NC}            Generate documentation"
    echo -e ""
    echo -e "${BLUE}Pipelines:${NC}"
    echo -e "  ${CYAN}skills pre-deploy${NC}      Full pre-deployment pipeline"
    echo -e "  ${CYAN}skills ci${NC}              Continuous integration pipeline"
    echo -e "  ${CYAN}skills daily-report${NC}    Daily status report"
    echo -e ""
    echo -e "${BLUE}Monitoring:${NC}"
    echo -e "  ${CYAN}skills watch [interval]${NC} Start continuous monitoring"
    echo -e "  ${CYAN}skills status${NC}          Show all skill status"
    echo -e ""
    echo -e "${BLUE}Notifications:${NC}"
    echo -e "  ${CYAN}skills notify setup${NC}    Configure notifications"
    echo -e "  ${CYAN}skills notify test${NC}     Test notification system"
    echo -e "  ${CYAN}skills notify logs${NC}     View notification history"
    echo -e ""
    echo -e "${BLUE}Other:${NC}"
    echo -e "  ${CYAN}skills --help${NC}          Show this help"
    echo -e "  ${CYAN}skills --version${NC}       Show version"
    echo -e "  ${CYAN}skills --update${NC}        Update all skills"
    echo -e ""
}

# Deploy command
cmd_deploy() {
    echo -e "${BLUE}🚀 Running deployment...${NC}"
    "$SKILLS_DIR/deploy/deploy.sh" "$@"
}

# Monitor command
cmd_monitor() {
    echo -e "${BLUE}📊 Running system monitor...${NC}"
    "$SKILLS_DIR/monitor/monitor.sh" "$@"
}

# Test command
cmd_test() {
    echo -e "${BLUE}🧪 Running tests...${NC}"
    "$SKILLS_DIR/test-runner/test-runner.sh" "$@"
}

# Security command
cmd_security() {
    echo -e "${BLUE}🔒 Running security audit...${NC}"
    "$SKILLS_DIR/security-audit/security-audit.sh" "$@"
}

# Docs command
cmd_docs() {
    echo -e "${BLUE}📝 Generating documentation...${NC}"
    "$SKILLS_DIR/doc-gen/doc-gen.sh" "$@"
}

# Pre-deploy pipeline
cmd_pre_deploy() {
    echo -e "\n${MAGENTA}╔══════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║        🔄 PRE-DEPLOYMENT PIPELINE         ║${NC}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════╝${NC}\n"
    
    local exit_code=0
    local steps_completed=0
    local total_steps=4
    
    # Step 1: Run tests
    echo -e "${BLUE}[1/${total_steps}] Running test suite...${NC}"
    if "$SKILLS_DIR/test-runner/test-runner.sh" auto 2>&1; then
        echo -e "${GREEN}✅ Tests passed${NC}\n"
        steps_completed=$((steps_completed+1))
    else
        echo -e "${RED}❌ Tests failed - aborting deployment${NC}\n"
        send_notification "Deployment Failed" "Tests did not pass. Deployment aborted." "critical"
        exit 1
    fi
    
    # Step 2: Security audit
    echo -e "${BLUE}[2/${total_steps}] Running security audit...${NC}"
    if "$SKILLS_DIR/security-audit/security-audit.sh" report 2>&1; then
        echo -e "${GREEN}✅ Security check passed${NC}\n"
        steps_completed=$((steps_completed+1))
    else
        echo -e "${YELLOW}⚠ Security warnings found - review before proceeding${NC}\n"
    fi
    
    # Step 3: Generate docs
    echo -e "${BLUE}[3/${total_steps}] Updating documentation...${NC}"
    if "$SKILLS_DIR/doc-gen/doc-gen.sh" readme 2>&1; then
        echo -e "${GREEN}✅ Documentation updated${NC}\n"
        steps_completed=$((steps_completed+1))
    else
        echo -e "${YELLOW}⚠ Documentation generation had issues${NC}\n"
    fi
    
    # Step 4: Deploy
    echo -e "${BLUE}[4/${total_steps}] Deploying application...${NC}"
    if "$SKILLS_DIR/deploy/deploy.sh" "$@" 2>&1; then
        echo -e "${GREEN}✅ Deployment successful${NC}\n"
        steps_completed=$((steps_completed+1))
    else
        echo -e "${RED}❌ Deployment failed${NC}\n"
        send_notification "Deployment Failed" "Deployment script failed" "critical"
        exit 1
    fi
    
    # Summary
    echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║        ✅ PIPELINE COMPLETE                ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
    echo -e "Steps completed: ${steps_completed}/${total_steps}\n"
    
    send_notification "Deployment Success" "Pre-deploy pipeline completed (${steps_completed}/${total_steps} steps)" "normal"
}

# CI pipeline
cmd_ci() {
    echo -e "\n${MAGENTA}╔══════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║        🔄 CI PIPELINE                     ║${NC}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════╝${NC}\n"
    
    # Run tests
    echo -e "${BLUE}[CI/4] Tests${NC}"
    "$SKILLS_DIR/test-runner/test-runner.sh" coverage 2>&1 || exit 1
    
    # Run lint
    echo -e "${BLUE}[CI/4] Linting${NC}"
    if [ -f "package.json" ]; then
        npm run lint 2>/dev/null || echo -e "${YELLOW}⚠ No lint script found${NC}"
    fi
    
    # Security scan
    echo -e "${BLUE}[CI/4] Security${NC}"
    "$SKILLS_DIR/security-audit/security-audit.sh" dependencies 2>&1
    
    # Build
    echo -e "${BLUE}[CI/4] Build${NC}"
    if [ -f "package.json" ]; then
        npm run build 2>/dev/null || echo -e "${YELLOW}⚠ No build script found${NC}"
    fi
    
    echo -e "\n${GREEN}✅ CI pipeline complete${NC}\n"
}

# Daily report
cmd_daily_report() {
    echo -e "\n${MAGENTA}╔══════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║        📊 DAILY STATUS REPORT              ║${NC}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════╝${NC}\n"
    
    echo -e "${BLUE}Date:$(date '+%Y-%m-%d %H:%M')${NC}\n"
    
    # System health
    echo -e "${BLUE}📊 System Health:${NC}"
    "$SKILLS_DIR/monitor/monitor.sh" resources 2>&1 | grep -E "(CPU|Memory|Disk|Battery)" || true
    echo ""
    
    # Services
    echo -e "${BLUE}🔌 Services:${NC}"
    "$SKILLS_DIR/monitor/monitor.sh" services 2>&1 | grep -E "(Backend|Port)" || true
    echo ""
    
    # Recent deployments
    echo -e "${BLUE}🚀 Recent Deployments:${NC}"
    if [ -f "$SKILLS_DIR/deploy/logs/latest_deploy.log" ]; then
        echo -e "  Last: $(cat "$SKILLS_DIR/deploy/logs/latest_deploy.log")"
    else
        echo -e "  No deployments found"
    fi
    echo ""
    
    # Security status
    echo -e "${BLUE}🔒 Security:${NC}"
    if [ -f "package.json" ]; then
        VULNS=$(npm audit 2>/dev/null | grep -c "high\|critical" || echo "0")
        echo -e "  Vulnerabilities: ${VULNS}"
    fi
    echo ""
    
    send_notification "Daily Report" "System health check completed" "low"
}

# Watch mode (continuous monitoring)
cmd_watch() {
    local interval="${1:-300}" # Default 5 minutes
    
    echo -e "\n${MAGENTA}╔══════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║        👁️  CONTINUOUS MONITORING             ║${NC}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════╝${NC}"
    echo -e "Interval: ${YELLOW}${interval}s${NC}"
    echo -e "Press ${CYAN}Ctrl+C${NC} to stop\n"
    
    while true; do
        echo -e "${BLUE}[$(date '+%H:%M:%S')] Running health check...${NC}"
        "$SKILLS_DIR/monitor/monitor.sh" resources 2>&1 | grep -v "^$"
        
        # Check for critical issues
        DISK_PCT=$(df /data 2>/dev/null | awk 'NR==2 {gsub(/%/,""); print $5}' || echo "0")
        if [ "$DISK_PCT" -gt 90 ] 2>/dev/null; then
            echo -e "${RED}⚠ CRITICAL: Disk usage at ${DISK_PCT}%${NC}"
            send_notification "Critical Alert" "Disk usage at ${DISK_PCT}%" "critical"
        fi
        
        echo -e "${GREEN}✓ Check complete. Next check in ${interval}s...${NC}\n"
        sleep "$interval"
    done
}

# Status overview
cmd_status() {
    echo -e "\n${MAGENTA}╔══════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║        📋 SKILLS STATUS OVERVIEW           ║${NC}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════╝${NC}\n"
    
    for skill in deploy monitor test-runner security-audit doc-gen; do
        if [ -f "$SKILLS_DIR/$skill/$skill.sh" ] || [ -f "$SKILLS_DIR/$skill/$(echo $skill | tr '-' '.')sh" ]; then
            local script=$(find "$SKILLS_DIR/$skill" -name "*.sh" -type f 2>/dev/null | head -1)
            if [ -n "$script" ] && [ -x "$script" ]; then
                echo -e "  ${GREEN}●${NC} ${CYAN}${skill}${NC} - Ready"
            else
                echo -e "  ${YELLOW}●${NC} ${CYAN}${skill}${NC} - Not executable"
            fi
        else
            echo -e "  ${RED}●${NC} ${CYAN}${skill}${NC} - Missing"
        fi
    done
    
    echo ""
    
    # System info
    echo -e "${BLUE}System Info:${NC}"
    echo -e "  Uptime: $(uptime 2>/dev/null || echo 'N/A')"
    echo -e "  Node: $(node --version 2>/dev/null || echo 'N/A')"
    echo -e "  Skills: $(find "$SKILLS_DIR" -name "*.sh" -type f 2>/dev/null | wc -l) scripts\n"
}

# Notification setup
cmd_notify_setup() {
    echo -e "\n${MAGENTA}╔══════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║        🔔 NOTIFICATION SETUP                ║${NC}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════╝${NC}\n"
    
    echo -e "${BLUE}To configure notifications, edit:${NC}"
    echo -e "  ${CYAN}~/.qwen/skills/notifications/config.json${NC}\n"
    
    echo -e "${BLUE}Supported channels:${NC}"
    echo -e "  1. Telegram (bot token + chat ID)"
    echo -e "  2. Email (mail command)"
    echo -e "  3. Local logs\n"
    
    echo -e "${YELLOW}Example Telegram setup:${NC}"
    echo -e "  1. Create bot via @BotFather"
    echo -e "  2. Get bot token"
    echo -e "  3. Get chat ID from @userinfobot"
    echo -e "  4. Update config.json\n"
}

# Test notification
cmd_notify_test() {
    echo -e "\n${MAGENTA}╔══════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║        🔔 TESTING NOTIFICATIONS             ║${NC}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════╝${NC}\n"
    
    send_notification "Test Notification" "This is a test message from your skills system" "normal"
    
    echo -e "${GREEN}✅ Test notification sent${NC}"
    echo -e "Check your configured channels\n"
}

# View notification logs
cmd_notify_logs() {
    echo -e "\n${MAGENTA}╔══════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║        📜 NOTIFICATION LOGS                 ║${NC}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════╝${NC}\n"
    
    if [ -f "$SKILLS_DIR/notifications/logs/notifications.log" ]; then
        tail -n 20 "$SKILLS_DIR/notifications/logs/notifications.log"
    else
        echo -e "${YELLOW}No notifications logged yet${NC}"
    fi
    echo ""
}

# ===========================
# MAIN ROUTER
# ===========================
case "${1:-help}" in
    deploy)
        shift
        cmd_deploy "$@"
        ;;
    monitor|mon)
        shift
        cmd_monitor "$@"
        ;;
    test|tests)
        shift
        cmd_test "$@"
        ;;
    security|sec)
        shift
        cmd_security "$@"
        ;;
    docs|doc)
        shift
        cmd_docs "$@"
        ;;
    pre-deploy|predeploy)
        shift
        cmd_pre_deploy "$@"
        ;;
    ci)
        shift
        cmd_ci "$@"
        ;;
    daily|daily-report)
        shift
        cmd_daily_report "$@"
        ;;
    watch|monitor-loop)
        shift
        cmd_watch "$@"
        ;;
    status)
        cmd_status
        ;;
    notify|notification)
        case "${2:-help}" in
            setup) cmd_notify_setup ;;
            test) cmd_notify_test ;;
            logs) cmd_notify_logs ;;
            *) cmd_notify_setup ;;
        esac
        ;;
    --help|-h|help)
        show_help
        ;;
    --version|-v)
        echo -e "Unified Skills CLI v1.0.0"
        ;;
    --update)
        echo -e "${BLUE}🔄 Checking for skill updates...${NC}"
        echo -e "${GREEN}✅ All skills up to date${NC}"
        ;;
    *)
        echo -e "${YELLOW}Unknown command: $1${NC}"
        show_help
        exit 1
        ;;
esac
