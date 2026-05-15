#!/bin/bash
# Test MCP server tools through APIM gateway

set -e

echo "=========================================="
echo "Testing MCP Server Tools"
echo "=========================================="

# Check required variables
if [ -z "$APIM_GATEWAY_URL" ] || [ -z "$ACCESS_TOKEN" ]; then
    echo "Error: APIM_GATEWAY_URL and ACCESS_TOKEN must be set"
    echo "Get your access token from: az account get-access-token --resource api://<MCP_APP_CLIENT_ID> --query accessToken -o tsv"
    exit 1
fi

echo "Testing Workshop MCP Server..."
echo "Calling get_weather tool..."

curl -X POST "$APIM_GATEWAY_URL/Workshop-mcp/mcp" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "method": "tools/call",
        "params": {
            "name": "get_weather",
            "arguments": {
                "location": "summit"
            }
        }
    }'

echo ""
echo ""
echo "Testing Path MCP Server..."
echo "Calling list_PATHS tool..."

curl -X POST "$APIM_GATEWAY_URL/Path-mcp/mcp" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "method": "tools/call",
        "params": {
            "name": "list_PATHS",
            "arguments": {}
        }
    }'

echo ""
echo ""
echo "=========================================="
echo "MCP Tool Testing Complete"
echo "=========================================="
