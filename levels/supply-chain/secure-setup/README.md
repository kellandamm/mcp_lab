# Secure Setup: Verified, Scanned MCP Dependencies

This directory represents the fixed state: every dependency is pinned, audited, and verified before the MCP server runs.

---

## Defense Layers

### Layer 1: Pin Dependencies with Hash Verification

Use `uv` or `pip-compile` to generate a lockfile with cryptographic hashes:

```bash
# Generate a locked requirements file
uv pip compile pyproject.toml -o requirements.lock

# Install only from the lockfile (hash verification enforced)
uv pip sync requirements.lock --require-hashes
```

A tampered package will have a different hash — installation fails before any code runs.

### Layer 2: Scan for Known Vulnerabilities

```bash
# Install pip-audit
uv pip install pip-audit

# Scan all dependencies in the current environment
uv run pip-audit

# Scan a specific requirements file
pip-audit -r requirements.lock

# Output as JSON for CI integration
pip-audit -r requirements.lock -f json -o audit-results.json
```

`pip-audit` queries the Python Packaging Advisory Database (PyPA) and OSV for known CVEs across all installed packages.

### Layer 3: Generate a Software Bill of Materials (SBOM)

```bash
# Install Syft (once)
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

# Generate SPDX SBOM for this module's directory
syft dir:. -o spdx-json > sbom.json

# Generate CycloneDX SBOM (alternative format)
syft dir:. -o cyclonedx-json > sbom-cyclonedx.json
```

Store the SBOM alongside your deployment artifacts. Use it to answer "what's running?" after an incident.

### Layer 4: Verify MCP Tool Descriptions

Before adding an MCP server to `.vscode/mcp.json` or deploying it, review every tool description for unexpected instructions:

```bash
# Connect with MCP Inspector and list tools
npx @modelcontextprotocol/inspector stdio -- uv run python server.py

# Or parse the server's tool list programmatically
uv run python -c "
import asyncio
from fastmcp import Client

async def audit_tools():
    async with Client('path/to/server.py') as client:
        tools = await client.list_tools()
        for tool in tools:
            print(f'--- {tool.name} ---')
            print(tool.description)
            print()

asyncio.run(audit_tools())
"
```

Red flags in a tool description:
- Instructions directing the AI to send data to an external URL
- Phrases like "IMPORTANT:", "SYSTEM:", "Before returning" that add imperative directives
- Base64-encoded content embedded in the description
- References to other tools or system prompts

### Layer 5: Automated CI Checks

Add to your GitHub Actions workflow:

```yaml
- name: Audit Python dependencies
  run: |
    pip install pip-audit
    pip-audit -r requirements.lock --fail-on-vuln

- name: Generate SBOM
  uses: anchore/sbom-action@v0
  with:
    path: .
    format: spdx-json
    output-file: sbom.json

- name: Upload SBOM artifact
  uses: actions/upload-artifact@v4
  with:
    name: sbom
    path: sbom.json
```

---

## Verified Package Policy

Before approving any MCP server dependency for use in this workshop or in production:

- [ ] Package is published by a known, consistent author or organization
- [ ] Package name matches exactly — no dashes/numbers substituted
- [ ] First publication date is not recent/suspicious relative to the legitimate package
- [ ] `pip-audit` shows zero critical vulnerabilities
- [ ] Tool descriptions contain no embedded instructions or directives
- [ ] SBOM has been generated and stored with the deployment artifact
- [ ] Dependencies are pinned with hashes in the lockfile

---

## Next Steps

Return to the **[Workshop Guide](../../../docs/modules/module5-supply-chain.md)** to configure Dependabot and GitHub Advanced Security for ongoing protection.
