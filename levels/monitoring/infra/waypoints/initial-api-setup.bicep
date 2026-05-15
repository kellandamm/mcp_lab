/*
  Initial APIM API Setup for Camp 4
  
  This follows the Camp 2 pattern:
  1. Workshop MCP Server - Native MCP type API (passthrough to Container App)
  2. Path REST API - HTTP API with operations (backend for Path MCP)
  3. Path MCP Server - MCP API that wraps Path REST API operations as tools
  4. Content Safety backend - For Layer 1 protection
  5. Security Function - For Layer 2 protection
  
  Security (Camp 4 starts with full security from Camp 3):
  - OAuth validation on MCP APIs (Workshop MCP, Path MCP)
  - Layer 1: Content Safety on MCP APIs
  - Layer 2: Security Function (input validation + output sanitization)
  
  This runs in postprovision hook after Container Apps are deployed.
*/

param apimName string
param WorkshopServerUrl string
param PathApiUrl string
param contentSafetyEndpoint string
param tenantId string
param mcpAppClientId string
param functionAppUrl string
param functionAppV1Url string
param functionAppV2Url string

resource apim 'Microsoft.ApiManagement/service@2024-06-01-preview' existing = {
  name: apimName
}

// ============================================
// Backends
// ============================================

// Backend: Workshop MCP Server
resource WorkshopBackend 'Microsoft.ApiManagement/service/backends@2024-06-01-preview' = {
  parent: apim
  name: 'Workshop-mcp-backend'
  properties: {
    protocol: 'http'
    url: '${WorkshopServerUrl}/mcp'
    title: 'Workshop MCP Server'
    description: 'Backend for Workshop MCP Server running in Container Apps'
  }
}

// Backend: Path API
resource PathBackend 'Microsoft.ApiManagement/service/backends@2024-06-01-preview' = {
  parent: apim
  name: 'Path-api-backend'
  properties: {
    protocol: 'http'
    url: PathApiUrl
    title: 'Path REST API'
    description: 'Backend for Path REST API with PII endpoint'
  }
}

// Backend: Content Safety
resource contentSafetyBackend 'Microsoft.ApiManagement/service/backends@2024-06-01-preview' = {
  parent: apim
  name: 'content-safety-backend'
  properties: {
    protocol: 'http'
    url: contentSafetyEndpoint
    title: 'Azure AI Content Safety'
    description: 'Backend for Content Safety API (Layer 1)'
  }
}

// ============================================
// Policy Fragment: MCP Content Safety (Prompt Shields)
// Reusable fragment for Layer 1 content safety checks
// ============================================

resource mcpContentSafetyFragment 'Microsoft.ApiManagement/service/policyFragments@2024-06-01-preview' = {
  parent: apim
  name: 'mcp-content-safety'
  properties: {
    description: 'Extracts MCP tool arguments and checks for prompt injection using Azure Content Safety Prompt Shields API'
    format: 'rawxml'
    value: loadTextContent('../policies/fragments/mcp-content-safety.xml')
  }
}

// Named Value: Function App URL (for Layer 2 policies)
// This is the URL that policies use - starts pointing to v1, workshop swaps to v2
resource namedValueFunctionUrl 'Microsoft.ApiManagement/service/namedValues@2024-06-01-preview' = {
  parent: apim
  name: 'function-app-url'
  properties: {
    displayName: 'function-app-url'
    value: functionAppUrl  // Initially points to v1
    secret: false
  }
}

// Named Value: Function App v1 URL (for reference/switching)
resource namedValueFunctionV1Url 'Microsoft.ApiManagement/service/namedValues@2024-06-01-preview' = {
  parent: apim
  name: 'function-app-v1-url'
  properties: {
    displayName: 'function-app-v1-url'
    value: functionAppV1Url
    secret: false
  }
}

// Named Value: Function App v2 URL (for reference/switching)
resource namedValueFunctionV2Url 'Microsoft.ApiManagement/service/namedValues@2024-06-01-preview' = {
  parent: apim
  name: 'function-app-v2-url'
  properties: {
    displayName: 'function-app-v2-url'
    value: functionAppV2Url
    secret: false
  }
}

// ============================================
// Workshop MCP API (Native MCP Type - Passthrough)
// ============================================

// Workshop MCP API - registered as native MCP type for passthrough
resource WorkshopMcpApi 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' = {
  parent: apim
  name: 'Workshop-mcp'
  properties: {
    displayName: 'Workshop MCP Server'
    description: 'MCP Server for weather, PATHS, and gear recommendations'
    path: 'Workshop/mcp'
    protocols: ['https']
    subscriptionRequired: false  // OAuth handles auth
    type: 'mcp'
    #disable-next-line BCP037 // backendId is a preview feature
    backendId: WorkshopBackend.name
    #disable-next-line BCP037 // mcpProperties is a preview feature
    mcpProperties: {
      transportType: 'streamable'
    }
  }
}

