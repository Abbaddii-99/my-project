#!/data/data/com.termux/files/usr/bin/bash

# Monitor Skill - Main Script
# Usage: ./monitor.sh [services|resources|logs|report]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$SCRIPT_DIR/logs/monitor_${TIMESTAMP}.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

MODE="${1:-full}"

log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# Header
log "\n${CYAN}╔════════════════════════════════════════╗${NC}"
log "${CYAN}║        📊 SYSTEM MONITOR               ║${NC}"
log "${CYAN}╚════════════════════════════════════════╝${NC}"
log "Timestamp: ${YELLOW}${TIMESTAMP}${NC}"
log "Mode: ${YELLOW}${MODE}${NC}\n"

# Check Services
check_services() {
    log "${BLUE}🔌 Service Status:${NC}"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check backend
    if curl -s --max-time 3 http://localhost:3000/health &>/dev/null; then
        log "  Backend (3000):  ${GREEN}● RUNNING${NC}"
    else
        log "  Backend (3000):  ${RED}● STOPPED${NC}"
    fi
    
    # Check common ports
    for port in 80 443 5432 6379 27017 8080; do
        if command -v nc &>/dev/null && nc -z localhost $port 2>/dev/null; then
            log "  Port ${port}:      ${GREEN}● OPEN${NC}"
        fi
    done
    log ""
}

# Check Resources
check_resources() {
    log "${BLUE}💻 Resource Usage:${NC}"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # CPU
    if command -v top &>/dev/null; then
        CPU=$(top -bn1 2>/dev/null | grep "Cpu" | awk '{print $2}' || echo "N/A")
        log "  CPU Usage:       ${YELLOW}${CPU}%${NC}"
    fi
    
    # Memory
    if command -v free &>/dev/null; then
        MEM=$(free -m 2>/dev/null | awk '/^Mem:/ {printf "%.1f%%", $3/$2*100}' || echo "N/A")
        log "  Memory Usage:    ${YELLOW}${MEM}${NC}"
    elif command -v vmstat &>/dev/null; then
        log "  Memory:          ${YELLOW}$(vmstat -s 2>/dev/null | head -2 || echo "N/A")${NC}"
    fi
    
    # Disk
    if command -v df &>/dev/null; then
        DISK=$(df -h /data 2>/dev/null | awk 'NR==2 {print $5}' || echo "N/A")
        log "  Disk Usage:      ${YELLOW}${DISK}${NC}"
    fi
    
    # Battery (Termux specific)
    if command -v termux-battery-status &>/dev/null; then
        BATTERY=$(termux-battery-status 2>/dev/null | grep -o '"percentage": [0-9]*' | awk '{print $2}' || echo "N/A")
        log "  Battery:         ${YELLOW}${BATTERY}%${NC}"
    fi
    log ""
}

# Check Processes
check_processes() {
    log "${BLUE}⚙️  Top Processes:${NC}"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if command -v ps &>/dev/null; then
        ps aux --sort=-%mem 2>/dev/null | head -6 | awk '{printf "  %-10s %-8s %-6s %s\n", $11, $1, $4"%", $6"KB"}'
    fi
    log ""
}

# Generate Report
generate_report() {
    log "${BLUE}📋 Health Report Summary:${NC}"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    ISSUES=0
    
    # Disk space warning
    DISK_PCT=$(df /data 2>/dev/null | awk 'NR==2 {gsub(/%/,""); print $5}' || echo "0")
    if [ "$DISK_PCT" -gt 80 ] 2>/dev/null; then
        log "  ${RED}⚠ Disk usage above 80%: ${DISK_PCT}%${NC}"
        ISSUES=$((ISSUES+1))
    fi
    
    # Check for zombie processes
    ZOMBIES=$(ps aux 2>/dev/null | awk '$8=="Z" {count++} END {print count+0}')
    if [ "$ZOMBIES" -gt 0 ] 2>/dev/null; then
        log "  ${RED}⚠ Zombie processes detected: ${ZOMBIES}${NC}"
        ISSUES=$((ISSUES+1))
    fi
    
    # Node.js memory check
    if command -v node &>/dev/null; then
        NODE_MEM=$(node -e "const m = process.memoryUsage(); console.log(Math.round(m.heapUsed/1024/1024))" 2>/dev/null || echo "0")
        if [ "$NODE_MEM" -gt 500 ] 2>/dev/null; then
            log "  ${YELLOW}⚠ Node.js heap usage: ${NODE_MEM}MB${NC}"
            ISSUES=$((ISSUES+1))
        fi
    fi
    
    if [ "$ISSUES" -eq 0 ]; then
        log "  ${GREEN}✅ No critical issues found${NC}"
    else
        log "\n  ${YELLOW}Total Issues: ${ISSUES}${NC}"
    fi
    log ""
}

# Execute based on mode
case "$MODE" in
    services)
        check_services
        ;;
    resources)
        check_resources
        ;;
    logs)
        log "${BLUE}📜 Recent Error Logs:${NC}"
        log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        tail -n 20 ~/.qwen/skills/deploy/logs/*.log 2>/dev/null || log "  No logs found"
        ;;
    report|full)
        check_services
        check_resources
        check_processes
        generate_report
        ;;
    *)
        log "${YELLOW}Usage: $0 [services|resources|logs|report|full]${NC}"
        exit 1
        ;;
esac

log "${GREEN}✅ Monitor check complete${NC}"
log "Log: ${LOG_FILE}\n"
