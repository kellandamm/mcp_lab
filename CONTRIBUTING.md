# Contributing

Thank you for your interest in improving this workshop!

## Quick Links

- **📚 Workshop:** [azure-samples.github.io/Workshop](https://azure-samples.github.io/Workshop/)
- **🔒 Security Guide:** [microsoft.github.io/mcp-azure-security-guide](https://microsoft.github.io/mcp-azure-security-guide/)

## Repository Structure

```
Workshop/
├── modules/                    # Workshop modules
│   ├── base-module/            # Local-only, MCP fundamentals
│   ├── module1-identity/     # Azure: OAuth, Managed Identity
│   ├── gateway/        # Azure: APIM, Content Safety
│   ├── io-security/    # Azure: Input validation, PII
│   └── monitoring/     # Azure: Logging, alerts
├── docs/                     # MkDocs documentation
│   └── modules/                # Workshop guides
└── mkdocs.yml
```

## Workshop Pattern

All modules follow **exploit → fix → validate**:

1. Start with a vulnerable or incomplete configuration
2. Demonstrate the security risk
3. Apply the fix
4. Validate the fix works

## Module Types

| Type | Example | Deployment | Key Files |
|------|---------|------------|-----------|
| **Local** | Module 0 | `uv run python -m src.server` | `vulnerable-server/`, `secure-server/` |
| **Azure** | Modules 1–4 | `azd up` | `azure.yaml`, `infra/`, `scripts/` |

## Running Docs Locally

```bash
pip install -r requirements-docs.txt
mkdocs serve
```

## Code Guidelines

- **Python:** 3.11+, type hints, `uv` for dependencies
- **Bicep:** Consistent naming, security comments
- **Scripts:** Bash, `set -e`, clear progress output

## Testing Changes

1. Run through the workshop guide yourself
2. Verify exploit scripts demonstrate the vulnerability
3. Verify fix scripts resolve the issue
4. Check documentation renders correctly

## Submitting Changes

1. Fork and create a branch
2. Make changes and test thoroughly
3. Submit a Pull Request with a clear description

## Questions?

Open an [issue](https://github.com/Azure-Samples/Workshop/issues).

---

*Thank you for helping improve this workshop!*
