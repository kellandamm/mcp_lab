
<div class="module-banner">
  <div class="module-banner-content">
    <div class="module-banner-text">
      <div class="module-banner-label">Module 2</div>
      <h1>Gateway Security</h1>
      <p>Scale security across multiple MCP servers with Azure API Management — a single, hardened gateway for authentication, rate limiting, and content filtering.</p>
    </div>

  </div>
</div>

!!! info "Module Details"
    **Tech Stack:** Python, MCP, Azure API Management, Container Apps, Content Safety, API Center, Entra ID  
    **Primary Risks:** [MCP-02](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp02-privilege-escalation/) (Privilege Escalation), [MCP-06](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp06-prompt-injection/) (Prompt Injection), [MCP-07](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp07-authz/) (Insufficient Auth), [MCP-09](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp09-shadow-servers/) (Shadow Servers)

!!! info "Module 2 at a Glance"
    **Time:** 1 hour (demo) · 2.5 hours (full walkthrough)  
    **Azure Cost:** ~$5–10/day while deployed (adds APIM Developer tier + Content Safety)  
    **Clean up when done:** `azd down --force --purge`  
    **Recommended client:** [GitHub Copilot agent mode](../../copilot-client.md)

In Module 1, you secured a single MCP server with OAuth and Managed Identity. In production environments, you'll often have dozens of MCP servers across business systems, APIs, and data sources — each needing consistent security. Securing them individually means duplicating authentication logic, rate limiting, and monitoring across every server.

**Azure API Management (APIM)** solves this as a centralized MCP gateway: a single, hardened layer where all MCP traffic flows through. Instead of securing each server individually, the gateway validates, rate-limits, and filters every request before it reaches your backends.

This module follows the same **"vulnerable → exploit → fix → validate"** pattern from previous modules, but now at scale with multiple MCP servers and comprehensive gateway controls.

---

## Prerequisites

:material-check: Azure subscription with Contributor access  
:material-check: Azure CLI installed and authenticated  
:material-check: Azure Developer CLI (azd) installed and authenticated  
:material-check: Docker installed and running  
:material-check: Completed Module 1 (recommended for OAuth context)

:material-arrow-right: [Full prerequisites guide](../../prerequisites.md) with installation instructions.

**Verify your setup:**

=== "Bash"
    ```bash
    az account show && azd version && docker --version
    ```

=== "PowerShell"
    ```powershell
    az account show; azd version; docker --version
    ```

---

## Getting Started

```bash
# Clone the repo (skip if you already have it)
git clone https://github.com/kellandamm/mcp_lab.git

# Navigate to Module 2
cd mcp_lab/modules/gateway

# Provision infrastructure (~10-15 minutes)
azd provision
```

!!! tip "Windows Users"
    All scripts in this module have PowerShell equivalents (`.ps1`). When you see `./scripts/X.sh`, you can run `./scripts/X.ps1` instead.

When prompted, choose an environment name (e.g., `module2-dev`), select your Azure subscription, and pick a region (e.g., `westus2`).

???+ note "What happens during provisioning?"
    `azd provision` executes three phases:

    **Phase 1: Pre-Provision Hook** — Creates Entra ID applications for OAuth:

    - **MCP Resource App** — Represents your MCP server resources with scopes
    - **VS Code Pre-authorization** — Allows VS Code to request tokens without admin consent
    - **Service Principal** — Enables Azure RBAC for the MCP app

    **Phase 2: Infrastructure Deployment** — Provisions all Azure resources (~10 minutes):

    | Resource | Purpose |
    |----------|---------|
    | API Management (Basic v2) | MCP gateway (APIs added via waypoint scripts) |
    | Container Apps Environment | Hosts MCP servers and REST APIs |
    | Container Registry | Stores Docker images |
    | Content Safety (S0) | AI-powered prompt injection detection |
    | API Center | API governance and discovery |
    | Log Analytics | Monitoring and diagnostics |
    | 2× Managed Identities | For APIM and Container Apps |
    | 2× Container Apps | Workshop MCP Server and Path API (placeholder images) |

    **Phase 3: Post-Provision Hook** — Reports region adjustments and outputs connection details.

    ??? tip "Region Selection"
        API Center has limited region availability. If your selected region doesn't support API Center, the deployment automatically falls back to `eastus` for that service. All other resources deploy to your selected region.

When provisioning completes, save your deployment info:

=== "Bash"
    ```bash
    azd env get-values | grep -E "APIM_GATEWAY_URL|MCP_APP_CLIENT_ID|AZURE_RESOURCE_GROUP"
    ```

=== "PowerShell"
    ```powershell
    azd env get-values | Select-String "APIM_GATEWAY_URL|MCP_APP_CLIENT_ID|AZURE_RESOURCE_GROUP"
    ```

Ready? Let's start by exposing your MCP server through the gateway.

[Start: Gateway & Authentication →](section1-gateway-governance.md){ .md-button .md-button--primary }

---

← [Module 1: Identity](../module1-identity.md) | [Gateway & Authentication →](section1-gateway-governance.md)
