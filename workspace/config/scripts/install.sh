#!/data/data/com.termux/files/usr/bin/bash

# Install Skills from Repository
# Usage: ./install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="$HOME/.qwen/skills"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "\n${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║        📦 QWEN SKILLS INSTALLER            ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}\n"

# Create skills directory
mkdir -p "$SKILLS_DIR"

# Install each skill
for skill_dir in "$REPO_DIR/skills"/*/; do
    skill_name=$(basename "$skill_dir")
    echo -e "${BLUE}Installing: ${CYAN}${skill_name}${NC}"
    
    if [ -d "$skill_dir" ]; then
        # Backup existing skill if present
        if [ -d "$SKILLS_DIR/$skill_name" ]; then
            echo -e "  ${YELLOW}⚠ Backing up existing ${skill_name}...${NC}"
            mv "$SKILLS_DIR/$skill_name" "$SKILLS_DIR/${skill_name}.bak.$(date +%Y%m%d_%H%M%S)"
        fi
        
        # Copy skill
        cp -r "$skill_dir" "$SKILLS_DIR/$skill_name"
        
        # Make scripts executable
        find "$SKILLS_DIR/$skill_name" -name "*.sh" -exec chmod +x {} \;
        
        echo -e "  ${GREEN}✅ ${skill_name} installed${NC}"
    fi
done

# Setup unified CLI alias
if ! grep -q "alias skills=" ~/.bashrc 2>/dev/null; then
    echo -e "\n${BLUE}Adding 'skills' alias to ~/.bashrc...${NC}"
    echo 'alias skills="~/.qwen/skills/unified-cli/skills.sh"' >> ~/.bashrc
    echo -e "${GREEN}✅ Alias added${NC}"
else
    echo -e "${YELLOW}⚠ Alias already exists${NC}"
fi

echo -e "\n${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        ✅ INSTALLATION COMPLETE            ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo -e "\nRun ${CYAN}source ~/.bashrc${NC} or restart terminal"
echo -e "Then use: ${CYAN}skills --help${NC}\n"