// MCP endpoint operation (catch-all for MCP protocol)
resource mcpOperation 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: WorkshopMcpApi
  name: 'mcp-endpoint'
  properties: {
    displayName: 'MCP Endpoint'
    method: '*'
    urlTemplate: '/'
    description: 'MCP protocol endpoint - handles all MCP JSON-RPC requests'
  }
}

// Policy for Workshop MCP API - OAuth + Content Safety + Security Function (Layer 1 + 2)
// Note: {{function-app-url}} is NOT replaced here - APIM resolves it at runtime from named value
// This allows switching between v1/v2 by just updating the named value
resource WorkshopMcpPolicy 'Microsoft.ApiManagement/service/apis/policies@2024-06-01-preview' = {
  parent: WorkshopMcpApi
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: replace(replace(replace(
      loadTextContent('../policies/Workshop-mcp-full-io-security.xml'),
      '{{tenant-id}}', tenantId),
      '{{mcp-app-client-id}}', mcpAppClientId),
      '{{apim-gateway-url}}', apim.properties.gatewayUrl)
  }
  dependsOn: [namedValueFunctionUrl, mcpContentSafetyFragment]
}

// ============================================
// Path REST API (Backend for Path MCP)
// ============================================

// Path API - exposed as REST API (no auth - accessed via MCP layer)
resource PathApi 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' = {
  parent: apim
  name: 'Path-api'
  properties: {
    displayName: 'Path REST API'
    description: 'REST API for Path information and permit management'
    path: 'Pathapi'
    protocols: ['https']
    subscriptionRequired: false
    apiType: 'http'
    serviceUrl: PathApiUrl
  }
}

// GET /Pathapi/PATHS - List all PATHS
resource listPATHSOp 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: PathApi
  name: 'list-PATHS'
  properties: {
    displayName: 'List PATHS'
    description: 'List all available hiking PATHS'
    method: 'GET'
    urlTemplate: '/PATHS'
  }
}

// GET /Pathapi/PATHS/{PathId} - Get Path details
resource getPathOp 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: PathApi
  name: 'get-Path'
  properties: {
    displayName: 'Get Path'
    description: 'Get details for a specific Path'
    method: 'GET'
    urlTemplate: '/PATHS/{PathId}'
    templateParameters: [
      {
        name: 'PathId'
        type: 'string'
        required: true
        description: 'Path identifier (e.g., summit-Path, base-Path)'
      }
    ]
  }
}

// GET /Pathapi/PATHS/{PathId}/conditions - Get Path conditions
resource checkConditionsOp 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: PathApi
  name: 'check-conditions'
  properties: {
    displayName: 'Check Conditions'
    description: 'Get current Path conditions and hazards'
    method: 'GET'
    urlTemplate: '/PATHS/{PathId}/conditions'
    templateParameters: [
      {
        name: 'PathId'
        type: 'string'
        required: true
        description: 'Path identifier'
      }
    ]
  }
}

// GET /Pathapi/permits/{permitId} - Get permit details
resource getPermitOp 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: PathApi
  name: 'get-permit'
  properties: {
    displayName: 'Get Permit'
    description: 'Retrieve a Path permit by ID'
    method: 'GET'
    urlTemplate: '/permits/{permitId}'
    templateParameters: [
      {
        name: 'permitId'
        type: 'string'
        required: true
        description: 'Permit identifier (e.g., PRM-2025-0001)'
      }
    ]
  }
}

// GET /Pathapi/permits/{permitId}/holder - Get permit holder PII (vulnerable endpoint)
resource getPermitHolderOp 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: PathApi
  name: 'get-permit-holder'
  properties: {
    displayName: 'Get Permit Holder'
    description: 'Get permit holder details (contains PII - demonstrates data leakage)'
    method: 'GET'
    urlTemplate: '/permits/{permitId}/holder'
    templateParameters: [
      {
        name: 'permitId'
        type: 'string'
        required: true
        description: 'Permit identifier'
      }
    ]
  }
}

// Path REST API Policy - Output sanitization (Layer 2)
// Input security is on Path-mcp, output sanitization is here (before SSE wrapping)
// Note: {{function-app-url}} is NOT replaced here - APIM resolves it at runtime from named value
resource PathApiPolicy 'Microsoft.ApiManagement/service/apis/policies@2024-06-01-preview' = {
  parent: PathApi
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: loadTextContent('../policies/Path-api-output-sanitization.xml')
  }
  dependsOn: [namedValueFunctionUrl]
}

// ============================================
// Path MCP Server (Wraps REST API as MCP Tools)
// ============================================

