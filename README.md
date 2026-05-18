# The MCP Security Workshop

*A Workshop's Guide to Securing Model Context Protocol Servers in Azure*

**🚀 [Start the Workshop →](docs/index.md)**

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/kellandamm/mcp_lab)


## Overview

This workshop shows you what Model Context Protocol (MCP) enables — and exactly why each capability must be secured. Through hands-on exploitation and remediation, you'll see real attacks succeed against unprotected MCP servers, then apply Azure-native security controls to stop them.

MCP is an open protocol that lets AI applications connect to external tools and data sources. It's becoming the standard way to extend AI capabilities — which makes every exposed MCP server a potential attack surface. This workshop teaches you practical, hands-on security techniques you can apply immediately.

**Aligned with:** MCP Specification 2025-11-25 | OWASP MCP Top 10

## Workshop Modules

Each module demonstrates a real MCP capability, exploits it without security, then applies the fix.

| Module | MCP Capability | Security Focus |
|:------:|:-------------:|:--------------:|
| **Module 0: Foundations** | Exposing tools, resources, and user data | MCP fundamentals, basic authentication |
| **Module 1** | Cloud-deployed AI tools connecting to Azure resources | OAuth, Managed Identity, Key Vault |
| **Module 2** | Enterprise AI gateway routing multiple MCP servers | API/MCP Gateway, Private Endpoints, API Center |
| **Module 3** | Natural language driving backend logic | Content Safety, Input Validation, PII Detection |
| **Module 4** | Full observability of AI tool usage | Logging, Monitoring, Threat Detection |
| **Summary** | OWASP coverage summary + production checklist | — |

## Reference Guide

Comprehensive security guidance is available at:  
**[microsoft.github.io/mcp-azure-security-guide](https://microsoft.github.io/mcp-azure-security-guide/)**

Throughout the workshop, we reference specific sections for deeper dives on each OWASP MCP Top 10 risk.

## Prerequisites

- **Azure subscription** with Contributor access
- **VS Code** with GitHub Copilot or MCP extension
- **Azure CLI** installed and authenticated
- **Python 3.10+** installed
- **node.js 22>** installed
- Basic familiarity with Azure Portal
- No prior MCP or security expertise required

## Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/kellandamm/mcp_lab.git
   cd mcp_lab
   ```

2. **Start at Module 0:**
   ```bash
   cd modules/base-module
   ```

3. **Follow the guide:**  
   Visit the **[Workshop Guide](docs/index.md)** for step-by-step instructions following our proven "Deploy → Exploit → Fix → Validate" pattern.

## Workshop Methodology

Each module follows the same proven pattern:

1. **Show the Capability** — Understand what MCP enables in this context
2. **Deploy Vulnerable System** — Experience the risk firsthand
3. **Exploit the Vulnerability** — Use VS Code MCP client to demonstrate attacks
4. **Implement Security Fixes** — Apply Azure-native security controls
5. **Validate** — Re-attempt exploits to confirm protection

## OWASP MCP Top 10 Coverage

| Risk | Name | module |
|:----:|------|:----:|
| **[MCP01](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp01-token-mismanagement/)** | Token Mismanagement & Secret Exposure | Module 0, Module 1 |
| **[MCP02](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp02-privilege-escalation/)** | Privilege Escalation via Scope Creep | Module 1, Module 2 |
| **[MCP03](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp03-tool-poisoning/)** | Tool Poisoning | Module 3 |
| **[MCP04](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp04-supply-chain/)** | Supply Chain Attacks | Awareness |
| **[MCP05](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp05-command-injection/)** | Command Injection & Execution | Module 3 |
| **[MCP06](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp06-prompt-injection/)** | Prompt Injection via Contextual Payloads | Module 2, Module 3 |
| **[MCP07](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp07-authz/)** | Insufficient Authentication & Authorization | Module 0, Module 1, Module 2 |
| **[MCP08](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp08-telemetry/)** | Lack of Audit and Telemetry | Module 4 |
| **[MCP09](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp09-shadow-servers/)** | Shadow MCP Servers | Module 2 |
| **[MCP10](https://microsoft.github.io/mcp-azure-security-guide/mcp/mcp10-context-oversharing/)** | Context Injection & Over-Sharing | Module 3 |

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to add new modules or improve existing content.

## Resources

- **OWASP MCP Azure Guide:** [microsoft.github.io/mcp-azure-security-guide](https://microsoft.github.io/mcp-azure-security-guide/)
- **MCP Specification:** [modelcontextprotocol.io/specification/2025-11-25](https://modelcontextprotocol.io/specification/2025-11-25)
- **Security Best Practices:** [modelcontextprotocol.io/.../security_best_practices](https://modelcontextprotocol.io/.../basic/security_best_practices)
- **Azure API Management:** [learn.microsoft.com/azure/api-management](https://learn.microsoft.com/azure/api-management/)
- **Azure API Center:** [learn.microsoft.com/azure/api-center](https://learn.microsoft.com/azure/api-center/)
- **Azure Key Vault:** [learn.microsoft.com/azure/key-vault](https://learn.microsoft.com/azure/key-vault/)
- **Azure Managed Identity:** [learn.microsoft.com/entra/identity/managed-identities-azure-resources](https://learn.microsoft.com/entra/identity/managed-identities-azure-resources/)
- **Microsoft Foundry:** [learn.microsoft.com/azure/ai-foundry/what-is-azure-ai-foundry](https://learn.microsoft.com/azure/ai-foundry/what-is-azure-ai-foundry?view=foundry)
- **Azure AI Content Safety:** [learn.microsoft.com/azure/ai-services/content-safety](https://learn.microsoft.com/azure/ai-services/content-safety/)

---

**MCP is a capability multiplier for AI. Every tool you expose is a potential attack surface. This workshop makes sure that's never a surprise. 🔒**
