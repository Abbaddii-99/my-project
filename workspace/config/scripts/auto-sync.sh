#!/data/data/com.termux/files/usr/bin/bash

# Auto-Sync Script for Qwen Skills Settings
# Monitors changes and automatically commits to GitHub
# Usage: ./auto-sync.sh [start|stop|status|sync]

set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PID_FILE="$REPO_DIR/logs/auto-sync.pid"
LOG_FILE="$REPO_DIR/logs/sync.log"
CHECK_INTERVAL=60  # Check every 60 seconds

mkdir -p "$REPO_DIR/logs"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Sync function
do_sync() {
    local message="${1:-Auto-sync: $(date '+%Y-%m-%d %H:%M')}"
    
    cd "$REPO_DIR"
    
    # Check for changes
    if [ -z "$(git status --porcelain)" ]; then
        log "${YELLOW}⚠ No changes to commit${NC}"
        return 0
    fi
    
    # Add all changes
    git add -A 2>/dev/null || true
    
    # Commit
    git commit -m "$message" 2>/dev/null || {
        log "${RED}❌ Commit failed${NC}"
        return 1
    }
    
    # Push
    git push origin main 2>/dev/null || {
        log "${YELLOW}⚠ Push failed (check connection)${NC}"
        return 1
    }
    
    log "${GREEN}✅ Synced: $message${NC}"
    return 0
}

# Check for changes without committing
check_changes() {
    cd "$REPO_DIR"
    
    local changed=$(git status --porcelain 2>/dev/null)
    if [ -n "$changed" ]; then
        echo "${YELLOW}⚠ Uncommitted changes found:${NC}"
        echo "$changed"
        return 1
    else
        echo "${GREEN}✅ Repository is up to date${NC}"
        return 0
    fi
}

# Start auto-sync
start_sync() {
    # Check if already running
    if [ -f "$PID_FILE" ]; then
        local old_pid=$(cat "$PID_FILE")
        if kill -0 "$old_pid" 2>/dev/null; then
            log "${YELLOW}⚠ Auto-sync already running (PID: $old_pid)${NC}"
            exit 1
        fi
    fi
    
    # Save PID
    echo $$ > "$PID_FILE"
    
    log "\n${CYAN}╔══════════════════════════════════════════╗${NC}"
    log "${CYAN}║        🔄 AUTO-SYNC STARTED                ║${NC}"
    log "${CYAN}╚══════════════════════════════════════════╝${NC}"
    log "Repository: $REPO_DIR"
    log "Check interval: ${CHECK_INTERVAL}s"
    log "Log: $LOG_FILE"
    log "Stop with: ./auto-sync.sh stop\n"
    
    # Trap to clean up PID file on exit
    trap 'rm -f "$PID_FILE"; log "Auto-sync stopped"; exit 0' INT TERM
    
    # Initial sync
    log "${BLUE}🔄 Running initial sync...${NC}"
    do_sync "Initial sync"
    
    # Monitor loop
    while true; do
        sleep "$CHECK_INTERVAL"
        
        cd "$REPO_DIR"
        if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
            log "${BLUE}🔄 Changes detected, syncing...${NC}"
            do_sync "Auto-sync: $(date '+%Y-%m-%d %H:%M:%S')"
        fi
    done
}

# Stop auto-sync
stop_sync() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            log "${BLUE}🛑 Stopping auto-sync (PID: $pid)...${NC}"
            kill "$pid"
            rm -f "$PID_FILE"
            log "${GREEN}✅ Auto-sync stopped${NC}"
        else
            log "${YELLOW}⚠ Process not running, cleaning up${NC}"
            rm -f "$PID_FILE"
        fi
    else
        log "${YELLOW}⚠ Auto-sync not running${NC}"
    fi
}

# Show status
show_status() {
    log "\n${CYAN}╔══════════════════════════════════════════╗${NC}"
    log "${CYAN}║        📊 AUTO-SYNC STATUS                 ║${NC}"
    log "${CYAN}╚══════════════════════════════════════════╝${NC}\n"
    
    # Check if running
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            log "Status: ${GREEN}● RUNNING${NC} (PID: $pid)"
        else
            log "Status: ${RED}● STOPPED${NC} (stale PID file)"
            rm -f "$PID_FILE"
        fi
    else
        log "Status: ${RED}● STOPPED${NC}"
    fi
    
    # Repository status
    cd "$REPO_DIR"
    log "\nRepository: $REPO_DIR"
    log "Branch: $(git branch --show-current 2>/dev/null || echo 'N/A')"
    
    # Last commit
    log "Last commit: $(git log -1 --oneline 2>/dev/null || echo 'No commits yet')"
    
    # Check for changes
    log "\nUncommitted changes:"
    check_changes
    
    # Recent sync logs
    if [ -f "$LOG_FILE" ]; then
        log "\nRecent sync activity:"
        tail -n 5 "$LOG_FILE"
    fi
    
    log ""
}

# Manual sync
manual_sync() {
    log "${BLUE}🔄 Running manual sync...${NC}"
    do_sync "Manual sync: $(date '+%Y-%m-%d %H:%M:%S')"
}

# Main router
case "${1:-status}" in
    start)
        start_sync
        ;;
    stop)
        stop_sync
        ;;
    status)
        show_status
        ;;
    sync|manual)
        manual_sync
        ;;
    check)
        check_changes
        ;;
    *)
        echo -e "${YELLOW}Usage: $0 {start|stop|status|sync|check}${NC}"
        exit 1
        ;;
esac
