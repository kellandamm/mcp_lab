# Waypoint 1.2: Enable I/O Security in APIM
#
# Applies Layer 2 security (Azure Functions) while preserving Layer 1
#
# Policy Architecture:
#   Workshop-mcp: Full I/O security (input + output in MCP policy)
#   Path-mcp:  Input security only (output sanitization on Path-api)
#   Path-api:  Output sanitization (catches responses before SSE wrapping)
#
# This split is needed because synthesized MCP servers (Path-mcp) have
# SSE streams controlled by APIM that block outbound Body.As<string>() calls.
# Real MCP servers (Workshop-mcp) work fine with outbound policies.

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location (Join-Path $ScriptDir "..")

Write-Host ""
Write-Host "=========================================="
Write-Host "Waypoint 1.2: Enable I/O Security"
Write-Host "=========================================="
Write-Host ""

$APIM_NAME = azd env get-value APIM_NAME
$RG_NAME = azd env get-value AZURE_RESOURCE_GROUP
$FUNCTION_APP_URL = azd env get-value FUNCTION_APP_URL
$SUBSCRIPTION_ID = az account show --query id -o tsv

Write-Host "APIM: $APIM_NAME"
Write-Host "Resource Group: $RG_NAME"
Write-Host "Function URL: $FUNCTION_APP_URL"
Write-Host ""

# ============================================
# Step 1: Add Function URL as Named Value
# ============================================
Write-Host "Step 1: Add Function URL as Named Value"
Write-Host "----------------------------------------"

az apim nv create `
    --resource-group $RG_NAME `
    --service-name $APIM_NAME `
    --named-value-id "function-app-url" `
    --display-name "function-app-url" `
    --value $FUNCTION_APP_URL `
    2>$null

