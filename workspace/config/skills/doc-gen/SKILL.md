# Doc Generator Skill

## Overview
Automated documentation generation from source code, APIs, and project structure.

## Usage
```
/doc-gen                    # Generate full project docs
/doc-gen api                # Document API endpoints
/doc-gen functions          # Document all functions
/doc-gen readme             # Generate/update README.md
/doc-gen architecture       # Document system architecture
/doc-gen diagrams           # Generate architecture diagrams
```

## Output Formats
- Markdown (.md)
- HTML documentation site
- Mermaid diagrams
- OpenAPI/Swagger specs

## Features
- Parse JSDoc, docstrings, type annotations
- Generate function signatures and descriptions
- Create module dependency graphs
- Auto-update existing documentation

## Configuration
Edit `~/.qwen/skills/doc-gen/config.json`
