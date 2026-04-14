#!/data/data/com.termux/files/usr/bin/bash

# Test Runner Skill - Main Script
# Usage: ./test-runner.sh [unit|integration|coverage|watch|path]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

MODE="${1:-auto}"
TARGET="${2:-.}"

echo -e "\n${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║        🧪 TEST RUNNER                   ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo -e "Mode: ${YELLOW}${MODE}${NC}\n"

# Detect test framework
detect_framework() {
    echo -e "${BLUE}🔍 Detecting test framework...${NC}"
    
    # Node.js projects
    if [ -f "package.json" ]; then
        if grep -q "jest" package.json 2>/dev/null; then
            echo "jest"
            return
        elif grep -q "mocha" package.json 2>/dev/null; then
            echo "mocha"
            return
        elif grep -q "vitest" package.json 2>/dev/null; then
            echo "vitest"
            return
        elif [ -d "node_modules/.bin/jest" ]; then
            echo "jest"
            return
        fi
    fi
    
    # Python projects
    if [ -f "pytest.ini" ] || [ -f "pyproject.toml" ]; then
        if command -v pytest &>/dev/null; then
            echo "pytest"
            return
        fi
    fi
    
    if [ -f "setup.py" ] || ls test_*.py 2>/dev/null | head -1 &>/dev/null; then
        echo "unittest"
        return
    fi
    
    # Go projects
    if ls *_test.go 2>/dev/null | head -1 &>/dev/null; then
        echo "go-test"
        return
    fi
    
    echo "none"
}

FRAMEWORK=$(detect_framework)
echo -e "Detected: ${GREEN}${FRAMEWORK}${NC}\n"

# Run tests based on framework
run_tests() {
    case "$FRAMEWORK" in
        jest)
            echo -e "${BLUE}Running Jest tests...${NC}"
            if [ "$MODE" = "coverage" ]; then
                npx jest --coverage --testPathPattern="$TARGET"
            elif [ "$MODE" = "watch" ]; then
                npx jest --watch
            else
                npx jest --testPathPattern="$TARGET" --verbose
            fi
            ;;
        mocha)
            echo -e "${BLUE}Running Mocha tests...${NC}"
            if [ "$MODE" = "coverage" ]; then
                npx nyc mocha "test/**/*.js"
            else
                npx mocha "test/**/*.js" --reporter spec
            fi
            ;;
        vitest)
            echo -e "${BLUE}Running Vitest tests...${NC}"
            if [ "$MODE" = "watch" ]; then
                npx vitest watch
            else
                npx vitest run --reporter=verbose
            fi
            ;;
        pytest)
            echo -e "${BLUE}Running Pytest...${NC}"
            if [ "$MODE" = "coverage" ]; then
                pytest --cov=. --cov-report=term-missing "$TARGET"
            else
                pytest -v "$TARGET"
            fi
            ;;
        unittest)
            echo -e "${BLUE}Running Python unittest...${NC}"
            python -m unittest discover -s "$TARGET" -v
            ;;
        go-test)
            echo -e "${BLUE}Running Go tests...${NC}"
            if [ "$MODE" = "coverage" ]; then
                go test -v -coverprofile=coverage.out ./...
            else
                go test -v ./...
            fi
            ;;
        none)
            echo -e "${YELLOW}⚠ No test framework detected${NC}"
            echo -e "\nSuggestions:"
            echo -e "  Node.js: ${CYAN}npm install --save-dev jest${NC}"
            echo -e "  Python:  ${CYAN}pip install pytest${NC}"
            echo -e "  Go:      ${CYAN}Built-in testing support${NC}"
            echo -e "\nCreating test directory structure..."
            mkdir -p test tests/__tests__ tests
            echo -e "${GREEN}✅ Test directories created${NC}"
            ;;
    esac
}

# Execute
EXIT_CODE=0
run_tests || EXIT_CODE=$?

# Summary
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
else
    echo -e "${RED}❌ Tests failed (exit code: ${EXIT_CODE})${NC}"
fi
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

exit $EXIT_CODE
