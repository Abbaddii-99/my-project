#!/data/data/com.termux/files/usr/bin/bash

# Notification Service - Standalone
# Usage: ./notify.sh "Title" "Message" [priority]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.json"
LOG_FILE="$SCRIPT_DIR/logs/notifications.log"

mkdir -p "$SCRIPT_DIR/logs"

TITLE="${1:-Notification}"
MESSAGE="${2:-No message provided}"
PRIORITY="${3:-normal}"

# Load config
if [ -f "$CONFIG_FILE" ]; then
    # Telegram
    TG_ENABLED=$(grep -o '"enabled": *false' "$CONFIG_FILE" | head -1 | awk '{print $2}' || echo "false")
    BOT_TOKEN=$(grep -o '"bot_token": *"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4 || echo "")
    CHAT_ID=$(grep -o '"chat_id": *"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4 || echo "")
    
    if [ "$TG_ENABLED" = "true" ] && [ -n "$BOT_TOKEN" ] && [ -n "$CHAT_ID" ]; then
        TEXT="*${TITLE}*\n\n${MESSAGE}"
        curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
            -d "chat_id=${CHAT_ID}" \
            -d "text=${TEXT}" \
            -d "parse_mode=Markdown" &>/dev/null &
    fi
    
    # Email
    EMAIL_ENABLED=$(grep -o '"email_enabled": *[a-z]*' "$CONFIG_FILE" 2>/dev/null | awk '{print $2}' || echo "false")
    EMAIL_TO=$(grep -o '"email_to": *"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4 || echo "")
    
    if [ "$EMAIL_ENABLED" = "true" ] && [ -n "$EMAIL_TO" ] && command -v mail &>/dev/null; then
        echo "$MESSAGE" | mail -s "$TITLE" "$EMAIL_TO" 2>/dev/null &
    fi
fi

# Always log
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${PRIORITY^^}] ${TITLE}: ${MESSAGE}" >> "$LOG_FILE"

echo -e "✅ Notification logged: ${TITLE}"
