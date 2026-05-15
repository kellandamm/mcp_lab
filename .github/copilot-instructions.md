# Workshop MCP Security Workshop — Copilot Instructions

## Repository Structure

```
Workshop/
├── modules/                       # Workshop modules
│   ├── base-module/               # Local-only MCP fundamentals
│   ├── module1-identity/        # OAuth, Managed Identity, Key Vault
│   ├── gateway/           # APIM gateway, Content Safety, API Center
│   ├── io-security/       # Input validation, output sanitization, PII
│   └── monitoring/        # Logging, dashboards, alerts, incident response
├── docs/                        # MkDocs documentation site
│   └── modules/                   # Workshop guides (mirrors modules/ structure)
├── infra/                       # Shared infrastructure docs
└── mkdocs.yml                   # MkDocs configuration
```

## Module Conventions

Each Azure module (1–4) follows this layout:

| Path | Purpose |
|------|---------|
| `azure.yaml` | azd project definition with `hooks:` for `preprovision` and `postprovision` |
| `infra/` | Bicep modules for Azure resources |
| `scripts/` | Waypoint scripts following **exploit → fix → validate** pattern |
| `scripts/hooks/` | azd lifecycle hooks (preprovision, postprovision) |
| `tests/` | Test and example scripts |
| `servers/` | MCP server and API source code (Python, FastMCP) |

### Script Naming

- **Numbered waypoints:** `{section}.{waypoint}-{action}.sh` — e.g., `1.1-deploy.sh`, `2.1-validate.sh`
- **Functional names:** `register-entra-app.sh`, `get-mcp-token.sh` (Module 1 uses this style)
- **Subdirectories:** Module 4 uses `scripts/section{N}/` subdirectories
- **Utility libraries:** Some modules have shared functions (e.g., `common.sh` sourced by other scripts)

### azure.yaml Hooks

When a module has both `.sh` and `.ps1` hooks, the `azure.yaml` uses platform-specific sections:

```yaml
hooks:
  preprovision:
    posix:
      shell: sh
      run: ./scripts/hooks/preprovision.sh
      continueOnError: false
    windows:
      shell: pwsh
      run: ./scripts/hooks/preprovision.ps1
      continueOnError: false
```

## Windows Support

Every `.sh` script should have a corresponding `.ps1` PowerShell equivalent. Module 2 is the reference implementation with full parity. Use the `/windows-scripts` skill for conversion and `/windows-docs` skill for documentation updates.

## Documentation

- Built with **MkDocs Material** (`mkdocs.yml` at repo root)
- Tab syntax for OS-specific commands uses `=== "Bash"` / `=== "PowerShell"` content tabs
- Indentation matters — tabs inside admonitions (`???`, `!!!`, `???+`) require extra 4-space indent
- Cross-platform commands (e.g., `azd provision`, `az account show`) do NOT need tabs

## Code Guidelines

- **Python:** 3.11+, type hints, `uv` for package management
- **Bash scripts:** `set -e` (or `set -euo pipefail`), clear progress output with section headers
- **PowerShell scripts:** `$ErrorActionPreference = 'Stop'`, use `curl.exe` (not the PowerShell alias), use `ConvertFrom-Json` / `ConvertTo-Json` instead of `jq`
- **Bicep:** Consistent naming with `abbreviations.json`, security-focused comments
