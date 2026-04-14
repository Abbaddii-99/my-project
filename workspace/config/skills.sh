#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/skills/unified-cli/skills.sh" ]; then
    "$SCRIPT_DIR/skills/unified-cli/skills.sh" "$@"
else
    echo "Skills CLI not found. Running individual skills..."
    case "$1" in
        status) ls -la "$SCRIPT_DIR/skills/" ;;
        *) echo "Usage: ./skills.sh [status|deploy|monitor|test|security|docs|notify|watch|pre-deploy]" ;;
    esac
fi
