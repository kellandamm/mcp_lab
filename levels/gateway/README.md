# Module 2: Gateway Security

> **📚 Workshop Guide:** For the full step-by-step workshop, visit: **[Module 2: Gateway Security](https://azure-samples.github.io/Workshop/modules/gateway/)**

---

Establish enterprise-grade API gateway security for MCP servers using Azure API Management, implementing centralized OAuth 2.0 with PRM discovery, rate limiting, and AI content safety filtering.

## Overview

| | |
|---|---|
| **Difficulty** | Advanced |
| **Prerequisites** | Azure subscription, Module 1 recommended |
| **Tech Stack** | Python, MCP, Azure API Management, Content Safety, API Center |

## What You'll Learn

- Deploy Azure API Management as an MCP gateway
- Implement OAuth 2.0 with PRM (RFC 9728) for automatic discovery
- Configure rate limiting and throttling for MCP servers
- Add AI content safety filtering with Azure AI Content Safety
- Establish API governance with Azure API Center

## OWASP MCP Risks Addressed

| Risk | Description | Module 2 Solution |
|------|-------------|-----------------|
| [MCP-07](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp07-authz/) | Insufficient Auth | OAuth + PRM at gateway |
| [MCP-02](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp02-privilege-escalation/) | Privilege Escalation | Rate limiting |
| [MCP-06](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp06-prompt-injection/) | Prompt Injection | Content Safety filtering |
| [MCP-09](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp09-shadow-servers/) | Shadow MCP Servers | API Center governance |
| [MCP-04](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp04-tool-invocation/) | Tool Invocation | IP restrictions on backends |

## Quick Start

```bash
cd modules/gateway
azd up
```

Then follow the **[Workshop Guide](https://azure-samples.github.io/Workshop/modules/gateway/)** for the exploit → fix → validate walkthrough.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Azure APIM Gateway                       │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ • OAuth Validation (Entra ID)                          │ │
│  │ • Rate Limiting (by session)                           │ │
│  │ • AI Content Safety Filtering                          │ │
│  └────────────────────────────────────────────────────────┘ │
└──────────────────────────┬──────────────────────────────────┘
                           │
            ┌──────────────┴──────────────┐
            ▼                             ▼
   ┌─────────────────┐          ┌─────────────────┐
   │  Workshop MCP     │          │   Path API     │
   │  (Native MCP)   │          │  (REST → MCP)   │
   └─────────────────┘          └─────────────────┘
```

## Project Structure

```
modules/gateway/
├── azure.yaml                 # azd configuration
├── infra/                     # Bicep infrastructure
│   ├── main.bicep
│   ├── modules/
│   ├── policies/              # APIM policy XML files
│   └── waypoints/             # Per-waypoint Bicep files
├── servers/
│   ├── Workshop-mcp-server/     # Native MCP server
│   └── Path-api/             # REST API backend
└── scripts/                   # Workshop scripts
```

## Cleanup

```bash
azd down --force --purge
```

## Next Steps

- **[Module 3: I/O Security](../io-security/)** - Add input validation and output sanitization