if ($LASTEXITCODE -ne 0) {
    az apim nv update `
        --resource-group $RG_NAME `
        --service-name $APIM_NAME `
        --named-value-id "function-app-url" `
        --value $FUNCTION_APP_URL `
        --output none
}

Write-Host "✓ Named value 'function-app-url' configured"
Write-Host ""

# ============================================
# Step 2: Get OAuth Configuration
# ============================================
Write-Host "Step 2: Get OAuth Configuration"
Write-Host "--------------------------------"

$TENANT_ID = azd env get-value AZURE_TENANT_ID 2>$null
if (-not $TENANT_ID) {
    $TENANT_ID = az account show --query tenantId -o tsv
}
$MCP_APP_CLIENT_ID = azd env get-value MCP_APP_CLIENT_ID 2>$null
$APIM_GATEWAY_URL = azd env get-value APIM_GATEWAY_URL

if (-not $MCP_APP_CLIENT_ID) {
    Write-Host "Warning: MCP_APP_CLIENT_ID not set."
    Write-Host "OAuth validation will use placeholder. Run register-entra-app.ps1 to configure."
    $MCP_APP_CLIENT_ID = "00000000-0000-0000-0000-000000000000"
}

Write-Host "Tenant ID: $TENANT_ID"
Write-Host "MCP App Client ID: $MCP_APP_CLIENT_ID"
Write-Host "APIM Gateway URL: $APIM_GATEWAY_URL"
Write-Host ""

# ============================================
# Step 3: Update Workshop MCP Server Policy
# ============================================
Write-Host "Step 3: Update Workshop MCP Server Policy"
Write-Host "----------------------------------------"
Write-Host "Policy: Full I/O Security (OAuth + Content Safety + Input Check + Output Sanitization)"
Write-Host ""

# Prepare Workshop MCP policy (full I/O security - works because backend controls stream)
$Workshop_POLICY_XML = (Get-Content -Path "infra/policies/Workshop-mcp-full-io-security.xml" -Raw) `
    -replace '{{tenant-id}}', $TENANT_ID `
    -replace '{{mcp-app-client-id}}', $MCP_APP_CLIENT_ID `
    -replace '{{apim-gateway-url}}', $APIM_GATEWAY_URL

$WorkshopPolicyBody = @{
    properties = @{
        format = "rawxml"
        value = $Workshop_POLICY_XML
    }
} | ConvertTo-Json -Depth 5

$WorkshopPolicyFile = Join-Path $env:TEMP "Workshop-mcp-policy.json"
$WorkshopPolicyBody | Set-Content -Path $WorkshopPolicyFile -Encoding UTF8

Write-Host "Applying full I/O security policy to Workshop MCP Server..."
$result = az rest --method PUT `
    --uri "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_NAME/providers/Microsoft.ApiManagement/service/$APIM_NAME/apis/Workshop-mcp/policies/policy?api-version=2024-06-01-preview" `
    --body "@$WorkshopPolicyFile" `
    --output none 2>$null

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Workshop MCP policy updated!"
} else {
    Write-Host "✗ Failed to update Workshop MCP policy"
    Write-Host "  Make sure Workshop-mcp API exists (run azd provision first)"
}
Write-Host ""

# ============================================
# Step 4: Update Path MCP Server Policy
# ============================================
Write-Host "Step 4: Update Path MCP Server Policy"
Write-Host "---------------------------------------"
Write-Host "Policy: Input Security Only (OAuth + Content Safety + Input Check)"
Write-Host "Note: Output sanitization applied to Path-api instead (see Step 5)"
Write-Host ""

# Prepare Path MCP policy (input only - outbound blocks on synthesized MCP)
$Path_MCP_POLICY_XML = (Get-Content -Path "infra/policies/Path-mcp-input-security.xml" -Raw) `
    -replace '{{tenant-id}}', $TENANT_ID `
    -replace '{{mcp-app-client-id}}', $MCP_APP_CLIENT_ID `
    -replace '{{apim-gateway-url}}', $APIM_GATEWAY_URL

$PathMcpPolicyBody = @{
    properties = @{
        format = "rawxml"
        value = $Path_MCP_POLICY_XML
    }
} | ConvertTo-Json -Depth 5

$PathMcpPolicyFile = Join-Path $env:TEMP "Path-mcp-policy.json"
$PathMcpPolicyBody | Set-Content -Path $PathMcpPolicyFile -Encoding UTF8

Write-Host "Applying input security policy to Path MCP Server..."
$result = az rest --method PUT `
    --uri "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_NAME/providers/Microsoft.ApiManagement/service/$APIM_NAME/apis/Path-mcp/policies/policy?api-version=2024-06-01-preview" `
    --body "@$PathMcpPolicyFile" `
    --output none 2>$null

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Path MCP policy updated!"
} else {
    Write-Host "✗ Failed to update Path MCP policy"
    Write-Host "  Make sure Path-mcp API exists (run azd provision first)"
}
Write-Host ""

# ============================================
# Step 5: Update Path REST API Policy
# ============================================
Write-Host "Step 5: Update Path REST API Policy"
Write-Host "-------------------------------------"
Write-Host "Policy: Output Sanitization (PII redaction before SSE wrapping)"
Write-Host ""

# Prepare Path API policy (output sanitization - runs before APIM wraps response in SSE)
$Path_API_POLICY_XML = Get-Content -Path "infra/policies/Path-api-output-sanitization.xml" -Raw

$PathApiPolicyBody = @{
    properties = @{
        format = "rawxml"
        value = $Path_API_POLICY_XML
    }
} | ConvertTo-Json -Depth 5

$PathApiPolicyFile = Join-Path $env:TEMP "Path-api-policy.json"
$PathApiPolicyBody | Set-Content -Path $PathApiPolicyFile -Encoding UTF8

Write-Host "Applying output sanitization policy to Path REST API..."
$result = az rest --method PUT `
    --uri "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_NAME/providers/Microsoft.ApiManagement/service/$APIM_NAME/apis/Path-api/policies/policy?api-version=2024-06-01-preview" `
    --body "@$PathApiPolicyFile" `
    --output none 2>$null

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Path API policy updated!"
} else {
    Write-Host "✗ Failed to update Path API policy"
    Write-Host "  Make sure Path-api API exists (run azd provision first)"
}

