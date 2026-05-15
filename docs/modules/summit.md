---
hide:
  - toc
---

<div class="module-banner">
  <div class="module-banner-content">
    <div class="module-banner-text">
      <div class="module-banner-label">Summary</div>
      <h1>Workshop Complete</h1>
      <p>You've seen what MCP can do — and exactly why every layer needs to be locked down. Here's what you covered and where to go next.</p>
    </div>
    <div class="module-banner-image">
      <img src="../../images/Workshop-mcp-workshop-sm.png" alt="Workshop Complete" />
    </div>
  </div>
</div>

## What You Covered

Each module demonstrated a real MCP capability, then showed what happens when that capability goes unsecured — and how to fix it.

| Module | MCP Capability | Security Layer Applied |
|--------|---------------|----------------------|
| **Module 0: Foundations** | Exposing tools, resources, and user data over MCP | Bearer token auth · Authorization checks |
| **Module 1: Identity** | Cloud-deployed MCP servers accessed by AI clients | OAuth 2.1 · Managed Identity · Key Vault |
| **Module 2: Gateway** | Routing multiple MCP servers through a single entry point | APIM gateway · Private Endpoints · API governance |
| **Module 3: I/O Security** | Natural language driving backend logic and returning sensitive data | Prompt injection defense · PII detection · Content Safety |
| **Module 4: Monitoring** | Full AI tool usage across your infrastructure | Log Analytics · Dashboards · Automated alerting |
| **Module 5: Supply Chain** | MCP server packages, dependencies, and container images | pip-audit · SBOM (Syft) · Dependabot · GHAS |

---

## OWASP MCP Top 10 Coverage

This workshop maps directly to the [OWASP MCP Azure Security Guide](https://microsoft.github.io/mcp-azure-security-guide/).

| Risk | Name | Covered In |
|:----:|------|:----------:|
| **[MCP01](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp01-token-mismanagement/)** | Token Mismanagement & Secret Exposure | Module 0 · Module 1 |
| **[MCP02](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp02-privilege-escalation/)** | Privilege Escalation via Scope Creep | Module 0 · Module 1 · Module 2 |
| **[MCP03](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp03-tool-poisoning/)** | Tool Poisoning | Module 3 |
| **[MCP04](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp04-supply-chain/)** | Supply Chain Attacks | Module 5 |
| **[MCP05](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp05-command-injection/)** | Command Injection & Execution | Module 3 |
| **[MCP06](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp06-prompt-injection/)** | Prompt Injection via Contextual Payloads | Module 2 · Module 3 |
| **[MCP07](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp07-authz/)** | Insufficient Authentication & Authorization | Module 0 · Module 1 · Module 2 |
| **[MCP08](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp08-telemetry/)** | Lack of Audit and Telemetry | Module 4 |
| **[MCP09](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp09-shadow-servers/)** | Shadow MCP Servers | Module 2 |
| **[MCP10](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp10-context-oversharing/)** | Context Injection & Over-Sharing | Module 3 |

---

## Production Readiness Checklist

Before deploying an MCP server to production, verify each layer is in place:

### Identity & Access
- [ ] OAuth 2.1 with short-lived JWTs (not static tokens)
- [ ] Azure Managed Identity for all Azure resource access (no stored credentials)
- [ ] Secrets stored in Azure Key Vault with RBAC — not environment variables
- [ ] Least-privilege roles assigned to each service identity

### Gateway & Network
- [ ] All MCP traffic routed through API Management
- [ ] Private Endpoints enabled — no public exposure of backend servers
- [ ] Rate limiting and throttling policies configured
- [ ] MCP servers registered in API Center for governance and discovery

### I/O Security
- [ ] Azure AI Content Safety screening requests and responses
- [ ] Technical injection detection (shell, SQL, path traversal) via Azure Functions
- [ ] PII detection and redaction on all outbound responses
- [ ] Tool descriptions reviewed for prompt injection vectors (MCP03)

### Observability
- [ ] All gateway requests logged to Log Analytics
- [ ] Application Insights connected to backend services
- [ ] Security event dashboard configured
- [ ] Automated alerts on injection attempts, auth failures, and anomalies
- [ ] Log retention policy set per compliance requirements

### Supply Chain
- [ ] All MCP server dependencies scanned with `pip-audit` or `npm audit`
- [ ] Dependencies pinned with hashes in lockfile (`uv pip compile --generate-hashes`)
- [ ] Software Bill of Materials (SBOM) generated and stored with each deployment
- [ ] Dependabot enabled for all `pyproject.toml` / `package.json` files in the repo
- [ ] GitHub Advanced Security enabled: dependency graph, Dependabot alerts, secret scanning
- [ ] Container images scanned (Trivy or Defender for DevOps) before pushing to ACR
- [ ] Tool descriptions reviewed — no embedded instructions or prompt injection patterns

---

## Azure Cost Summary

> 💡 All Azure modules deploy real infrastructure. **Remember to tear down after each session** — costs add up quickly if left running.

| Module | Resources Deployed | Est. Cost/Day |
|--------|-------------------|:-------------:|
| **Module 0** | None (local) | Free |
| **Module 1** | Container Apps, Key Vault, Container Registry | ~$2–5 |
| **Module 2** | + APIM Developer, Content Safety | ~$5–10 |
| **Module 3** | + Azure Functions, AI Language | ~$8–15 |
| **Module 4** | + Log Analytics, App Insights | ~$10–20 |

**Tear down any module:**
```bash
cd modules/<module-directory>
azd down --force --purge
```

**Tear down everything at once:**
```bash
# List all azd environments
azd env list

# Remove each environment
azd down --force --purge --environment <env-name>
```

---

## Key Takeaways

!!! tip "The Core Lesson"
    MCP is a powerful capability multiplier for AI — it's also a direct line into your backend systems. Every tool you expose is a potential attack surface. Security isn't optional; it's the price of connecting AI to anything that matters.

- **Authentication alone isn't enough.** You need identity (Module 1), a secure front door (Module 2), safe I/O (Module 3), and the ability to see what's happening (Module 4).
- **The exploit-first approach works.** Seeing an attack succeed makes the fix meaningful. Abstract security advice is easy to ignore; a live data exfiltration demo is not.
- **Azure-native services handle the hard parts.** Entra ID, APIM, Content Safety, and Log Analytics are production-grade — not workshop toys.

---

## What's Next

- **[OWASP MCP Azure Security Guide](https://microsoft.github.io/mcp-azure-security-guide/)** — deeper dives on every risk covered here
- **[MCP Specification](https://modelcontextprotocol.io/specification/2025-11-25)** — understand the protocol itself
- **[FastMCP Framework](https://github.com/jlowin/fastmcp)** — the Python framework used throughout this workshop
- **[Azure AI Foundry](https://learn.microsoft.com/azure/ai-foundry/)** — build and deploy production AI applications on Azure
- **[Contribute to this workshop](../resources/contributing.md)** — add new modules, improve existing content, or share feedback

---

← [Module 5: Supply Chain](module5-supply-chain.md)
