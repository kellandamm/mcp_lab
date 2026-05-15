# Waypoint 1.1: Deploy Workshop MCP Server
$ErrorActionPreference = 'Stop'

Set-Location (Join-Path $PSScriptRoot "..")

Write-Host ""
Write-Host "=========================================="
Write-Host "Waypoint 1.1: Deploy Workshop MCP Server"
Write-Host "=========================================="
Write-Host ""

# Deploy the container service
Write-Host "Building and deploying Workshop MCP Server..."
azd deploy Workshop-mcp-server

# Get environment values
$RG = azd env get-value AZURE_RESOURCE_GROUP
$APIM_NAME = azd env get-value APIM_NAME
$Workshop_URL = azd env get-value Workshop_SERVER_URL

Write-Host ""
Write-Host "Configuring APIM backend and API..."

# Deploy APIM configuration via Bicep
az deployment group create `
  --resource-group $RG `
  --template-file infra/waypoints/1.1-deploy-Workshop.bicep `
  --parameters apimName=$APIM_NAME `
               backendUrl="$Workshop_URL/mcp" `
  --output none

$APIM_URL = azd env get-value APIM_GATEWAY_URL

Write-Host ""
Write-Host "=========================================="
Write-Host "Workshop MCP Server Deployed"
Write-Host "=========================================="
Write-Host ""
Write-Host "Endpoint: $APIM_URL/Workshop/mcp"
Write-Host ""
Write-Host "Current security: NONE (completely open)"
Write-Host ""
Write-Host "Next: Test the vulnerability from VS Code"
Write-Host "  1. Add the endpoint to .vscode/mcp.json"
Write-Host "  2. Connect without any authentication"
Write-Host "  3. Then run: ./scripts/1.1-fix.ps1"
Write-Host ""