# Cleanup
Remove-Item -Path $WorkshopPolicyFile, $PathMcpPolicyFile, $PathApiPolicyFile -Force -ErrorAction SilentlyContinue

Write-Host ""

# ============================================
# Step 6: Enable Server-Side Sanitization
# ============================================
Write-Host "Step 6: Enable Server-Side Sanitization for Workshop MCP"
Write-Host "-------------------------------------------------------"
Write-Host "Setting SANITIZE_ENABLED=true and SANITIZE_FUNCTION_URL on Workshop-mcp-server Container App..."
Write-Host ""

az containerapp update `
    --name Workshop-mcp-server `
    --resource-group $RG_NAME `
    --set-env-vars "SANITIZE_ENABLED=true" "SANITIZE_FUNCTION_URL=$FUNCTION_APP_URL/api/sanitize-output" `
    --output none 2>$null

# Wait for new revision to be ready
Write-Host "Waiting for new revision to deploy..."

for ($i = 1; $i -le 30; $i++) {
    # Check if the env var is set in the active revision
    $SANITIZE_VALUE = az containerapp show `
        --name Workshop-mcp-server `
        --resource-group $RG_NAME `
        --query "properties.template.containers[0].env[?name=='SANITIZE_ENABLED'].value | [0]" -o tsv 2>$null

    if ($SANITIZE_VALUE -eq "true") {
        # Verify the revision is actually running
        $REVISION_STATUS = az containerapp revision list `
            --name Workshop-mcp-server `
            --resource-group $RG_NAME `
            --query "[?properties.active].properties.runningState | [0]" -o tsv 2>$null

        if ($REVISION_STATUS -like "Running*") {
            Write-Host "✓ Workshop MCP Server updated with SANITIZE_ENABLED=true"
            break
        }
    }

    if ($i -eq 30) {
        Write-Host "⚠ Warning: Timeout waiting for deployment. The revision may still be provisioning."
        Write-Host "  Wait a moment before running validation scripts."
    } else {
        Write-Host "  Waiting for deployment... ($i/30)"
        Start-Sleep -Seconds 3
    }
}

Write-Host ""
Write-Host "=========================================="
Write-Host "I/O Security Enabled!"
Write-Host "=========================================="
Write-Host ""
Write-Host "Security Architecture:"
Write-Host ""
Write-Host "  ┌─────────────────┐     ┌─────────────────┐"
Write-Host "  │   Workshop-mcp    │     │   Path-mcp     │"
Write-Host "  │ (real MCP proxy)│     │ (synthesized)   │"
Write-Host "  │                 │     │                 │"
Write-Host "  │  • OAuth        │     │  • OAuth        │"
Write-Host "  │  • ContentSafety│     │  • ContentSafety│"
Write-Host "  │  • Input Check  │     │  • Input Check  │"
Write-Host "  │  • Output Sanit.│     │  (no outbound)  │"
Write-Host "  │   (server-side) │     │                 │"
Write-Host "  └────────┬────────┘     └────────┬────────┘"
Write-Host "           │                       │"
Write-Host "           │              ┌────────┴────────┐"
Write-Host "           │              │   Path-api     │"
Write-Host "           │              │  • Output Sanit.│"
Write-Host "           │              │   (APIM policy) │"
Write-Host "           │              └────────┬────────┘"
Write-Host "           ▼                       ▼"
Write-Host "     Container App          Container App"
Write-Host ""
Write-Host "Next: Validate that security is working"
Write-Host "  ./scripts/1.3-validate-injection.ps1"
Write-Host "  ./scripts/1.3-validate-pii.ps1"
Write-Host ""
