# Module 5: Supply Chain Security

> **📚 Workshop Guide:** For the full step-by-step workshop, visit: **[Module 5: Supply Chain Security](../../docs/modules/module5-supply-chain.md)**

---

Understand how malicious or compromised packages can bypass every runtime security control you've built. Scan dependencies, generate SBOMs, configure Dependabot, and enforce container scanning — before anything runs.

## Overview

| | |
|---|---|
| **Difficulty** | Intermediate |
| **Prerequisites** | Python 3.10+, uv, GitHub repository (for GHAS/Dependabot) |
| **Tech Stack** | pip-audit, Syft, Dependabot, GitHub Advanced Security, Azure Container Registry |
| **Azure Required** | Optional (for container scanning with Defender for DevOps) |

## What You'll Learn

- Identify supply chain risks in MCP server dependencies
- Simulate a typosquatting attack against an MCP package
- Run `pip-audit` to scan for known vulnerabilities
- Generate a Software Bill of Materials (SBOM) with Syft
- Configure Dependabot for automatic dependency updates
- Enable GitHub Advanced Security (GHAS) for dependency scanning
- Set up container image scanning via GitHub Actions + Trivy
- Implement a verified package policy for MCP server deployments

## OWASP MCP Risks Addressed

| Risk | Description | Module 5 Solution |
|------|-------------|-------------------|
| [MCP-04](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp04-supply-chain/) | Supply Chain Attacks | Dependency scanning, SBOM, verified package policy |
| [MCP-01](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp01-token-mismanagement/) | Token Mismanagement | Secret scanning catches hardcoded tokens |
| [MCP-03](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp03-tool-poisoning/) | Tool Poisoning | Awareness: malicious tool descriptions in packages |

## Quick Start

```bash
cd modules/module5-supply-chain
uv sync

# Run a dependency scan
uv run pip-audit
```

Then follow the **[Workshop Guide](../../docs/modules/module5-supply-chain.md)** for the full exploit → fix → validate walkthrough.

## Project Structure

```
module5-supply-chain/
├── vulnerable-setup/      # Simulated supply chain risk scenario
│   └── README.md
├── secure-setup/          # Fixed, verified, scanned setup
│   └── README.md
└── pyproject.toml
```

## ⚠️ Educational Purpose

The `vulnerable-setup/` scenario illustrates what a malicious package scenario looks like. It does **not** include actual malicious code — only the patterns and indicators you should look for when auditing dependencies.

## Next Steps

- **[Summary](../summit/)** — OWASP coverage overview and production readiness checklist