// Path MCP API - exposes REST operations as MCP tools
resource PathMcpApi 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' = {
  parent: apim
  name: 'Path-mcp'
  properties: {
    type: 'mcp'
    displayName: 'Path MCP Server'
    description: 'MCP server exposing Path and permit operations as tools'
    subscriptionRequired: false  // OAuth handles auth
    path: 'PATHS'               // MCP type adds /mcp automatically -> PATHS/mcp
    protocols: ['https']
    #disable-next-line BCP037 // mcpTools is a preview feature
    mcpTools: [
      {
        name: listPATHSOp.name
        operationId: listPATHSOp.id
        description: listPATHSOp.properties.description
      }
      {
        name: getPathOp.name
        operationId: getPathOp.id
        description: getPathOp.properties.description
      }
      {
        name: checkConditionsOp.name
        operationId: checkConditionsOp.id
        description: checkConditionsOp.properties.description
      }
      {
        name: getPermitOp.name
        operationId: getPermitOp.id
        description: getPermitOp.properties.description
      }
      {
        name: getPermitHolderOp.name
        operationId: getPermitHolderOp.id
        description: getPermitHolderOp.properties.description
      }
    ]
  }
  dependsOn: [
    listPATHSOp
    getPathOp
    checkConditionsOp
    getPermitOp
    getPermitHolderOp
  ]
}

// Policy for Path MCP API - OAuth + Content Safety + Input Check (Layer 1 + 2 input)
// Output sanitization is on Path-api (to avoid SSE blocking)
// Note: {{function-app-url}} is NOT replaced here - APIM resolves it at runtime from named value
resource PathMcpPolicy 'Microsoft.ApiManagement/service/apis/policies@2024-06-01-preview' = {
  parent: PathMcpApi
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: replace(replace(replace(
      loadTextContent('../policies/Path-mcp-input-security.xml'),
      '{{tenant-id}}', tenantId),
      '{{mcp-app-client-id}}', mcpAppClientId),
      '{{apim-gateway-url}}', apim.properties.gatewayUrl)
  }
  dependsOn: [namedValueFunctionUrl, mcpContentSafetyFragment]
}

// ============================================
// OAuth PRM Discovery API (RFC 9728)
// Enables VS Code MCP OAuth discovery
// ============================================

// OAuth PRM API for RFC 9728 path-based discovery
resource oauthPrmApi 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' = {
  parent: apim
  name: 'oauth-prm'
  properties: {
    displayName: 'OAuth Protected Resource Metadata'
    description: 'RFC 9728 Protected Resource Metadata for OAuth discovery'
    path: ''  // Root path
    protocols: ['https']
    subscriptionRequired: false
    apiType: 'http'
  }
}

// PRM operation for Workshop MCP (RFC 9728 path-based discovery)
resource oauthPrmWorkshopMcpOperation 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: oauthPrmApi
  name: 'get-prm-Workshop-mcp'
  properties: {
    displayName: 'Get PRM for Workshop MCP'
    description: 'RFC 9728 path-based discovery for /Workshop/mcp resource'
    method: 'GET'
    urlTemplate: '/.well-known/oauth-protected-resource/Workshop/mcp'
  }
}

// Policy for Workshop MCP PRM discovery
resource oauthPrmWorkshopMcpPolicy 'Microsoft.ApiManagement/service/apis/operations/policies@2024-06-01-preview' = {
  parent: oauthPrmWorkshopMcpOperation
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: replace(replace(replace(replace(
      loadTextContent('../policies/prm-metadata.xml'),
      '{{tenant-id}}', tenantId),
      '{{mcp-app-client-id}}', mcpAppClientId),
      '{{apim-gateway-url}}', apim.properties.gatewayUrl),
      '{{api-path}}', 'Workshop/mcp')
  }
}

// PRM operation for Path MCP (RFC 9728 path-based discovery)
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

// Policy for Path MCP PRM discovery
resource oauthPrmPathMcpPolicy 'Microsoft.ApiManagement/service/apis/operations/policies@2024-06-01-preview' = {
  parent: oauthPrmPathMcpOperation
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: replace(replace(replace(replace(
      loadTextContent('../policies/prm-metadata.xml'),
      '{{tenant-id}}', tenantId),
      '{{mcp-app-client-id}}', mcpAppClientId),
      '{{apim-gateway-url}}', apim.properties.gatewayUrl),
      '{{api-path}}', 'PATHS/mcp')
  }
}

// ============================================
// Outputs
// ============================================

output WorkshopMcpApiId string = WorkshopMcpApi.id
output PathApiId string = PathApi.id
output PathMcpApiId string = PathMcpApi.id
output WorkshopBackendId string = WorkshopBackend.id
output PathBackendId string = PathBackend.id
output contentSafetyBackendId string = contentSafetyBackend.id
output WorkshopMcpEndpoint string = '${apim.properties.gatewayUrl}/Workshop/mcp'
output PathMcpEndpoint string = '${apim.properties.gatewayUrl}/PATHS/mcp'
