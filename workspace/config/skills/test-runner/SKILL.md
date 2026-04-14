# Test Runner Skill

## Overview
Automated test detection, execution, and reporting across any project type.

## Usage
```
/test-runner                # Auto-detect and run tests
/test-runner unit            # Run unit tests only
/test-runner integration     # Run integration tests only
/test-runner coverage        # Run tests with coverage report
/test-runner watch           # Watch mode for TDD
/test-runner [path]          # Run tests in specific directory
```

## Supported Frameworks
- Jest / Mocha / Vitest (Node.js)
- Pytest / Unittest (Python)
- Go test (Golang)
- PHPUnit (PHP)

## Features
- Auto-detect test framework
- Parallel test execution
- Coverage reporting
- Test result caching
- Failure summaries

## Configuration
Edit `~/.qwen/skills/test-runner/config.json`
