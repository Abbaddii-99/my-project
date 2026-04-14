#!/data/data/com.termux/files/usr/bin/bash

# Skills Monitoring Loop Service
# This runs in the background and monitors system health
# Usage: ./monitor-loop.sh [interval_seconds]

INTERVAL="${1:-300}" # Default 5 minutes
SKILLS_DIR="$HOME/.qwen/skills"
PID_FILE="$SKILLS_DIR/monitor/monitor-loop.pid"

# Check if already running
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        echo "⚠ Monitor loop already running (PID: $OLD_PID)"
        echo "Stop it first: kill $OLD_PID"
        exit 1
    fi
fi

# Save PID
echo $$ > "$PID_FILE"

echo "╔══════════════════════════════════════════╗"
echo "║        👁️  MONITOR LOOP STARTED            ║"
echo "╚══════════════════════════════════════════╝"
echo "Interval: ${INTERVAL}s"
echo "PID: $$"
echo "Log: $SKILLS_DIR/monitor/logs/loop_$(date +%Y%m%d).log"
echo "Press Ctrl+C or run: kill $$"
echo ""

# Trap to clean up PID file on exit
trap 'rm -f "$PID_FILE"; echo "Monitor loop stopped"; exit 0' INT TERM

while true; do
    TIMESTAMP=$(date '+%H:%M:%S')
    LOG_FILE="$SKILLS_DIR/monitor/logs/loop_$(date +%Y%m%d).log"
    
    echo -e "\n[$TIMESTAMP] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "[$TIMESTAMP] Running health check..."
    
    # Run monitor
    "$SKILLS_DIR/monitor/monitor.sh" resources 2>&1 | tee -a "$LOG_FILE"
    
    # Check for critical issues
    DISK_PCT=$(df /data 2>/dev/null | awk 'NR==2 {gsub(/%/,""); print $5}' || echo "0")
    MEM_PCT=$(free -m 2>/dev/null | awk '/^Mem:/ {printf "%.0f", $3/$2*100}' || echo "0")
    
    ALERT_TRIGGERED=false
    ALERT_MESSAGE=""
    
    if [ "$DISK_PCT" -gt 90 ] 2>/dev/null; then
        echo -e "🚨 CRITICAL: Disk usage at ${DISK_PCT}%"
        ALERT_TRIGGERED=true
        ALERT_MESSAGE="Disk usage critical: ${DISK_PCT}%"
    fi
    
    if [ "$MEM_PCT" -gt 90 ] 2>/dev/null; then
        echo -e "🚨 CRITICAL: Memory usage at ${MEM_PCT}%"
        ALERT_TRIGGERED=true
        ALERT_MESSAGE="${ALERT_MESSAGE} Memory usage critical: ${MEM_PCT}%"
    fi
    
    # Send notification if alert triggered
    if [ "$ALERT_TRIGGERED" = true ]; then
        "$SKILLS_DIR/notifications/notify.sh" "Critical System Alert" "$ALERT_MESSAGE" "critical"
    fi
    
    echo "[$TIMESTAMP] ✓ Check complete. Next in ${INTERVAL}s..."
    
    sleep "$INTERVAL"
done
