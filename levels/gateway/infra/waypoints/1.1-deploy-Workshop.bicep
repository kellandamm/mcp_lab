// Waypoint 1.1: Deploy Workshop MCP Server to APIM
// Creates backend and API with subscription key only (vulnerable)

param apimName string
param backendUrl string

resource apim 'Microsoft.ApiManagement/service@2024-06-01-preview' existing = {
  name: apimName
}

// Backend pointing to Workshop Container App
resource WorkshopBackend 'Microsoft.ApiManagement/service/backends@2024-06-01-preview' = {
  parent: apim
  name: 'Workshop-mcp-backend'
  properties: {
    title: 'Workshop MCP Server'
    description: 'Backend for Workshop MCP Server running in Container Apps'
    protocol: 'http'
    url: backendUrl
  }
}

// Workshop MCP API - registered as native MCP type
resource WorkshopApi 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' = {
  parent: apim
  name: 'Workshop-mcp'
  properties: {
    displayName: 'Workshop MCP Server'
    description: 'MCP Server for weather, PATHS, and gear recommendations'
    path: 'Workshop/mcp'
    protocols: ['https']
    subscriptionRequired: false  // No authentication (vulnerable)
    type: 'mcp'
    #disable-next-line BCP037 // backendId is a preview feature not yet in type definitions
    backendId: WorkshopBackend.name
    #disable-next-line BCP037 // mcpProperties is a preview feature not yet in type definitions
    mcpProperties: {
      transportType: 'streamable'
    }
  }
}

// MCP endpoint operation
resource mcpOperation 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: WorkshopApi
  name: 'mcp-endpoint'
  properties: {
    displayName: 'MCP Endpoint'
    method: '*'
    urlTemplate: '/'
    description: 'MCP protocol endpoint'
  }
}

output WorkshopApiId string = WorkshopApi.id
output WorkshopBackendId string = WorkshopBackend.id
