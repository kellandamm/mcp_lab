#!/bin/bash
# Waypoint 1.2: Deploy Path API
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

echo ""
echo "=========================================="
echo "Waypoint 1.2: Deploy Path API"
echo "=========================================="
echo ""

# Deploy the container service
echo "Building and deploying Path API..."
azd deploy Path-api

# Get environment values
RG=$(azd env get-value AZURE_RESOURCE_GROUP)
APIM_NAME=$(azd env get-value APIM_NAME)
APIM_URL=$(azd env get-value APIM_GATEWAY_URL)
Path_URL=$(azd env get-value Path_API_URL)

echo ""
echo "Configuring APIM backend and API with subscription key..."

# Build bicep to ARM JSON (workaround for CLI issues)
az bicep build --file infra/waypoints/1.2-deploy-Path.bicep --outfile /tmp/Path-api.json 2>/dev/null

# Deploy APIM configuration
DEPLOYMENT_OUTPUT=$(az deployment group create \
  --resource-group "$RG" \
  --template-file /tmp/Path-api.json \
  --parameters apimName="$APIM_NAME" \
               backendUrl="$Path_URL" \
  --query "properties.outputs" -o json)

# Extract and save subscription key (for Path Services Product)
SUB_KEY=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.subscriptionKey.value')
azd env set Path_SUBSCRIPTION_KEY "$SUB_KEY"

echo ""
echo "Exporting Path API as MCP server..."

# Build and deploy MCP export layer
az bicep build --file infra/waypoints/1.2-deploy-Path-mcp.bicep --outfile /tmp/Path-mcp.json 2>/dev/null

MCP_OUTPUT=$(az deployment group create \
  --resource-group "$RG" \
  --template-file /tmp/Path-mcp.json \
  --parameters apimName="$APIM_NAME" \
  --query "properties.outputs" -o json)

MCP_ENDPOINT=$(echo "$MCP_OUTPUT" | jq -r '.mcpEndpoint.value')

echo ""
echo "=========================================="
echo "Path API Deployed as MCP Server"
echo "=========================================="
echo ""
echo "Path Services Product:"
echo "  Subscription Key: ${SUB_KEY:0:8}...${SUB_KEY: -4}"
echo ""
echo "REST Endpoint: $APIM_URL/Pathapi/PATHS"
echo "MCP Endpoint:  $MCP_ENDPOINT"
echo ""
echo "MCP Tools available:"
echo "  - list_PATHS: List all available hiking PATHS"
echo "  - get_Path: Get details for a specific Path"
echo "  - check_conditions: Current Path conditions and hazards"
echo "  - get_permit: Retrieve a Path permit"
echo "  - request_permit: Request a new Path permit"
echo ""
echo "Current security: Subscription key only (no authentication!)"
echo ""
