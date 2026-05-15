# Waypoint 1.2: Deploy Path API
$ErrorActionPreference = 'Stop'

Set-Location (Join-Path $PSScriptRoot "..")

Write-Host ""
Write-Host "=========================================="
Write-Host "Waypoint 1.2: Deploy Path API"
Write-Host "=========================================="
Write-Host ""

# Deploy the container service
Write-Host "Building and deploying Path API..."
azd deploy Path-api

# Get environment values
$RG = azd env get-value AZURE_RESOURCE_GROUP
$APIM_NAME = azd env get-value APIM_NAME
$APIM_URL = azd env get-value APIM_GATEWAY_URL
$Path_URL = azd env get-value Path_API_URL

Write-Host ""
Write-Host "Configuring APIM backend and API with subscription key..."

# Build bicep to ARM JSON (workaround for CLI issues)
$tempPathApi = Join-Path $env:TEMP "Path-api.json"
az bicep build --file infra/waypoints/1.2-deploy-Path.bicep --outfile $tempPathApi 2>$null

# Deploy APIM configuration
$DEPLOYMENT_OUTPUT = az deployment group create `
  --resource-group $RG `
  --template-file $tempPathApi `
  --parameters apimName=$APIM_NAME `
               backendUrl=$Path_URL `
  --query "properties.outputs" -o json

# Extract and save subscription key (for Path Services Product)
$outputObj = $DEPLOYMENT_OUTPUT | ConvertFrom-Json
$SUB_KEY = $outputObj.subscriptionKey.value
azd env set Path_SUBSCRIPTION_KEY $SUB_KEY

Write-Host ""
Write-Host "Exporting Path API as MCP server..."

# Build and deploy MCP export layer
$tempPathMcp = Join-Path $env:TEMP "Path-mcp.json"
az bicep build --file infra/waypoints/1.2-deploy-Path-mcp.bicep --outfile $tempPathMcp 2>$null

$MCP_OUTPUT = az deployment group create `
  --resource-group $RG `
  --template-file $tempPathMcp `
  --parameters apimName=$APIM_NAME `
  --query "properties.outputs" -o json

$mcpObj = $MCP_OUTPUT | ConvertFrom-Json
$MCP_ENDPOINT = $mcpObj.mcpEndpoint.value

Write-Host ""
Write-Host "=========================================="
Write-Host "Path API Deployed as MCP Server"
Write-Host "=========================================="
Write-Host ""
Write-Host "Path Services Product:"
Write-Host "  Subscription Key: $($SUB_KEY.Substring(0,8))...$($SUB_KEY.Substring($SUB_KEY.Length - 4))"
Write-Host ""
Write-Host "REST Endpoint: $APIM_URL/Pathapi/PATHS"
Write-Host "MCP Endpoint:  $MCP_ENDPOINT"
Write-Host ""
Write-Host "MCP Tools available:"
Write-Host "  - list_PATHS: List all available hiking PATHS"
Write-Host "  - get_Path: Get details for a specific Path"
Write-Host "  - check_conditions: Current Path conditions and hazards"
Write-Host "  - get_permit: Retrieve a Path permit"
Write-Host "  - request_permit: Request a new Path permit"
Write-Host ""
Write-Host "Current security: Subscription key only (no authentication!)"
Write-Host ""
