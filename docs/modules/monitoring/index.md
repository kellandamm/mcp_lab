---
hide:
  - toc
---

<div class="module-banner">
  <div class="module-banner-content">
    <div class="module-banner-text">
      <div class="module-banner-label">Module 4</div>
      <h1>Monitoring & Telemetry</h1>
      <p>Prove your defenses work with Log Analytics, Application Insights, dashboards, and automated alerting — because security without observability is blind.</p>
    </div>
    <div class="module-banner-image">
      <img src="../../images/Workshop-monitoring-sm.png" alt="Module 4: Monitoring" />
    </div>
  </div>
</div>

!!! info "Module Details"
    **Tech Stack:** Log Analytics, Application Insights, Azure Monitor, Workbooks, API Management, Container Apps, Functions, MCP  
    **Primary Risks:** [MCP08](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp08-telemetry/) (Lack of Audit and Telemetry)

!!! info "Module 4 at a Glance"
    ⏱️ **Time:** 45 min (demo) · 2 hours (full walkthrough)  
    💰 **Azure Cost:** ~$10–20/day while deployed (adds Log Analytics + App Insights)  
    🗑️ **Clean up when done:** `azd down --force --purge`  
    👉 **Recommended client:** [GitHub Copilot agent mode](../../copilot-client.md)

### Welcome to Module 4!

You've reached the final workshop module. Throughout the previous modules, you've locked down authentication, put a gateway in front of your MCP servers, and added input validation and output sanitization. Your servers are now protected by multiple layers of defense.

But here's a question: **How do you know it's working?**

If an attacker probed your system last night, would you know? If your security function blocked 100 injection attempts yesterday, could you prove it to an auditor? If there's a sudden spike in attacks right now, would you be alerted?

This is where **observability** comes in, and it's just as important as the security controls themselves.

!!! quote "The Key Insight"
    Security controls without observability are like locks without security cameras. You might stop the intruder, but you'll never know they tried to get in.

---

## What You'll Build

By the end of Module 4, every request will be logged, visualized, and alertable. Here's the complete architecture:

```
┌─────────────────────────────────────────────────────────────────┐
│                         MCP Client                              │
└───────────────────────────────┬─────────────────────────────────┘
                                │ HTTPS Request
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                     API Management (APIM)                       │
│                                                                 │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │ LAYER 1: Prompt Shields (AI Content Safety)             │   │
│   │   • Scans for prompt injection attacks                  │   │
│   │   • Blocks jailbreak/manipulation attempts              │   │
│   │   • Logs via <trace> policy → AppTraces                 │   │
│   │     └── Properties.event_type (direct)                  │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│   • Receives all MCP traffic                                    │
│   • Applies policies (auth, rate limiting)                      │
│   • Generates CorrelationId for tracing                         │
│   • Routes clean requests to security function                  │
│                                                                 │
│   Diagnostic Settings → Log Analytics                           │
│   └── GatewayLogs (HTTP details)                                │
│   └── GatewayLlmLogs (LLM usage)                                │
│   └── WebSocketConnectionLogs (WebSocket events)                │
└───────────────────────────────┬─────────────────────────────────┘
                                │ (if not blocked by Layer 1)
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Security Function (Layer 2)                  │
│   • Receives forwarded request + CorrelationId                  │
│   • Regex checks for SQL, path traversal, shell injection       │
│   • Scans for PII/credentials in responses                      │
│   • Logs structured events with custom dimensions               │
│                                                                 │
│   Application Insights SDK → AppTraces table                    │
│   └── Properties.custom_dimensions.event_type                   │
│   └── Properties.custom_dimensions.injection_type               │
│   └── Properties.custom_dimensions.correlation_id               │
└─────────────────────────────────────────────────────────────────┘
```

You'll wire up structured logging, build a security dashboard with Azure Workbooks, create alert rules that fire when attacks spike, and learn KQL to investigate incidents across services.

---

## Prerequisites

Before starting Module 4, ensure you have:

:material-check: Azure subscription with Contributor access  
:material-check: Azure CLI installed and logged in (`az login`)  
:material-check: Azure Developer CLI installed (`azd auth login`)  
:material-check: Docker installed and running (for Container Apps deployment)  
:material-check: Completed Module 3: I/O Security (recommended, but not required)

:material-arrow-right: [Full prerequisites guide](../../prerequisites.md) with installation instructions for all tools.

---

## Getting Started

```bash
# Navigate to Module 4
cd modules/monitoring

# Deploy infrastructure AND services (~15 minutes)
azd up
```

This deploys an APIM gateway, security functions (v1 with basic logging, v2 with structured logging), a Log Analytics workspace, Application Insights, and the MCP server and Path API on Container Apps.

!!! tip "Windows Users"
    All scripts in this module have PowerShell equivalents (`.ps1`). When you see `./scripts/X.sh`, you can run `./scripts/X.ps1` instead.

!!! tip "Just want the full solution?"
    Skip the workshop and deploy everything at once — dashboards, alerts, and structured logging included. See [Production Deployment](production-deploy.md).

Once deployment completes, you're ready to start the workshop. Module 4 follows the **hidden → visible → actionable** pattern — you'll explore what's already logging, make hidden events visible, then turn that visibility into dashboards and alerts.

Ready? Let's start by exploring what API Management is already logging.

[Start: Gateway Logging →](section1-apim-logging.md){ .md-button .md-button--primary }

---

← [Module 3: I/O Security](../io-security/index.md) | [Summary →](../summit.md)
