# Test MCP server tools through APIM gateway
$ErrorActionPreference = 'Stop'

Write-Host "=========================================="
Write-Host "Testing MCP Server Tools"
Write-Host "=========================================="

# Check required variables
if (-not $env:APIM_GATEWAY_URL -or -not $env:ACCESS_TOKEN) {
    Write-Host "Error: APIM_GATEWAY_URL and ACCESS_TOKEN must be set"
    Write-Host "Get your access token from: az account get-access-token --resource api://<MCP_APP_CLIENT_ID> --query accessToken -o tsv"
    exit 1
}

Write-Host "Testing Workshop MCP Server..."
Write-Host "Calling get_weather tool..."

curl.exe -X POST "$($env:APIM_GATEWAY_URL)/Workshop-mcp/mcp" `
    -H "Authorization: Bearer $($env:ACCESS_TOKEN)" `
    -H "Content-Type: application/json" `
    -d '{"method":"tools/call","params":{"name":"get_weather","arguments":{"location":"summit"}}}'

Write-Host ""
Write-Host ""
Write-Host "Testing Path MCP Server..."
Write-Host "Calling list_PATHS tool..."

curl.exe -X POST "$($env:APIM_GATEWAY_URL)/Path-mcp/mcp" `
    -H "Authorization: Bearer $($env:ACCESS_TOKEN)" `
    -H "Content-Type: application/json" `
    -d '{"method":"tools/call","params":{"name":"list_PATHS","arguments":{}}}'

Write-Host ""
Write-Host ""
Write-Host "=========================================="
Write-Host "MCP Tool Testing Complete"
Write-Host "=========================================="
