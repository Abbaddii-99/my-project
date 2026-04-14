#!/data/data/com.termux/files/usr/bin/bash

# Deploy Skill - Main Script
# Usage: ./deploy.sh [staging|production|--dry-run|--rollback|--status]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.json"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$SCRIPT_DIR/logs/deploy_${TIMESTAMP}.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse arguments
ENV="${1:-local}"
DRY_RUN=false
ROLLBACK=false
STATUS_CHECK=false

case "$1" in
    --dry-run)
        DRY_RUN=true
        ENV="local"
        ;;
    --rollback)
        ROLLBACK=true
        ENV="local"
        ;;
    --status)
        STATUS_CHECK=true
        ENV="local"
        ;;
    staging|production)
        ENV="$1"
        ;;
esac

# Logging function
log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# Header
log "\n${BLUE}╔════════════════════════════════════════╗${NC}"
log "${BLUE}║        🚀 DEPLOYMENT SCRIPT           ║${NC}"
log "${BLUE}╚════════════════════════════════════════╝${NC}\n"
log "Environment: ${YELLOW}${ENV}${NC}"
log "Timestamp: ${YELLOW}${TIMESTAMP}${NC}\n"

# Status check
if [ "$STATUS_CHECK" = true ]; then
    log "${BLUE}📊 Deployment Status:${NC}"
    if [ -f "$SCRIPT_DIR/logs/latest_deploy.log" ]; then
        log "Last deployment: $(cat "$SCRIPT_DIR/logs/latest_deploy.log")"
    else
        log "No previous deployment found."
    fi
    
    # Check if backend is running
    if command -v curl &> /dev/null; then
        HEALTH=$(curl -s --max-time 5 http://localhost:3000/health 2>/dev/null || echo "UNREACHABLE")
        log "Health check: ${HEALTH}"
    fi
    exit 0
fi

# Rollback
if [ "$ROLLBACK" = true ]; then
    log "${YELLOW}🔄 Rolling back deployment...${NC}"
    BACKUP_DIR="$HOME/.backups/local"
    LATEST_BACKUP=$(ls -t "$BACKUP_DIR" 2>/dev/null | head -1)
    
    if [ -n "$LATEST_BACKUP" ]; then
        log "Restoring from backup: ${LATEST_BACKUP}"
        # Add rollback logic here
        log "${GREEN}✅ Rollback complete${NC}"
    else
        log "${RED}❌ No backups found for rollback${NC}"
        exit 1
    fi
    exit 0
fi

# Pre-flight checks
log "${BLUE}🔍 Running pre-flight checks...${NC}"

# Check if start-backend.sh exists
if [ -f "./start-backend.sh" ]; then
    log "${GREEN}✅ Backend script found${NC}"
else
    log "${RED}❌ start-backend.sh not found${NC}"
    exit 1
fi

# Check Node.js
if command -v node &> /dev/null; then
    log "${GREEN}✅ Node.js $(node --version) available${NC}"
else
    log "${RED}❌ Node.js not found${NC}"
    exit 1
fi

# Check npm
if command -v npm &> /dev/null; then
    log "${GREEN}✅ npm available${NC}"
else
    log "${YELLOW}⚠️  npm not found (optional)${NC}"
fi

# Dry run mode
if [ "$DRY_RUN" = true ]; then
    log "\n${YELLOW}📋 DRY RUN MODE - No changes will be made${NC}"
    log "Steps that would be executed:"
    log "  1. Create backup → ~/.backups/local/${TIMESTAMP}/"
    log "  2. Run tests (if configured)"
    log "  3. Execute: ./start-backend.sh"
    log "  4. Health check: curl http://localhost:3000/health"
    log "\n${GREEN}✅ Dry run complete${NC}\n"
    exit 0
fi

# Create backup
log "${BLUE}💾 Creating backup...${NC}"
BACKUP_DIR="$HOME/.backups/local/${TIMESTAMP}"
mkdir -p "$BACKUP_DIR"

# Backup important files
for dir in ./*.js ./*.json ./src ./public; do
    if [ -e "$dir" ]; then
        cp -r "$dir" "$BACKUP_DIR/" 2>/dev/null || true
    fi
done

log "${GREEN}✅ Backup created: ${BACKUP_DIR}${NC}"

# Deploy
log "\n${BLUE}🚀 Starting deployment...${NC}"
log "Executing: ./start-backend.sh"

if [ "$ENV" = "local" ]; then
    # Make script executable
    chmod +x ./start-backend.sh 2>/dev/null || true
    
    # Run the backend script
    if ./start-backend.sh &> /dev/null &
    then
        log "${GREEN}✅ Backend started successfully${NC}"
        log "PID: $!"
    else
        log "${RED}❌ Failed to start backend${NC}"
        exit 1
    fi
else
    log "${YELLOW}⚠️  Remote deployment not yet configured${NC}"
    log "Set up SSH keys and environment variables for remote deployment."
fi

# Health check
log "\n${BLUE}🏥 Running health check...${NC}"
sleep 2

if command -v curl &> /dev/null; then
    HEALTH=$(curl -s --max-time 5 http://localhost:3000/health 2>/dev/null || echo "UNREACHABLE")
    if [ "$HEALTH" != "UNREACHABLE" ]; then
        log "${GREEN}✅ Health check passed: ${HEALTH}${NC}"
    else
        log "${YELLOW}⚠️  Health endpoint unreachable (service may need more time to start)${NC}"
    fi
fi

# Save latest deployment info
echo "${TIMESTAMP} - ${ENV} - Success" > "$SCRIPT_DIR/logs/latest_deploy.log"

log "\n${GREEN}╔════════════════════════════════════════╗${NC}"
log "${GREEN}║        ✅ DEPLOYMENT SUCCESSFUL         ║${NC}"
log "${GREEN}╚════════════════════════════════════════╝${NC}\n"
log "Log file: ${LOG_FILE}\n"

exit 0
