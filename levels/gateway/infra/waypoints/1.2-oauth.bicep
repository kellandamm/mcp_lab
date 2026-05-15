// Waypoint 1.2: Add OAuth to Path MCP Server (keeping subscription keys)
// 
// This waypoint configures:
// 1. OAuth token validation on the Path MCP API (Entra ID tokens)
// 2. RFC 9728 Protected Resource Metadata (PRM) for discovery
//
// Note: MCP API type doesn't support custom operations, so we:
// - Use the existing oauth-prm API for RFC 9728 path-based discovery
// - Apply OAuth validation policy at API level (no suffix pattern for MCP type)
//
// Demonstrates hybrid authentication: subscription key + OAuth
// - Subscription key = which application (tracking/billing)
// - OAuth token = which user (authentication/audit)

param apimName string
param tenantId string
param mcpAppClientId string
param apimGatewayUrl string

resource apim 'Microsoft.ApiManagement/service@2024-06-01-preview' existing = {
  name: apimName
}

resource PathMcpApi 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' existing = {
  parent: apim
  name: 'Path-mcp'
}

// Reference existing OAuth PRM API (created by 1.1-fix)
resource oauthPrmApi 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' existing = {
  parent: apim
  name: 'oauth-prm'
}

// ============================================================
// PRM Operation for Path MCP (RFC 9728 path-based discovery)
// VS Code tries this path first: /.well-known/oauth-protected-resource/PATHS/mcp
// ============================================================
resource oauthPrmPathMcpOperation 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: oauthPrmApi
  name: 'get-prm-Path-mcp'
  properties: {
    displayName: 'Get PRM for Path MCP'
    description: 'RFC 9728 path-based discovery for /PATHS/mcp resource'
    method: 'GET'
    urlTemplate: '/.well-known/oauth-protected-resource/PATHS/mcp'
  }
}

// Policy for RFC 9728 path-based PRM discovery (Path MCP)
resource oauthPrmPathMcpPolicy 'Microsoft.ApiManagement/service/apis/operations/policies@2024-06-01-preview' = {
  parent: oauthPrmPathMcpOperation
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: replace(replace(replace(replace(
      loadTextContent('../policies/prm-metadata.xml'),
      '{{tenant-id}}', tenantId),
      '{{mcp-app-client-id}}', mcpAppClientId),
      '{{apim-gateway-url}}', apimGatewayUrl),
      '/Workshop/mcp', '/PATHS/mcp')  // Update resource path for Path MCP
  }
}

// ============================================================
// OAuth Token Validation Policy on Path MCP API
// Validates Entra ID tokens and returns proper 401 with PRM link
// Works WITH subscription keys (both required)
// 
// Note: MCP type APIs don't support operations, so we can only apply
// API-level policy. The 401 response will use context.Api.Path
// which resolves to "PATHS" for this API.
// ============================================================
resource PathMcpApiPolicy 'Microsoft.ApiManagement/service/apis/policies@2024-06-01-preview' = {
  parent: PathMcpApi
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: replace(replace(replace(
      loadTextContent('../policies/oauth-validation.xml'),
      '{{tenant-id}}', tenantId),
      '{{mcp-app-client-id}}', mcpAppClientId),
      '{{apim-gateway-url}}', apimGatewayUrl)
  }
}

output policyApplied bool = true
